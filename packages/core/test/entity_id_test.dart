import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:test/test.dart';

void main() {
  group('EntityId', () {
    test('throws when empty', () {
      // Act & Assert
      expect(() => EntityId(''), throwsA(isA<ValidationFailure>()));
    });

    test('throws when contains unsupported characters', () {
      // Act & Assert
      expect(() => EntityId('abc def'), throwsA(isA<ValidationFailure>()));
    });

    test('supports equality by value', () {
      // Arrange
      final first = EntityId('abc123');
      final second = EntityId('abc123');

      // Assert
      expect(first, equals(second));
      expect(first.hashCode, equals(second.hashCode));
    });

    test('generate produces unique values', () {
      // Act
      final first = EntityId.generate();
      final second = EntityId.generate();

      // Assert
      expect(first, isNot(equals(second)));
      expect(first.value, hasLength(24));
      expect(second.value, hasLength(24));
    });
  });
}
