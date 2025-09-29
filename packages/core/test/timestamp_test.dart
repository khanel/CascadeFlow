import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:test/test.dart';

void main() {
  group('Timestamp', () {
    test('normalizes to UTC', () {
      // Act
      final local = Timestamp(DateTime(2025, 1, 1, 12));

      // Assert
      expect(local.value.isUtc, isTrue);
    });

    test('difference compares underlying values', () {
      // Arrange
      final earlier = Timestamp(DateTime.utc(2025, 1, 1, 10));
      final later = Timestamp(DateTime.utc(2025, 1, 1, 12));

      // Assert
      expect(later.difference(earlier), const Duration(hours: 2));
      expect(later.isAfter(earlier), isTrue);
      expect(earlier.isBefore(later), isTrue);
    });
  });
}
