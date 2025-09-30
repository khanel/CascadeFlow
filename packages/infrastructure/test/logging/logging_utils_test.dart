import 'dart:async';

import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:test/test.dart';

void main() {
  group('runWithLogging', () {
    test('logs uncaught errors with provided logger', () async {
      // Arrange
      final logLines = <String>[];
      final logger = PrintLogger(printer: logLines.add);

      // Act
      await expectLater(
        () => runWithLogging<void>(
          logger: logger,
          body: () {
            throw StateError('boom');
          },
        ),
        throwsA(isA<StateError>()),
      );

      // Assert
      expect(
        logLines.single,
        contains('[ERROR] Uncaught zone error: StateError: boom'),
      );
    });

    test('delegates to custom error handler after logging', () async {
      // Arrange
      Object? capturedError;
      StackTrace? capturedStackTrace;
      final logger = PrintLogger(printer: (_) {});

      // Act
      try {
        await runWithLogging<void>(
          logger: logger,
          body: () {
            throw StateError('boom');
          },
          onError: (error, stackTrace) {
            capturedError = error;
            capturedStackTrace = stackTrace;
          },
        );
        fail('Expected runWithLogging to rethrow the error');
      } on StateError {
        // Expected path.
      }

      // Assert
      expect(capturedError, isA<StateError>());
      expect(capturedStackTrace, isNotNull);
    });
  });
}
