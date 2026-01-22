import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/app_colors.dart';
import 'core/utils/logger.dart';
import 'core/router/app_router.dart';
import 'core/services/ad_service.dart';
import 'core/services/offline_cache_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up error boundary for production
  ErrorWidget.builder = (FlutterErrorDetails details) {
    // Log error for debugging
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
    // Load environment file based on compile-time constant
    // Usage: flutter run --dart-define=ENV_FILE=assets/env/local.env
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

    // Initialize AdMob
    await AdService().initialize();

    final sharedPreferences = await SharedPreferences.getInstance();
    Logger.info('SharedPreferences initialized');

    // Set up global error handling
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Restart app (not perfect, but better than crash)
                      runApp(
                        MaterialApp(
                          home: Scaffold(
                            body: const Center(
                              child: Text('Restarting...'),
                            ),
                          ),
                        ),
                      );
                      // In a real app, you'd use a proper restart mechanism
                    },
                    child: const Text('Restart App'),
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
        child: const TransfortApp(),
      ),
    );
  } catch (e, stackTrace) {
    Logger.error('App initialization failed', error: e);
    Logger.error('Stack trace', error: stackTrace);
    runApp(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Failed to initialize app: $e'),
          ),
        ),
      ),
    );
  }
}

class TransfortApp extends ConsumerWidget {
  const TransfortApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      routerConfig: router,
    );
  }
}
