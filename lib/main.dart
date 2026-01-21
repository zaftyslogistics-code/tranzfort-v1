import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
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
import 'features/auth/data/datasources/mock_auth_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    if (kIsWeb) {
      try {
        await dotenv.load(fileName: 'assets/env/production.env');
        Logger.info('Loaded assets/env/production.env file');
      } catch (e) {
        try {
          await dotenv.load(fileName: 'assets/env/staging.env');
          Logger.info('Loaded assets/env/staging.env file');
        } catch (e2) {
          try {
            await dotenv.load(fileName: 'assets/env/local.env');
            Logger.info('Loaded assets/env/local.env file');
          } catch (e3) {
            // Fallback if no env assets are present
            Logger.warning('No env assets found, using fallback configuration');
            dotenv.env.addAll({
              'ENVIRONMENT': 'production',
              'SUPABASE_URL': 'https://your-production-project.supabase.co',
              'SUPABASE_ANON_KEY': 'your_production_anon_key',
              'USE_MOCK_AUTH': 'false',
              'USE_MOCK_LOADS': 'false',
              'USE_MOCK_CHAT': 'false',
              'ENABLE_ANALYTICS': 'true',
              'API_TIMEOUT': '30000',
            });
          }
        }
      }
    } else {
      try {
        await dotenv.load(fileName: '.env');
        Logger.info('Loaded .env file');
      } catch (e) {
        try {
          await dotenv.load(fileName: '.env.production');
          Logger.info('Loaded .env.production file');
        } catch (e2) {
          try {
            await dotenv.load(fileName: '.env.local');
            Logger.info('Loaded .env.local file');
          } catch (e3) {
            try {
              await dotenv.load(fileName: 'assets/env/production.env');
              Logger.info('Loaded assets/env/production.env file');
            } catch (e4) {
              try {
                await dotenv.load(fileName: 'assets/env/staging.env');
                Logger.info('Loaded assets/env/staging.env file');
              } catch (e5) {
                try {
                  await dotenv.load(fileName: 'assets/env/local.env');
                  Logger.info('Loaded assets/env/local.env file');
                } catch (e6) {
                  Logger.warning('No env files found, using fallback configuration');
                  dotenv.env.addAll({
                    'ENVIRONMENT': 'production',
                    'SUPABASE_URL': 'https://your-production-project.supabase.co',
                    'SUPABASE_ANON_KEY': 'your_production_anon_key',
                    'USE_MOCK_AUTH': 'false',
                    'USE_MOCK_LOADS': 'false',
                    'USE_MOCK_CHAT': 'false',
                    'ENABLE_ANALYTICS': 'true',
                    'API_TIMEOUT': '30000',
                  });
                }
              }
            }
          }
        }
      }
    }
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

    // Clear mock data in development mode for fresh testing
    if (EnvConfig.isLocal) {
      try {
        final mockAuth = MockAuthDataSource(sharedPreferences);
        await mockAuth.clearMockData();
        Logger.info('🧹 Mock data cleared for fresh testing');
      } catch (e) {
        Logger.error('Failed to clear mock data', error: e);
      }
    }

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
