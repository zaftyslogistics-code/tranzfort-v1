import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/config/env_config.dart';
import 'core/theme/app_colors.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_mode_provider.dart';
import 'core/utils/logger.dart';
import 'core/router/admin_app_router.dart';
import 'core/services/analytics_service.dart';
import 'core/services/offline_cache_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) {
    Logger.error('Widget error caught by error boundary',
        error: details.exception, stackTrace: details.stack);

    return MaterialApp(
      home: Scaffold(
        backgroundColor: AppColors.darkBackground,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 64, color: AppColors.danger),
                const SizedBox(height: 16),
                const Text(
                  'Something went wrong',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please restart the app. If the problem persists, contact support.',
                  style: TextStyle(color: AppColors.textSecondary),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  };

  try {
    const String envFile = String.fromEnvironment(
      'ENV_FILE',
      defaultValue: 'assets/env/production.env',
    );
    await dotenv.load(fileName: envFile);
    Logger.info('Loaded $envFile file');
    Logger.info('Environment loaded: ${EnvConfig.environment}');

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: EnvConfig.isLocal,
    );
    Logger.info('Supabase initialized');

    await OfflineCacheService().init();

    if (EnvConfig.enableAnalytics) {
      Logger.info('🔧 Initializing analytics service...');
      try {
        await AnalyticsService().initialize(
          userId: Supabase.instance.client.auth.currentUser?.id,
        );
        Logger.info('✅ Analytics service initialized successfully');
      } catch (e) {
        Logger.error('❌ Analytics service initialization failed', error: e);
        // Continue without analytics - don't block app startup
      }
    }

    final sharedPreferences = await SharedPreferences.getInstance();
    Logger.info('SharedPreferences initialized');
    
    // Check current auth state before starting app
    final currentUser = Supabase.instance.client.auth.currentUser;
    Logger.info('🔍 Current auth state: ${currentUser != null ? "authenticated as ${currentUser.id}" : "not authenticated"}');

    ErrorWidget.builder = (FlutterErrorDetails details) {
      Logger.error('Flutter Error', error: details.exception);
      Logger.error('Stack trace', error: details.stack);

      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AppColors.danger,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Oops! Something went wrong',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Please restart the app. If the problem persists, contact support.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    };

    runApp(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
        ],
        child: const TransfortAdminApp(),
      ),
    );
  } catch (e, stackTrace) {
    Logger.error('Admin app initialization failed', error: e);
    Logger.error('Stack trace', error: stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize admin app: $e'),
          ),
        ),
      ),
    );
  }
}

class TransfortAdminApp extends ConsumerWidget {
  const TransfortAdminApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(adminRouterProvider);
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp.router(
      title: 'Transfort Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: router,
    );
  }
}
