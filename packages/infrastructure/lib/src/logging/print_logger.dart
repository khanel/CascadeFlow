class PrintLogger {
  const PrintLogger({void Function(String line)? printer})
      : _printer = printer ?? print;

  final void Function(String line) _printer;

  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  void error(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_LogLevel.error, message, error: error, stackTrace: stackTrace);
  }

  void _log(
    _LogLevel level,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final buffer = StringBuffer('[${level.label}] $message');

    if (error != null) {
      buffer.write(' | error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n$stackTrace');
    }

    // Using `print` keeps the stub simple while tests can intercept the output.
    _printer(buffer.toString());
  }
}

enum _LogLevel {
  debug('DEBUG'),
  info('INFO'),
  warning('WARNING'),
  error('ERROR');

  const _LogLevel(this.label);

  final String label;
}
