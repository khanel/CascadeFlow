// Ensures the temporary secure storage stub lines up with the roadmap state in
// `docs/project/progress.md` while native integrations are pending.
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:riverpod/riverpod.dart';
import 'package:test/test.dart';

void main() {
  group('InMemorySecureStorage', () {
    const tokenKey = 'token';
    const refreshKey = 'refresh';

    test('writes, reads, deletes, and clears values', () async {
      // Arrange
      final storage = InMemorySecureStorage();

      // Act
      await storage.write(key: tokenKey, value: 'abc123');
      await storage.write(key: refreshKey, value: 'def456');
      final tokenAfterWrite = await storage.read(key: tokenKey);
      final refreshAfterWrite = await storage.read(key: refreshKey);
      await storage.delete(key: tokenKey);
      final tokenAfterDelete = await storage.read(key: tokenKey);
      await storage.clear();
      final refreshAfterClear = await storage.read(key: refreshKey);

      // Assert
      expect(tokenAfterWrite, equals('abc123'));
      expect(refreshAfterWrite, equals('def456'));
      expect(tokenAfterDelete, isNull);
      expect(refreshAfterClear, isNull);
    });
  });

  group('secureStorageProvider', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('resolves to in-memory implementation', () {
      // Arrange
      final read = container.read;

      // Act
      final storage = read(secureStorageProvider);

      // Assert
      expect(storage, isA<InMemorySecureStorage>());
    });
  });
}
