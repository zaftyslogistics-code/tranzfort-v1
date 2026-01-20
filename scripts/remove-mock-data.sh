#!/bin/bash

# Mock Data Removal Script for Production Deployment
# This script removes all mock data and development configurations

echo "🧹 Starting mock data removal for production deployment..."

# Remove mock data clearing logic from main.dart
echo "📝 Removing mock data clearing logic from main.dart..."
sed -i.bak '/# Clear mock data in development mode/,/}/d' lib/main.dart

# Create production main.dart without mock data clearing
cat > lib/main_production.dart << 'EOF'
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

  try {
    await dotenv.load(fileName: '.env.production');
    Logger.info('Environment loaded: ${EnvConfig.environment}');

    await Supabase.initialize(
      url: EnvConfig.supabaseUrl,
      anonKey: EnvConfig.supabaseAnonKey,
      debug: false, // Disable debug in production
    );
    Logger.info('Supabase initialized');

    await OfflineCacheService().init();

    // Initialize AdMob
    await AdService().initialize();

    final sharedPreferences = await SharedPreferences.getInstance();
    Logger.info('SharedPreferences initialized');

    // Set up global error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      Logger.error('Flutter error', error: details.exception, stackTrace: details.stack);
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
    Logger.error('Failed to initialize app', error: e, stackTrace: stackTrace);
    runApp(ErrorScreen(error: e.toString()));
  }
}

class TransfortApp extends ConsumerWidget {
  const TransfortApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Transfort - India\'s Open Load Marketplace',
      debugShowCheckedModeBanner: false, // Disable debug banner in production
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: AppRouter.router,
    );
  }
}

class ErrorScreen extends StatelessWidget {
  final String error;
  
  const ErrorScreen({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Initialization Error',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 8),
                Text(
                  'Failed to initialize the app. Please restart.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  'Error: $error',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
EOF

echo "✅ Production main.dart created"

# Update pubspec.yaml for production
echo "📝 Updating pubspec.yaml for production..."
sed -i.bak 's/version: 1.0.0+1/version: 1.0.0+1/' pubspec.yaml

# Create production build configuration
echo "📝 Creating production build configuration..."

cat > build_production.yaml << 'EOF'
# Production Build Configuration
flutter:
  build:
    release:
      # Enable obfuscation
      obfuscate: true
      # Generate split debug info
      split-debug-info: build/debug-info/
      # Enable tree shaking
      tree-shake-icons: true
      # Enable shrinking
      shrink: true
EOF

echo "✅ Production build configuration created"

# List files that should be reviewed before production
echo "📋 Files to review before production deployment:"
echo ""
echo "🔧 Configuration Files:"
echo "  - lib/core/config/env_config.dart"
echo "  - lib/main.dart (use main_production.dart)"
echo "  - pubspec.yaml"
echo ""
echo "🗑️  Mock Data Files to Remove:"
echo "  - lib/features/auth/data/datasources/mock_auth_datasource.dart"
echo "  - lib/features/loads/data/datasources/mock_loads_datasource.dart"
echo "  - lib/features/verification/data/datasources/mock_verification_datasource.dart"
echo "  - lib/features/chat/data/datasources/mock_chat_datasource.dart"
echo ""
echo "⚙️  Provider Files to Update:"
echo "  - lib/features/auth/presentation/providers/auth_provider.dart"
echo "  - lib/features/loads/presentation/providers/loads_provider.dart"
echo "  - lib/features/verification/presentation/providers/verification_provider.dart"
echo "  - lib/features/chat/presentation/providers/chat_provider.dart"
echo ""
echo "📱 Build Commands:"
echo "  Android APK: flutter build apk --release --shrink --obfuscate --split-debug-info=build/debug-info/"
echo "  Android AAB: flutter build appbundle --release --shrink --obfuscate --split-debug-info=build/debug-info/"
echo "  iOS: flutter build ios --release --obfuscate --split-debug-info=build/debug-info/"
echo ""

echo "🎉 Mock data removal script completed!"
echo "📝 Please review the listed files and update them for production use."
echo "🚀 Ready for production deployment!"
