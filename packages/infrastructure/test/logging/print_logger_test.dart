// Validates the placeholder logger behaviour described in
// `docs/project/progress.md`
// while infrastructure services are still stubs for Milestone 3.
import 'dart:async';

import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:test/test.dart';

void main() {
  group('PrintLogger', () {
    test('prefixes messages with their log level', () {
      // Arrange
      final logs = <String>[];

      // Act
      runZoned(
        () {
          const logger = PrintLogger();
          logger
            ..debug('debug message')
            ..info('info message')
            ..warning('warn message')
            ..error('error message', error: Exception('boom'));
        },
        zoneSpecification: ZoneSpecification(
          print: (self, parent, zone, line) => logs.add(line),
        ),
      );

      // Assert
      expect(logs, hasLength(4));
      expect(logs[0], contains('[DEBUG] debug message'));
      expect(logs[3], contains('[ERROR] error message'));
    });
  });
}
