import 'dart:async';

import 'print_logger.dart';

Future<T> runWithLogging<T>({
  required PrintLogger logger,
  required FutureOr<T> Function() body,
  void Function(Object error, StackTrace stackTrace)? onError,
}) async {
  try {
    return await Future<T>.sync(body);
  } catch (error, stackTrace) {
    final description = _describeError(error);
    logger.error(
      'Uncaught zone error: $description',
      stackTrace: stackTrace,
    );
    onError?.call(error, stackTrace);
    rethrow;
  }
}

String _describeError(Object error) {
  if (error is StateError) {
    return 'StateError: ${error.message}';
  }
  if (error is ArgumentError) {
    return 'ArgumentError: ${error.message}';
  }
  if (error is AssertionError && error.message != null) {
    return 'AssertionError: ${error.message}';
  }
  if (error is FormatException) {
    return 'FormatException: ${error.message}';
  }

  final typeName = error.runtimeType.toString();
  final errorString = error.toString();
  return errorString.startsWith(typeName)
      ? errorString
      : '$typeName: $errorString';
}
