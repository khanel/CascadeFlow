import 'dart:async';

import 'package:cascade_flow_infrastructure/src/logging/print_logger.dart';

/// Runs [body] while ensuring uncaught errors are logged before being rethrown.
Future<T> runWithLogging<T>({
  required PrintLogger logger,
  required FutureOr<T> Function() body,
  LogErrorHandler? onError,
}) async {
  try {
    return await Future<T>.sync(body);
  } on Object catch (error, stackTrace) {
    _logUnhandledError(logger, error, stackTrace);
    onError?.call(error, stackTrace);
    rethrow;
  }
}

/// Callback invoked after the error has been logged.
typedef LogErrorHandler =
    void Function(
      Object error,
      StackTrace stackTrace,
    );

void _logUnhandledError(
  PrintLogger logger,
  Object error,
  StackTrace stackTrace,
) {
  logger.error(
    'Uncaught zone error: ${_describeError(error)}',
    stackTrace: stackTrace,
  );
}

String _describeError(Object error) => switch (error) {
  StateError(:final message) => 'StateError: $message',
  ArgumentError(:final message) => 'ArgumentError: $message',
  AssertionError(:final message?) => 'AssertionError: $message',
  AssertionError() => 'AssertionError',
  FormatException(:final message) => 'FormatException: $message',
  _ => _fallbackDescription(error),
};

String _fallbackDescription(Object error) {
  final typeName = error.runtimeType.toString();
  final errorString = error.toString();
  return errorString.startsWith(typeName)
      ? errorString
      : '$typeName: $errorString';
}
