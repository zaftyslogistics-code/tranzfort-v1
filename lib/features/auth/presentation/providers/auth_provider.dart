import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/datasources/mock_auth_datasource.dart';
import '../../data/datasources/supabase_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart' as domain;
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/update_profile.dart';
import '../../../../core/config/env_config.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden');
});

final authDataSourceProvider = Provider<AuthDataSource>((ref) {
  if (EnvConfig.useMockAuth) {
    final prefs = ref.watch(sharedPreferencesProvider);
    return MockAuthDataSource(prefs);
  } else {
    final supabase = Supabase.instance.client;
    return SupabaseAuthDataSourceImpl(supabaseClient: supabase);
  }
});

final authRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(authDataSourceProvider);
  return AuthRepositoryImpl(dataSource);
});

final sendOtpUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return SendOtp(repository);
});

final verifyOtpUseCaseProvider = Provider((ref) {
  final repository = ref.watch(authRepositoryProvider);
  return VerifyOtp(repository);
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

class AuthState {
  final domain.User? user;
  final bool isLoading;
  final String? error;
  final bool isAuthenticated;
  final bool hasCheckedAuth;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isAuthenticated = false,
    this.hasCheckedAuth = false,
  });

  AuthState copyWith({
    domain.User? user,
    bool? isLoading,
    String? error,
    bool? isAuthenticated,
    bool? hasCheckedAuth,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      hasCheckedAuth: hasCheckedAuth ?? this.hasCheckedAuth,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final SendOtp sendOtpUseCase;
  final VerifyOtp verifyOtpUseCase;
  final GetCurrentUser getCurrentUserUseCase;
  final SignOut signOutUseCase;
  final UpdateProfile updateProfileUseCase;

  AuthNotifier({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.getCurrentUserUseCase,
    required this.signOutUseCase,
    required this.updateProfileUseCase,
  }) : super(AuthState());

  Future<void> checkAuthStatus() async {
    if (state.hasCheckedAuth) return;
    state = state.copyWith(isLoading: true, error: null);
    final result = await getCurrentUserUseCase();
    result.fold(
      (failure) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          error: failure.message,
          hasCheckedAuth: true,
        );
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: user != null,
          hasCheckedAuth: true,
        );
      },
    );
  }

  Future<bool> sendOtp(String mobileNumber, String countryCode) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await sendOtpUseCase(mobileNumber, countryCode);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (_) {
        state = state.copyWith(isLoading: false);
        return true;
      },
    );
  }

  Future<bool> verifyOtp(String mobileNumber, String otp) async {
    state = state.copyWith(isLoading: true, error: null);
    final result = await verifyOtpUseCase(mobileNumber, otp);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(
          user: user,
          isLoading: false,
          isAuthenticated: true,
          hasCheckedAuth: true,
        );
        return true;
      },
    );
  }

  Future<bool> updateUserProfile(Map<String, dynamic> updates) async {
    if (state.user == null) return false;
    
    state = state.copyWith(isLoading: true, error: null);
    final result = await updateProfileUseCase(state.user!.id, updates);
    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (user) {
        state = state.copyWith(user: user, isLoading: false);
        return true;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true);
    await signOutUseCase();
    state = AuthState(hasCheckedAuth: true);
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    sendOtpUseCase: ref.watch(sendOtpUseCaseProvider),
    verifyOtpUseCase: ref.watch(verifyOtpUseCaseProvider),
    getCurrentUserUseCase: ref.watch(getCurrentUserUseCaseProvider),
    signOutUseCase: ref.watch(signOutUseCaseProvider),
    updateProfileUseCase: ref.watch(updateProfileUseCaseProvider),
  );
});
