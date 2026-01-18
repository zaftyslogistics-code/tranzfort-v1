import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Test helpers for widget and integration tests

/// Wraps a widget with MaterialApp and ProviderScope for testing
Widget createTestWidget(Widget child, {List<Override>? overrides}) {
  return ProviderScope(
    overrides: overrides ?? [],
    child: MaterialApp(
      home: child,
    ),
  );
}

/// Pumps a widget with MaterialApp and ProviderScope
Future<void> pumpTestWidget(
  WidgetTester tester,
  Widget child, {
  List<Override>? overrides,
}) async {
  await tester.pumpWidget(createTestWidget(child, overrides: overrides));
}

/// Waits for all animations and microtasks to complete
Future<void> pumpAndSettleWithDelay(
  WidgetTester tester, {
  Duration delay = const Duration(milliseconds: 100),
}) async {
  await tester.pumpAndSettle();
  await Future.delayed(delay);
  await tester.pump();
}

/// Finds a widget by its text content
Finder findTextWidget(String text) {
  return find.text(text);
}

/// Finds a widget by its key
Finder findByTestKey(String key) {
  return find.byKey(Key(key));
}

/// Taps a widget and waits for animations
Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Enters text into a text field and waits
Future<void> enterTextAndSettle(
  WidgetTester tester,
  Finder finder,
  String text,
) async {
  await tester.enterText(finder, text);
  await tester.pumpAndSettle();
}

/// Scrolls until a widget is visible
Future<void> scrollUntilVisible(
  WidgetTester tester,
  Finder finder,
  Finder scrollable, {
  double delta = 100.0,
}) async {
  await tester.scrollUntilVisible(
    finder,
    delta,
    scrollable: scrollable,
  );
}

/// Verifies that a widget exists
void expectWidgetExists(Finder finder) {
  expect(finder, findsOneWidget);
}

/// Verifies that a widget does not exist
void expectWidgetDoesNotExist(Finder finder) {
  expect(finder, findsNothing);
}

/// Verifies that multiple widgets exist
void expectWidgetsExist(Finder finder, int count) {
  expect(finder, findsNWidgets(count));
}

/// Mock delay for simulating async operations
Future<void> mockDelay([Duration duration = const Duration(milliseconds: 100)]) {
  return Future.delayed(duration);
}

/// Creates a mock BuildContext for testing
BuildContext createMockContext(WidgetTester tester) {
  return tester.element(find.byType(MaterialApp));
}
