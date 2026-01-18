import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'core/config/env_config.dart';
import 'core/config/app_config.dart';
import 'core/theme/app_theme.dart';
import 'core/utils/logger.dart';
import 'core/router/app_router.dart';
import 'core/services/ad_service.dart';
import 'core/services/offline_cache_service.dart';
import 'features/auth/presentation/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: '.env.local');
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
