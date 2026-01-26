import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:local_auth/local_auth.dart';
import '../../data/datasources/auth_datasource.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/admin.dart' as domain;
import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/sign_in_with_email_password.dart';
import '../../domain/usecases/sign_up_with_email_password.dart';
import '../../domain/usecases/get_admin_profile.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/update_profile.dart';
import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/analytics_service.dart';
import '../../../../core/utils/logger.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  return SupabaseAuthDataSourceImpl(
    supabaseClient: Supabase.instance.client,
  );
});

// Additional provider for checking Supabase session directly
final supabaseAuthProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final authRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final signUpWithEmailPasswordUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignUpWithEmailPassword(repository);
});

final signInWithEmailPasswordUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignInWithEmailPassword(repository);
});

final getCurrentUserUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetCurrentUser(repository);
});

final signOutUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SignOut(repository);
});

final updateProfileUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return UpdateProfile(repository);
});

final getAdminProfileUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return GetAdminProfile(repository);
});

final biometricServiceProvider = Provider<BiometricService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return BiometricService(prefs);
});

class AuthState {
  final domain.User? user;
  final domain.Admin? admin;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool hasCheckedAuth;

  static const Object _unset = Object();

  AuthState({
    this.user,
    this.admin,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.hasCheckedAuth = false,
  });

  AuthState copyWith({
    Object? user = _unset,
    Object? admin = _unset,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? hasCheckedAuth,
  }) {
    return AuthState(
      user: identical(user, _unset) ? this.user : user as domain.User?,
      admin: identical(admin, _unset) ? this.admin : admin as domain.Admin?,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCheckedAuth: hasCheckedAuth ?? this.hasCheckedAuth,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SignUpWithEmailPassword signUpWithEmailPasswordUseCase;
  final SignInWithEmailPassword signInWithEmailPasswordUseCase;
  final GetCurrentUser getCurrentUserUseCase;
  final GetAdminProfile getAdminProfileUseCase;
  final SignOut signOutUseCase;
  final UpdateProfile updateProfileUseCase;
  final BiometricService biometricService;
  final SupabaseClient supabaseClient;

  Timer? _sessionTimer;
  Future<void>? _authCheckInFlight;
  static const Duration _authTimeout = Duration(seconds: 8);

  AuthNotifier({
    required this.signUpWithEmailPasswordUseCase,
    required this.signInWithEmailPasswordUseCase,
    required this.getCurrentUserUseCase,
    required this.getAdminProfileUseCase,
    required this.signOutUseCase,
    required this.updateProfileUseCase,
    required this.biometricService,
    required this.supabaseClient,
  }) : super(AuthState()) {
    _startSessionTimer(); // Start initial timer (will be cancelled if not authenticated)
    // Automatically check auth status on initialization
    checkAuthStatus();
  }

  void _startSessionTimer() {
    _sessionTimer?.cancel();
    // Session timeout: 2 hours
    _sessionTimer = Timer(const Duration(hours: 2), () {
      logout();
    });
  }

  void _cancelSessionTimer() {
    _sessionTimer?.cancel();
    _sessionTimer = null;
  }

  Future<void> checkAuthStatus({bool force = false}) async {
    Logger.info('🔍 AuthNotifier: checkAuthStatus called - force=$force, hasCheckedAuth=${state.hasCheckedAuth}, isLoading=${state.isLoading}');
    
    if (!force && state.hasCheckedAuth) {
      Logger.info('🔍 AuthNotifier: Already checked auth, skipping');
      return;
    }

    final inFlight = _authCheckInFlight;
    if (inFlight != null) {
      Logger.info('🔍 AuthNotifier: Auth check already in-flight, awaiting');
      await inFlight;
      return;
    }

    _authCheckInFlight = _checkAuthStatusInternal(force: force).whenComplete(() {
      _authCheckInFlight = null;
    });

    await _authCheckInFlight;
  }

  Future<void> _checkAuthStatusInternal({required bool force}) async {
    
    Logger.info('🔍 AuthNotifier: Starting auth check...');
    state = state.copyWith(
      isLoading: true,
      error: null,
      user: null,
      admin: null,
    );

    try {
      Logger.info('🔍 AuthNotifier: Calling getCurrentUserUseCase...');
      final result = await getCurrentUserUseCase().timeout(_authTimeout);
      Logger.info('🔍 AuthNotifier: getCurrentUserUseCase completed');

      await result.fold(
        (failure) async {
          Logger.error('🔍 AuthNotifier: getCurrentUser failed - ${failure.message}');
          _cancelSessionTimer(); // No active session
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: false,
            user: null,
            admin: null,
            error: failure.message,
            hasCheckedAuth: true,
          );
        },
        (user) async {
          Logger.info('🔍 AuthNotifier: Got user - ${user != null ? user.id : "null"}');
          if (user != null) {
            AnalyticsService().setUserId(user.id);

            // If user exists, check for admin profile
            Logger.info('🔍 AuthNotifier: Checking admin profile...');
            final adminResult =
                await getAdminProfileUseCase(user.id).timeout(_authTimeout);
            Logger.info('🔍 AuthNotifier: Admin profile check completed');
            
            adminResult.fold(
              (failure) {
                Logger.warning('🔍 AuthNotifier: Admin profile failed - ${failure.message}');
                _startSessionTimer(); // Start session timer for regular user
                state = state.copyWith(
                  user: user,
                  admin: null,
                  isLoading: false,
                  isAuthenticated: true,
                  hasCheckedAuth: true,
                );
              },
              (admin) {
                Logger.info('🔍 AuthNotifier: Admin profile found - ${admin?.role}');
                _startSessionTimer(); // Start session timer for admin
                state = state.copyWith(
                  user: user,
                  admin: admin,
                  isLoading: false,
                  isAuthenticated: true,
                  hasCheckedAuth: true,
                );
              },
            );
          } else {
            Logger.info('🔍 AuthNotifier: No user found');
            _cancelSessionTimer(); // No user found
            state = state.copyWith(
              isLoading: false,
              isAuthenticated: false,
              user: null,
              admin: null,
              hasCheckedAuth: true,
            );
          }
        },
      );
    } on TimeoutException catch (e, st) {
      Logger.error('🔍 AuthNotifier: Auth check timed out', error: e, stackTrace: st);
      _cancelSessionTimer();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        admin: null,
        error: 'Auth check timed out',
        hasCheckedAuth: true,
      );
    } catch (e, st) {
      Logger.error('🔍 AuthNotifier: Auth check failed unexpectedly', error: e, stackTrace: st);
      _cancelSessionTimer();
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        admin: null,
        error: e.toString(),
        hasCheckedAuth: true,
      );
    }
    
