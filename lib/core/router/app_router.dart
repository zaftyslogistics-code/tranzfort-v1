import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/admin/presentation/screens/admin_dashboard_screen.dart';
import '../../features/admin/presentation/screens/admin_verification_screen.dart';
import '../../features/admin/presentation/screens/admin_load_monitoring_screen.dart';
import '../../features/admin/presentation/screens/admin_config_screen.dart';
import '../../features/admin/presentation/screens/admin_user_management_screen.dart';
import '../../features/admin/presentation/screens/admin_reports_screen.dart';
import '../../features/admin/presentation/screens/admin_analytics_screen.dart';
import '../../features/admin/presentation/screens/manage_admins_screen.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/admin_email_password_login_screen.dart';
import '../../features/auth/presentation/screens/signup_screen.dart';
import '../../features/auth/presentation/screens/intent_selection_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_dimensions.dart';
import '../../features/loads/presentation/screens/supplier_dashboard_screen.dart';
import '../../features/loads/presentation/screens/my_loads_screen.dart';
import '../../features/fleet/presentation/screens/fleet_management_screen.dart';
import '../../features/fleet/presentation/screens/add_truck_screen.dart';
import '../../features/loads/presentation/screens/post_load_step1_screen.dart';
import '../../features/loads/presentation/screens/post_load_step2_screen.dart';
import '../../features/loads/presentation/screens/trucker_feed_screen.dart';
import '../../features/loads/presentation/screens/load_detail_supplier_screen.dart';
import '../../features/loads/presentation/screens/load_detail_trucker_screen.dart';
import '../../features/loads/presentation/screens/filters_screen.dart';
import '../../features/chat/presentation/screens/chat_screen.dart';
import '../../features/chat/presentation/screens/chat_list_screen.dart';
import '../../features/verification/presentation/screens/verification_center_screen.dart';
import '../../features/saved_searches/presentation/screens/saved_searches_screen.dart';
import '../../features/notifications/presentation/screens/notifications_screen.dart';
import '../../features/profile/presentation/screens/settings_screen.dart';
import '../../features/ratings/presentation/screens/ratings_screen.dart';
import '../../shared/widgets/glassmorphic_button.dart';
import '../../shared/widgets/glassmorphic_card.dart';
import '../../shared/widgets/gradient_text.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final authNotifier = ref.read(authNotifierProvider.notifier);

  return GoRouter(
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(authNotifier.stream),
    redirect: (context, state) {
      final authState = ref.read(authNotifierProvider);
      final isAuthenticated = authState.isAuthenticated;
      final user = authState.user;
      final isLoading = authState.isLoading;
      final hasCheckedAuth = authState.hasCheckedAuth;

      if (!hasCheckedAuth) {
        return state.matchedLocation == '/splash' ? null : '/splash';
      }

      if (isLoading) return null;

      final isOnSplash = state.matchedLocation == '/splash';
      final isOnLogin = state.matchedLocation == '/login';
      final isOnSignup = state.matchedLocation == '/signup';
      final isOnIntent = state.matchedLocation == '/intent-selection';
      final isOnAdminLogin = state.matchedLocation == '/admin-login';

      final isOnAdmin = state.matchedLocation.startsWith('/admin');

      if (!isAuthenticated) {
        return (isOnLogin || isOnSignup || isOnAdminLogin) ? null : '/login';
      }

      // Admin sessions always go to admin dashboard (even if user profile is missing)
      if (isAuthenticated && authState.admin != null) {
        if (!isOnAdmin) {
          return '/admin/dashboard';
        }
        return null;
      }

      if (isAuthenticated && user != null) {
        // Authenticated but NOT an admin: block /admin routes
        if (isOnAdmin) {
          if (user.isSupplierEnabled) return '/supplier-dashboard';
          if (user.isTruckerEnabled) return '/trucker-feed';
          return '/intent-selection';
        }

        final needsIntentSelection =
            !user.isSupplierEnabled && !user.isTruckerEnabled;

        if (needsIntentSelection && !isOnIntent) {
          return '/intent-selection';
        }

        // If user has selected an intent, redirect to appropriate dashboard
        if (!needsIntentSelection) {
          // Only redirect if we're not already on the target page
          final isOnSupplierDashboard =
              state.matchedLocation == '/supplier-dashboard';
          final isOnTruckerFeed = state.matchedLocation == '/trucker-feed';

          if ((isOnIntent || isOnLogin || isOnSignup || isOnSplash) &&
              !isOnSupplierDashboard &&
              !isOnTruckerFeed) {
            if (user.isSupplierEnabled) {
              return '/supplier-dashboard';
            }
            if (user.isTruckerEnabled) {
              return '/trucker-feed';
            }
          }
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: '/admin-login',
        builder: (context, state) => const AdminEmailPasswordLoginScreen(),
      ),
      GoRoute(
        path: '/intent-selection',
        builder: (context, state) => const IntentSelectionScreen(),
      ),
      GoRoute(
        path: '/supplier-dashboard',
        name: 'supplier-dashboard',
        builder: (context, state) => const SupplierDashboardScreen(),
      ),
      GoRoute(
        path: '/my-loads',
        name: 'my-loads',
        builder: (context, state) => const MyLoadsScreen(),
      ),
      GoRoute(
        path: '/fleet-management',
        name: 'fleet-management',
        builder: (context, state) => const FleetManagementScreen(),
      ),
      GoRoute(
        path: '/add-truck',
        name: 'add-truck',
        builder: (context, state) => const AddTruckScreen(),
      ),
      GoRoute(
        path: '/edit-truck/:truckId',
        name: 'edit-truck',
        builder: (context, state) {
          // TODO: Fetch truck data and pass to AddTruckScreen
          return const AddTruckScreen();
        },
      ),
      GoRoute(
        path: '/trucker-feed',
        name: 'trucker-feed',
        builder: (context, state) => const TruckerFeedScreen(),
      ),
      GoRoute(
        path: '/post-load-step1',
        builder: (context, state) => PostLoadStep1Screen(
          existingLoad: state.extra as dynamic,
        ),
      ),
      GoRoute(
        path: '/post-load-step2',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          return PostLoadStep2Screen(
            loadData: extra?['loadData'] ?? {},
            existingLoad: extra?['existingLoad'],
          );
        },
      ),
      GoRoute(
        path: '/load-detail-supplier',
        builder: (context, state) => LoadDetailSupplierScreen(
          loadId: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/load-detail-trucker',
        builder: (context, state) => LoadDetailTruckerScreen(
          loadId: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/filters',
        builder: (context, state) => const FiltersScreen(),
      ),
      GoRoute(
        path: '/chat',
        builder: (context, state) => ChatScreen(
          chatId: state.extra as String,
        ),
      ),
      GoRoute(
        path: '/chat-list',
        builder: (context, state) => const ChatListScreen(),
      ),
      GoRoute(
        path: '/saved-searches',
        builder: (context, state) => const SavedSearchesScreen(),
      ),
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: '/ratings',
        builder: (context, state) => const RatingsScreen(),
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
        path: '/verification',
        builder: (context, state) => const VerificationCenterScreen(),
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error: ${state.error}'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/login'),
              child: const Text('Go to Login'),
            ),
          ],
        ),
      ),
    ),
  );
});

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _checkAuth();
    });
  }

  Future<void> _checkAuth() async {
    await ref.read(authNotifierProvider.notifier).checkAuthStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.local_shipping,
              size: 100,
              color: Color(0xFF3B82F6),
            ),
            const SizedBox(height: 24),
            Text(
              'Transfort',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: const Color(0xFF3B82F6),
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    _subscription = stream.listen((_) {
      notifyListeners();
    });
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authNotifierProvider).user;
    final isSupplier = user?.isSupplierEnabled ?? false;
    final isTrucker = user?.isTruckerEnabled ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).logout();
              if (context.mounted) {
                context.go('/login');
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
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
            ),
          ),
          const Positioned(
            top: -140,
            right: -120,
            child: _GlowOrb(
              size: 280,
              color: AppColors.cyanGlowStrong,
            ),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(
              size: 320,
              color: AppColors.primary,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppDimensions.lg),
            child: user == null
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    children: [
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppDimensions.lg),
                        showGlow: true,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            GradientText(
                              'Welcome back!',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: AppDimensions.xs),
                            Text(
                              '${user.countryCode} ${user.mobileNumber}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppDimensions.lg),
                      if (isSupplier) ...[
                        GlassmorphicButton(
                          variant: GlassmorphicButtonVariant.primary,
                          onPressed: () => context.go('/feed'),
                          child: const Text('View My Loads'),
                        ),
                        const SizedBox(height: AppDimensions.sm),
                        GlassmorphicButton(
                          showGlow: false,
                          onPressed: () => context.go('/post-load-step1'),
                          child: const Text('Post New Load'),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                      ],
                      if (isTrucker) ...[
                        GlassmorphicButton(
                          variant: GlassmorphicButtonVariant.primary,
                          onPressed: () => context.go('/feed'),
                          child: const Text('Find Loads'),
                        ),
                        const SizedBox(height: AppDimensions.lg),
                      ],
                      GlassmorphicCard(
                        padding: const EdgeInsets.all(AppDimensions.md),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.info_outline,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: AppDimensions.sm),
                            Expanded(
                              child: Text(
                                'Load management is now live in mock mode. Start by posting or browsing loads.',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.construction,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
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
            ),
          ),
          const Positioned(
            top: -140,
            right: -120,
            child: _GlowOrb(
              size: 280,
              color: AppColors.cyanGlowStrong,
            ),
          ),
          const Positioned(
            bottom: -160,
            left: -140,
            child: _GlowOrb(
              size: 320,
              color: AppColors.primary,
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.all(AppDimensions.lg),
              child: GlassmorphicCard(
                padding: const EdgeInsets.all(AppDimensions.lg),
                showGlow: true,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 64, color: AppColors.primary),
                    const SizedBox(height: AppDimensions.md),
                    GradientText(
                      title,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppDimensions.sm),
                    Text(
                      message,
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
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowOrb({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color.withAlpha((0.35 * 255).round()),
              color.withAlpha(0),
            ],
          ),
        ),
      ),
    );
  }
}
