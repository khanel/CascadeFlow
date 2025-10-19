/// Minimal logger that writes lines to stdout, intended for early development.
class PrintLogger {
  /// Creates a logger that writes to [printer] (defaults to `print`).
  const PrintLogger({void Function(String line)? printer})
    : _printer = printer ?? print;

  final void Function(String line) _printer;

  /// Logs a verbose diagnostic [message].
  void debug(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_LogLevel.debug, message, error: error, stackTrace: stackTrace);
  }

  /// Logs informational [message]s for high-level progress.
  void info(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_LogLevel.info, message, error: error, stackTrace: stackTrace);
  }

  /// Logs warnings that deserve attention but are non-fatal.
  void warning(String message, {Object? error, StackTrace? stackTrace}) {
    _log(_LogLevel.warning, message, error: error, stackTrace: stackTrace);
  }

  /// Logs errors and optional [stackTrace] details.
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
