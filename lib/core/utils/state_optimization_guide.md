# State Management Optimization Guide

## Overview
This guide provides best practices for optimizing state management in the Transfort app using Riverpod.

## Key Principles

### 1. Use Selective Watching with `.select()`

**Bad:**
```dart
// Watches entire state, rebuilds on any change
final authState = ref.watch(authNotifierProvider);
```

**Good:**
```dart
// Only watches specific field, rebuilds only when that field changes
final user = ref.watch(authNotifierProvider.select((state) => state.user));
final isLoading = ref.watch(authNotifierProvider.select((state) => state.isLoading));
```

### 2. Avoid Watching Entire State Objects

**Bad:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final loadsState = ref.watch(loadsNotifierProvider); // Watches everything
  return Text('Count: ${loadsState.loads.length}');
}
```

**Good:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final loadCount = ref.watch(
    loadsNotifierProvider.select((state) => state.loads.length)
  );
  return Text('Count: $loadCount');
}
```

### 3. Use `ref.listen` for Side Effects

**Bad:**
```dart
Widget build(BuildContext context, WidgetRef ref) {
  final authState = ref.watch(authNotifierProvider);
  if (authState.error != null) {
    // This runs on every build!
    showSnackBar(authState.error);
  }
  return Container();
}
```

**Good:**
```dart
@override
Widget build(BuildContext context, WidgetRef ref) {
  ref.listen(authNotifierProvider, (previous, next) {
    if (next.error != null) {
      showSnackBar(next.error);
    }
  });
  return Container();
}
```

### 4. Use `ref.read` for One-Time Reads

**Bad:**
```dart
onPressed: () {
  final notifier = ref.watch(authNotifierProvider.notifier); // Creates dependency
  notifier.logout();
}
```

**Good:**
```dart
onPressed: () {
  ref.read(authNotifierProvider.notifier).logout(); // No dependency
}
```

### 5. Minimize Provider Scope

**Bad:**
```dart
// Global provider that rebuilds entire app
final appStateProvider = StateNotifierProvider<AppState, AppStateModel>((ref) {
  return AppState();
});
```

**Good:**
```dart
// Scoped providers for specific features
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

final loadsProvider = StateNotifierProvider<LoadsNotifier, LoadsState>((ref) {
  return LoadsNotifier(ref.read(loadsRepositoryProvider));
});
```

### 6. Use `family` for Parameterized Providers

**Bad:**
```dart
// Creates separate provider for each load
final loadProvider1 = FutureProvider((ref) => getLoad('id1'));
final loadProvider2 = FutureProvider((ref) => getLoad('id2'));
```

**Good:**
```dart
// Single provider family handles all loads
final loadProvider = FutureProvider.family<Load, String>((ref, id) {
  return ref.read(loadsRepositoryProvider).getLoad(id);
});

// Usage
final load = ref.watch(loadProvider('id1'));
```

### 7. Dispose Resources Properly

**Bad:**
```dart
class MyNotifier extends StateNotifier<MyState> {
  final StreamSubscription subscription;
  
  MyNotifier() : super(MyState()) {
    subscription = stream.listen((_) {});
  }
  // No disposal!
}
```

**Good:**
```dart
class MyNotifier extends StateNotifier<MyState> {
  final StreamSubscription subscription;
  
  MyNotifier() : super(MyState()) {
    subscription = stream.listen((_) {});
  }
  
  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
```

### 8. Use `autoDispose` for Temporary Data

**Bad:**
```dart
// Provider stays in memory forever
final searchResultsProvider = FutureProvider<List<Load>>((ref) {
  return searchLoads(query);
});
```

**Good:**
```dart
// Provider automatically disposed when no longer used
final searchResultsProvider = FutureProvider.autoDispose<List<Load>>((ref) {
  return searchLoads(query);
});
```

### 9. Batch State Updates

**Bad:**
```dart
void updateMultipleFields() {
  state = state.copyWith(field1: value1); // Rebuild
  state = state.copyWith(field2: value2); // Rebuild
  state = state.copyWith(field3: value3); // Rebuild
}
```

**Good:**
```dart
void updateMultipleFields() {
  state = state.copyWith(
    field1: value1,
    field2: value2,
    field3: value3,
  ); // Single rebuild
}
```

### 10. Use `keepAlive` Strategically

**Bad:**
```dart
// Keeps provider alive forever, even when not needed
final dataProvider = FutureProvider.autoDispose<Data>((ref) {
  ref.keepAlive();
  return fetchData();
});
```

**Good:**
```dart
// Keeps alive only while data is fresh
final dataProvider = FutureProvider.autoDispose<Data>((ref) {
  final link = ref.keepAlive();
  
  // Dispose after 5 minutes of inactivity
  Timer(const Duration(minutes: 5), link.close);
  
  return fetchData();
});
```

## Performance Checklist

- [ ] Use `.select()` to watch specific fields
- [ ] Avoid watching entire state objects
- [ ] Use `ref.listen` for side effects
- [ ] Use `ref.read` for one-time reads
- [ ] Minimize provider scope
- [ ] Use `family` for parameterized providers
- [ ] Dispose resources properly
- [ ] Use `autoDispose` for temporary data
- [ ] Batch state updates
- [ ] Use `keepAlive` strategically

## Common Patterns

### Loading States
```dart
final dataProvider = FutureProvider.autoDispose<Data>((ref) async {
  return await fetchData();
});

// In widget
final data = ref.watch(dataProvider);
return data.when(
  data: (value) => DataWidget(value),
  loading: () => LoadingWidget(),
  error: (error, stack) => ErrorWidget(error),
);
```

### Pagination
```dart
final paginatedDataProvider = StateNotifierProvider.autoDispose<PaginatedNotifier, PaginatedState>((ref) {
  return PaginatedNotifier();
});

// Only rebuild when page changes
final currentPage = ref.watch(
  paginatedDataProvider.select((state) => state.currentPage)
);
```

### Search with Debounce
```dart
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsProvider = FutureProvider.autoDispose<List<Result>>((ref) async {
  final query = ref.watch(searchQueryProvider);
  
  // Debounce
  await Future.delayed(const Duration(milliseconds: 500));
  
  // Cancel if query changed
  if (ref.state != const AsyncValue.loading()) {
    return ref.state.value ?? [];
  }
  
  return searchAPI(query);
});
```

## Monitoring Performance

Use Flutter DevTools to monitor:
- Widget rebuilds
- Provider updates
- Memory usage
- Frame rendering time

## Additional Resources

- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf)
- [State Management Guide](https://flutter.dev/docs/development/data-and-backend/state-mgmt)
