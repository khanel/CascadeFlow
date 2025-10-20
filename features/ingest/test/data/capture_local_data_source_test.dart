import 'dart:io';

import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import '../test_utils/capture_test_data.dart';

class _RecordingInitializer extends InMemoryHiveInitializer {
  final List<String> openedBoxes = <String>[];
  bool initializeCalled = false;

  @override
  Future<void> initialize() {
    initializeCalled = true;
    return super.initialize();
  }

  @override
  Future<HiveBox<T>> openEncryptedBox<T>(String name) {
    openedBoxes.add(name);
    return super.openEncryptedBox<T>(name);
  }
}

class _TestPathProvider extends Fake with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _TestPathProvider(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

Future<T> _withPersistentStorageOverrides<T>(
  Future<T> Function() action,
) async {
  final tempDir = await Directory.systemTemp.createTemp(
    'capture_local_data_source_test_',
  );
  final originalPathProvider = PathProviderPlatform.instance;
  PathProviderPlatform.instance = _TestPathProvider(tempDir.path);
  FlutterSecureStorage.setMockInitialValues({});

  try {
    return await action();
  } finally {
    PathProviderPlatform.instance = originalPathProvider;
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await registerCaptureItemHiveAdapter();
  });

  test('warmUp initializes hive and opens capture inbox box', () async {
    // ARRANGE
    final initializer = _RecordingInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);

    // ACT
    await dataSource.warmUp();

    // ASSERT
    expect(initializer.initializeCalled, isTrue);
    expect(
      initializer.openedBoxes,
      contains(captureItemsBoxName),
    );
    expect(initializer.openedBoxes.length, equals(1));
  });

  test('save writes capture model and read returns stored entry', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final item = buildTestCaptureItem(
      id: 'capture-1',
      createdMicros: 100,
      updatedMicros: 100,
    );
    final model = CaptureItemHiveModel.fromDomain(item);

    // ACT
    await dataSource.save(model);
    final stored = await dataSource.read(model.id);

    // ASSERT
    expect(stored, isNotNull);
    expect(stored!.toDomain(), equals(item));
  });

  test('readAll returns models in insertion order '
      'with latest values', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final first = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'capture-a',
        createdMicros: 50,
      ),
    );
    final second = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'capture-b',
        createdMicros: 60,
      ),
    );

    // ACT
    await dataSource.save(first);
    await dataSource.save(second);
    final models = await dataSource.readAll();

    // ASSERT
    expect(models, hasLength(2));
    expect(models.first.id, first.id);
    expect(models.last.id, second.id);
  });

  test('delete removes stored capture model and ignores unknown ids', () async {
    // ARRANGE
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();
    final model = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'to-delete',
        createdMicros: 5,
        updatedMicros: 5,
      ),
    );
    await dataSource.save(model);

    // ACT
    await dataSource.delete(model.id);
    await dataSource.delete('missing-id');

    // ASSERT
    expect(await dataSource.read(model.id), isNull);
    final remaining = await dataSource.readAll();
    expect(remaining, isEmpty);
  });

  test('persists data across data source instances', () async {
    // ARRANGE - Save data with first instance
    await _withPersistentStorageOverrides(() async {
      final initializer = RealHiveInitializer();
      final firstDataSource = CaptureLocalDataSource(initializer: initializer);
      await firstDataSource.warmUp();
      final model = CaptureItemHiveModel.fromDomain(
        buildTestCaptureItem(
          id: 'persistent-item',
          createdMicros: 200,
          updatedMicros: 200,
        ),
      );
      await firstDataSource.save(model);

      // ACT - Try to read from new instance (simulating app restart)
      final secondDataSource = CaptureLocalDataSource(initializer: initializer);
      await secondDataSource.warmUp();
      final persistedItem = await secondDataSource.read(model.id);

      // ASSERT - Data persists with real Hive storage
      expect(persistedItem, isNotNull);
      expect(persistedItem!.toDomain(), equals(model.toDomain()));
    });
  });

  test(
    'ensures data persists after multiple initializer reinitializations',
    () async {
      // Regression test: ensure reinitialization doesn't lose data with real
      // storage
      await _withPersistentStorageOverrides(() async {
        final initializer1 = RealHiveInitializer();
        final dataSource1 = CaptureLocalDataSource(initializer: initializer1);
        await dataSource1.warmUp();

        final item = CaptureItemHiveModel.fromDomain(
          buildTestCaptureItem(
            id: 'multi-init-test',
            createdMicros: 1000,
            updatedMicros: 1000,
          ),
        );

        await dataSource1.save(item);

        // Simulate multiple app startup cycles with new initializers
        // (all accessing shared storage)
        for (var i = 1; i <= 3; i++) {
          final newInitializer = RealHiveInitializer();
          final newDataSource = CaptureLocalDataSource(
            initializer: newInitializer,
          );
          await newDataSource.warmUp();

          final persistedItem = await newDataSource.read(item.id);
          expect(
            persistedItem,
            isNotNull,
            reason: 'Item should persist across initialization #$i',
          );
          expect(persistedItem!.toDomain(), equals(item.toDomain()));
        }
      });
    },
  );

  test('handles concurrent access from multiple data sources', () async {
    // Simulate concurrent operations from different app components
    final initializer = InMemoryHiveInitializer();
    final dataSource1 = CaptureLocalDataSource(initializer: initializer);
    final dataSource2 = CaptureLocalDataSource(initializer: initializer);

    await Future.wait([dataSource1.warmUp(), dataSource2.warmUp()]);

    final item1 = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'concurrent-a',
        createdMicros: 100,
        updatedMicros: 100,
      ),
    );
    final item2 = CaptureItemHiveModel.fromDomain(
      buildTestCaptureItem(
        id: 'concurrent-b',
        createdMicros: 200,
        updatedMicros: 200,
      ),
    );

    // Save from different sources concurrently
    await Future.wait([
      dataSource1.save(item1),
      dataSource2.save(item2),
    ]);

    // Verify both items are readable from either source
    final results = await Future.wait([
      dataSource1.read(item2.id),
      dataSource2.read(item1.id),
      dataSource1.readAll(),
      dataSource2.readAll(),
    ]);

    final item2FromDataSource1 = results[0]! as CaptureItemHiveModel;
    final item1FromDataSource2 = results[1]! as CaptureItemHiveModel;

    expect(
      item2FromDataSource1.toDomain(),
      equals(item2.toDomain()),
    ); // item2 from dataSource1
    expect(
      item1FromDataSource2.toDomain(),
      equals(item1.toDomain()),
    ); // item1 from dataSource2
    expect(results[2], hasLength(2)); // dataSource1 sees both items
    expect(results[3], hasLength(2)); // dataSource2 sees both items
  });

  test('validates Hive model domain conversion roundtrip', () async {
    // Ensure serialization/deserialization preserves data integrity
    final originalItem = buildTestCaptureItem(
      id: 'roundtrip-test',
      channel: 'test-channel',
      createdMicros: 500,
      updatedMicros: 600,
      content: 'Test content with special chars: éññü',
      metadata: {'key1': 'value1', 'key2': 'true'},
    );

    // Convert to Hive model and back
    final hiveModel = CaptureItemHiveModel.fromDomain(originalItem);
    final roundtripItem = hiveModel.toDomain();

    // Verify all fields match
    expect(roundtripItem.id, equals(originalItem.id));
    expect(roundtripItem.content, equals(originalItem.content));
    expect(roundtripItem.status, equals(originalItem.status));
    expect(roundtripItem.createdAt, equals(originalItem.createdAt));
    expect(roundtripItem.updatedAt, equals(originalItem.updatedAt));
    expect(roundtripItem.archivedAt, equals(originalItem.archivedAt));
    expect(roundtripItem.context.source, equals(originalItem.context.source));
    expect(
      roundtripItem.context.channel,
      equals(originalItem.context.channel),
    );
    expect(roundtripItem.metadata, equals(originalItem.metadata));
  });

  test('maintains data consistency across multiple operations', () async {
    // Test that multiple CRUD operations maintain data integrity
    final initializer = InMemoryHiveInitializer();
    final dataSource = CaptureLocalDataSource(initializer: initializer);
    await dataSource.warmUp();

    // Create multiple items
    final items = List.generate(
      5,
      (index) => CaptureItemHiveModel.fromDomain(
        buildTestCaptureItem(
          id: 'consistency-$index',
          createdMicros: index * 100,
          updatedMicros: index * 100,
        ),
      ),
    );

    // Save all items
    for (final item in items) {
      await dataSource.save(item);
    }

    // Verify all saved correctly
    final savedItems = await dataSource.readAll();
    expect(savedItems, hasLength(5));

    // Delete middle item
    await dataSource.delete('consistency-2');

    // Verify deletion worked
    final afterDelete = await dataSource.readAll();
    expect(afterDelete, hasLength(4));
    expect(
      afterDelete.map((m) => m.id).toList(),
      isNot(contains('consistency-2')),
    );

    // Verify remaining items are unchanged
    for (var i = 0; i < 5; i++) {
      if (i == 2) continue; // Skip deleted item
      final item = await dataSource.read('consistency-$i');
      expect(item, isNotNull);
      expect(item!.id, equals('consistency-$i'));
    }
  });
}
