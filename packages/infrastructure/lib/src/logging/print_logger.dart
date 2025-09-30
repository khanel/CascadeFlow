class PrintLogger {
  const PrintLogger();

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log('DEBUG', message, error: error, stackTrace: stackTrace);
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log('INFO', message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log('WARNING', message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log('ERROR', message, error: error, stackTrace: stackTrace);
  }

  void _log(
    String level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer('[${level.toUpperCase()}] $message');

    if (error != null) {
      buffer.write(' | error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }

    // Using `print` keeps the stub simple while tests can intercept the output.
    print(buffer.toString());
  }
}
