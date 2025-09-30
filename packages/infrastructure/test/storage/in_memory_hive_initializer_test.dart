// Covers the in-memory Hive stub used during Milestone 3 as noted in
// `docs/project/progress.md` until the real adapter is implemented.
import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:test/test.dart';

void main() {
  group('InMemoryHiveInitializer', () {
    const boxName = 'capture_items';
    late InMemoryHiveInitializer initializer;

    setUp(() {
      initializer = InMemoryHiveInitializer();
    });

    test('initializes only once and returns consistent box handles', () async {
      // Arrange
      await initializer.initialize();
      await initializer.initialize();

      // Act
      final boxA = await initializer.openEncryptedBox<String>(boxName);
      final boxB = await initializer.openEncryptedBox<String>(boxName);
      await boxA.put('item-1', 'First');
      final firstFromB = await boxB.get('item-1');
      final valuesAfterPut = await boxA.values();
      await boxB.clear();
      final valuesAfterClear = await boxA.values();

      // Assert
      expect(boxA, same(boxB));
      expect(firstFromB, equals('First'));
      expect(valuesAfterPut, contains('First'));
      expect(valuesAfterClear, isEmpty);
    });

    test('wraps missing keys with InfrastructureFailure', () async {
      // Arrange
      await initializer.initialize();

      // Act
      final box = await initializer.openEncryptedBox<String>(boxName);

      // Assert
      expect(
        () => box.require('missing'),
        throwsA(isA<InfrastructureFailure>()),
      );
    });
  });
}
