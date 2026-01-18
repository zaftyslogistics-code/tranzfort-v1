import 'dart:async';

Future<T> retry<T>(
  Future<T> Function() action, {
  int retries = 3,
  Duration initialDelay = const Duration(milliseconds: 300),
  double backoffFactor = 2.0,
  bool Function(Object error)? shouldRetry,
}) async {
  var attempt = 0;
  var delay = initialDelay;

  while (true) {
    attempt++;
    try {
      return await action();
    } catch (e) {
      final canRetry = attempt <= retries && (shouldRetry?.call(e) ?? true);
      if (!canRetry) rethrow;
      await Future.delayed(delay);
      delay = Duration(milliseconds: (delay.inMilliseconds * backoffFactor).round());
    }
  }
}
