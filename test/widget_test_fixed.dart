import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:transfort_app/shared/widgets/glassmorphic_button.dart';
import 'package:transfort_app/shared/widgets/glassmorphic_card.dart';
import 'package:transfort_app/core/theme/app_theme.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('GlassmorphicButton renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GlassmorphicButton(
              variant: GlassmorphicButtonVariant.primary,
              onPressed: () {},
              child: const Text('Test Button'),
            ),
          ),
        ),
      );

      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(GlassmorphicButton), findsOneWidget);
    });

    testWidgets('GlassmorphicCard renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GlassmorphicCard(
              padding: const EdgeInsets.all(16),
              child: const Text('Test Card'),
            ),
          ),
        ),
      );

      expect(find.text('Test Card'), findsOneWidget);
      expect(find.byType(GlassmorphicCard), findsOneWidget);
    });

    testWidgets('Button tap works correctly', (WidgetTester tester) async {
      bool wasTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GlassmorphicButton(
              variant: GlassmorphicButtonVariant.primary,
              onPressed: () {
                wasTapped = true;
              },
              child: const Text('Tap Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GlassmorphicButton));
      await tester.pump();

      expect(wasTapped, isTrue);
    });

    testWidgets('Button disabled state works', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(
            body: GlassmorphicButton(
              variant: GlassmorphicButtonVariant.primary,
              onPressed: null, // Disabled button
              child: const Text('Disabled Button'),
            ),
          ),
        ),
      );

      expect(find.byType(GlassmorphicButton), findsOneWidget);
      expect(find.text('Disabled Button'), findsOneWidget);
    });
  });
}
