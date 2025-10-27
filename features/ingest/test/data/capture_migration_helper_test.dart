import 'package:cascade_flow_ingest/data/capture_migration_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureMigrationHelper', () {
    test('can be instantiated', () {
      // Act
      final strategy = CaptureMigrationHelper();

      // Assert
      expect(strategy, isNotNull);
    });
  });
}