    Logger.info('🔍 AuthNotifier: Auth check completed - isAuthenticated=${state.isAuthenticated}, hasCheckedAuth=${state.hasCheckedAuth}');
  }

  Future<bool> signUpWithEmailPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await signUpWithEmailPasswordUseCase(email, password);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) async {
        AnalyticsService().setUserId(user.id);
        final adminResult = await getAdminProfileUseCase(user.id);
        adminResult.fold(
          (_) {
            _startSessionTimer(); // Start session timer for regular user
            state = state.copyWith(
              user: user,
              isLoading: false,
              isAuthenticated: true,
              hasCheckedAuth: true,
            );
          },
          (admin) {
            _startSessionTimer(); // Start session timer for admin
            state = state.copyWith(
              user: user,
              admin: admin,
              isLoading: false,
              isAuthenticated: true,
              hasCheckedAuth: true,
            );
          },
        );
        return true;
      },
    );
  }

  Future<bool> signInWithEmailPassword(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await signInWithEmailPasswordUseCase(email, password);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) async {
        AnalyticsService().setUserId(user.id);
        final adminResult = await getAdminProfileUseCase(user.id);
        adminResult.fold(
          (_) {
            _startSessionTimer();
            state = state.copyWith(
              user: user,
              isLoading: false,
              isAuthenticated: true,
              hasCheckedAuth: true,
            );
          },
          (admin) {
            _startSessionTimer();
            state = state.copyWith(
              user: user,
              admin: admin,
              isLoading: false,
              isAuthenticated: true,
              hasCheckedAuth: true,
            );
          },
        );
        return true;
      },
    );
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    Logger.info('🔧 AUTH: Updating user profile with updates: $updates');
    Logger.info('🔧 AUTH: Current user state: ${state.user?.id ?? "null"}');

    if (state.user == null) {
      Logger.error('❌ AUTH: Cannot update profile - user is null');
      return false;
    }

    state = state.copyWith(isLoading: true, error: null);
    Logger.info(
        '🔧 AUTH: Calling updateProfileUseCase for user: ${state.user!.id}');

    final result = await updateProfileUseCase(state.user!.id, updates);
    return result.fold(
      (failure) {
        Logger.error('❌ AUTH: Profile update failed: ${failure.message}');
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        Logger.info(
            '✅ AUTH: Profile updated successfully for user: ${user.id}');
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
    );
  }

  Future<void> logout() async {
    _cancelSessionTimer();
    await biometricService.disableBiometric(); // Disable biometric on logout
    state = state.copyWith(isLoading: true);
    await signOutUseCase();
    AnalyticsService().clearUser();
    state = AuthState(hasCheckedAuth: true);
  }

  Future<bool> isBiometricAvailable() async {
    return await biometricService.isBiometricAvailable;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    return await biometricService.getAvailableBiometrics();
  }

  Future<bool> authenticateWithBiometric(String userId) async {
    return await biometricService.authenticateUser(userId);
  }

  Future<void> enableBiometric(String userId) async {
    await biometricService.enableBiometric(userId);
  }

  Future<void> disableBiometric() async {
    await biometricService.disableBiometric();
  }

  bool get isBiometricEnabled => biometricService.isBiometricEnabled;
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    signUpWithEmailPasswordUseCase:
        ref.read(signUpWithEmailPasswordUseCaseProvider),
    signInWithEmailPasswordUseCase:
        ref.read(signInWithEmailPasswordUseCaseProvider),
    getCurrentUserUseCase: ref.read(getCurrentUserUseCaseProvider),
    getAdminProfileUseCase: ref.read(getAdminProfileUseCaseProvider),
    signOutUseCase: ref.read(signOutUseCaseProvider),
    updateProfileUseCase: ref.read(updateProfileUseCaseProvider),
    biometricService: ref.read(biometricServiceProvider),
    supabaseClient: Supabase.instance.client,
  );
});
