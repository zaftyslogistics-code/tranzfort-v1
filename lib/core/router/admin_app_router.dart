import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../utils/logger.dart';
import '../../../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../../../features/admin/presentation/screens/admin_config_screen.dart';
import '../../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../../features/admin/presentation/screens/admin_load_monitoring_screen.dart';
import '../../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../../features/admin/presentation/screens/admin_super_loads_screen.dart';
import '../../../features/admin/presentation/screens/admin_user_management_screen.dart';
import '../../../features/admin/presentation/screens/admin_verification_screen.dart';
import '../../../features/admin/presentation/screens/manage_admins_screen.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/auth/presentation/screens/admin_email_password_login_screen.dart';
import '../../../features/loads/presentation/screens/post_load_step1_screen.dart';
import '../../../features/loads/presentation/screens/post_load_step2_screen.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/admin-splash',
    refreshListenable: GoRouterRefreshNotifier(ref),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.isAuthenticated;
      final isLoading = authState.isLoading;
      final hasCheckedAuth = authState.hasCheckedAuth;

      Logger.info('🔍 AdminRouter redirect: location=${state.matchedLocation}, isAuthenticated=$isAuthenticated, isLoading=$isLoading, hasCheckedAuth=$hasCheckedAuth');

      final isOnSplash = state.matchedLocation == '/admin-splash';
      final isOnLogin = state.matchedLocation == '/admin-login';
      final isOnNotAuthorized = state.matchedLocation == '/admin-not-authorized';

      // Stay on splash until auth check completes
      if (!hasCheckedAuth || isLoading) {
        Logger.info('🔍 AdminRouter: Staying on splash (auth check in progress)');
        return isOnSplash ? null : '/admin-splash';
      }

      // After auth check completes, redirect based on auth state
      if (!isAuthenticated) {
        Logger.info('🔍 AdminRouter: Not authenticated, redirecting to login');
        return (isOnLogin || isOnSplash) ? null : '/admin-login';
      }

      // User is authenticated, check if they're an admin
      if (authState.admin == null) {
        Logger.info('🔍 AdminRouter: Authenticated but not admin, redirecting to not-authorized');
        return isOnNotAuthorized ? null : '/admin-not-authorized';
      }

      // User is authenticated admin, redirect to dashboard if on auth screens
      if (isOnLogin || isOnSplash || isOnNotAuthorized) {
        Logger.info('🔍 AdminRouter: Authenticated admin, redirecting to dashboard');
        return '/admin/dashboard';
      }

      // Ensure all routes start with /admin
      final isOnAdmin = state.matchedLocation.startsWith('/admin');
      if (!isOnAdmin) {
        Logger.info('🔍 AdminRouter: Not on admin route, redirecting to dashboard');
        return '/admin/dashboard';
      }

      Logger.info('🔍 AdminRouter: No redirect needed');
      return null;
    },
    routes: [
      GoRoute(
        path: '/admin-splash',
        builder: (context, state) => const AdminSplashScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminEmailPasswordLoginScreen(),
      ),
      GoRoute(
        path: '/admin-not-authorized',
        builder: (context, state) => const AdminNotAuthorizedScreen(),
      ),
      GoRoute(
        path: '/admin/dashboard',
        builder: (context, state) => const AdminDashboardScreen(),
      ),
      GoRoute(
        path: '/admin/verifications',
        builder: (context, state) => const AdminVerificationScreen(),
      ),
      GoRoute(
        path: '/admin/loads',
        builder: (context, state) => const AdminLoadMonitoringScreen(),
      ),
      GoRoute(
        path: '/admin/config',
        builder: (context, state) => const AdminConfigScreen(),
      ),
      GoRoute(
        path: '/admin/users',
        builder: (context, state) => const AdminUserManagementScreen(),
      ),
      GoRoute(
        path: '/admin/reports',
        builder: (context, state) => const AdminReportsScreen(),
      ),
      GoRoute(
        path: '/admin/analytics',
        builder: (context, state) => const AdminAnalyticsScreen(),
      ),
      GoRoute(
        path: '/admin/manage-admins',
        builder: (context, state) => const ManageAdminsScreen(),
      ),
      GoRoute(
        path: '/admin/super-loads',
        builder: (context, state) => const AdminSuperLoadsScreen(),
      ),
      GoRoute(
        path: '/admin/super-loads/create-step1',
        builder: (context, state) => const PostLoadStep1Screen(
          nextRoutePath: '/admin/super-loads/create-step2',
          showBottomNavigation: false,
        ),
      ),
      GoRoute(
        path: '/admin/super-loads/create-step2',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PostLoadStep2Screen(
            loadData: extra?['loadData'] ?? {},
            existingLoad: extra?['existingLoad'],
            onSuccessRoute: '/admin/super-loads',
            showBottomNavigation: false,
            forceSuperLoad: true,
          );
        },
      ),
      GoRoute(
        path: '/admin/super-loads/edit-step1',
        builder: (context, state) => PostLoadStep1Screen(
          existingLoad: state.extra as dynamic,
          nextRoutePath: '/admin/super-loads/edit-step2',
          showBottomNavigation: false,
        ),
      ),
      GoRoute(
        path: '/admin/super-loads/edit-step2',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PostLoadStep2Screen(
            loadData: extra?['loadData'] ?? {},
            existingLoad: extra?['existingLoad'],
            onSuccessRoute: '/admin/super-loads',
            showBottomNavigation: false,
            forceSuperLoad: true,
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: AppColors.danger),
              const SizedBox(height: AppDimensions.md),
              Text(
                'Error: ${state.error}',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textPrimary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.lg),
              ElevatedButton(
                onPressed: () => context.go('/admin-login'),
                child: const Text('Go to Admin Login'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

class GoRouterRefreshNotifier extends ChangeNotifier {
  GoRouterRefreshNotifier(this._ref) {
    _ref.listen<AuthState>(
      authNotifierProvider,
      (previous, next) {
        notifyListeners();
      },
    );
  }

  final Ref _ref;
}

class AdminSplashScreen extends ConsumerStatefulWidget {
  const AdminSplashScreen({super.key});

  @override
  ConsumerState<AdminSplashScreen> createState() => _AdminSplashScreenState();
}

class _AdminSplashScreenState extends ConsumerState<AdminSplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    Logger.info('🔍 AdminSplashScreen: Starting auth check...');
    try {
      await ref.read(authNotifierProvider.notifier).checkAuthStatus(force: true);
      Logger.info('🔍 AdminSplashScreen: Auth check completed');
      
      if (!mounted) return;
      
      // Explicitly navigate based on auth state after check completes
      final authState = ref.read(authNotifierProvider);
      Logger.info('🔍 AdminSplashScreen: Auth state after check - isAuthenticated=${authState.isAuthenticated}, admin=${authState.admin != null}');
      
      if (!authState.isAuthenticated) {
        Logger.info('🔍 AdminSplashScreen: Navigating to login');
        context.go('/admin-login');
      } else if (authState.admin == null) {
        Logger.info('🔍 AdminSplashScreen: Navigating to not-authorized');
        context.go('/admin-not-authorized');
      } else {
        Logger.info('🔍 AdminSplashScreen: Navigating to dashboard');
        context.go('/admin/dashboard');
      }
    } catch (e, st) {
      Logger.error('❌ AdminSplashScreen: Auth check failed', error: e, stackTrace: st);
      if (mounted) {
        context.go('/admin-login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.darkBackground,
              AppColors.secondaryBackground,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryVariant],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.cyanGlowStrong,
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.admin_panel_settings,
                  size: 60,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: AppDimensions.xl),
              Text(
                'Transfort Admin',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Administrative Dashboard',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
              ),
              const SizedBox(height: AppDimensions.xl),
              const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class AdminNotAuthorizedScreen extends ConsumerStatefulWidget {
  const AdminNotAuthorizedScreen({super.key});

  @override
  ConsumerState<AdminNotAuthorizedScreen> createState() =>
      _AdminNotAuthorizedScreenState();
}

class _AdminNotAuthorizedScreenState
    extends ConsumerState<AdminNotAuthorizedScreen> {
  bool _didLogout = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      if (_didLogout) return;
      _didLogout = true;

      try {
        await ref.read(authNotifierProvider.notifier).logout();
      } catch (e, st) {
        Logger.error('Failed to logout non-admin session',
            error: e, stackTrace: st);
      }

      if (!mounted) return;
      if (context.mounted) context.go('/admin-login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.lg),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.lock_outline,
                  size: 64, color: AppColors.warning),
              const SizedBox(height: AppDimensions.md),
              Text(
                'This account is not an admin.',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppDimensions.sm),
              Text(
                'Please sign in with an admin account.',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
