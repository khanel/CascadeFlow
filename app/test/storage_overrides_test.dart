import 'dart:io';

import 'package:cascade_flow_app/src/bootstrap/storage_overrides.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class _TestPathProvider extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  _TestPathProvider(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async => path;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('createStorageOverridesForPlatform', () {
    final basePlatform = debugDefaultTargetPlatformOverride;
    final basePathProvider = PathProviderPlatform.instance;

    tearDown(() async {
      debugDefaultTargetPlatformOverride = basePlatform;
      PathProviderPlatform.instance = basePathProvider;
      await Hive.deleteFromDisk();
    });

    Future<void> withPersistentPlatform(
      TargetPlatform platform,
      Future<void> Function() runTest,
    ) async {
      debugDefaultTargetPlatformOverride = platform;
      final tempDir = await Directory.systemTemp.createTemp();
      final originalPathProvider = PathProviderPlatform.instance;
      PathProviderPlatform.instance = _TestPathProvider(tempDir.path);

      try {
        await runTest();
      } finally {
        PathProviderPlatform.instance = originalPathProvider;
        await tempDir.delete(recursive: true);
      }
    }

    Future<void> expectPersistentStorage(TargetPlatform platform) async {
      await withPersistentPlatform(platform, () async {
        final container = ProviderContainer(
          overrides: createStorageOverridesForPlatform(),
        );
        final initializer = container.read(hiveInitializerProvider);
        final secureStorage = container.read(secureStorageProvider);

        expect(initializer, isA<RealHiveInitializer>());
        expect(secureStorage, isA<SecureStorage>());
        expect(secureStorage, isNot(isA<InMemorySecureStorage>()));
        container.dispose();
      });
    }

    test('uses persistent storage on Android', () async {
      await expectPersistentStorage(TargetPlatform.android);
    });

    test('uses persistent storage on iOS', () async {
      await expectPersistentStorage(TargetPlatform.iOS);
    });

    test('uses persistent storage on macOS', () async {
      await expectPersistentStorage(TargetPlatform.macOS);
    });

    test('uses persistent storage on Windows', () async {
      await expectPersistentStorage(TargetPlatform.windows);
    });

    test('uses persistent storage on Linux', () async {
      await expectPersistentStorage(TargetPlatform.linux);
    });

    test('persists data across container restarts on Android', () async {
      await withPersistentPlatform(
        TargetPlatform.android,
        () async {
          final sharedSecureStorage = InMemorySecureStorage();
          final firstContainer = ProviderContainer(
            overrides: createStorageOverridesForPlatform(
              persistentHiveInitializer: () => RealHiveInitializer(
                sharedSecureStorage,
              ),
              persistentSecureStorage: () => sharedSecureStorage,
            ),
          );
          final firstInitializer = firstContainer.read(hiveInitializerProvider);
          await firstInitializer.initialize();
          final box = await firstInitializer.openEncryptedBox<String>(
            'test.box',
          );
          await box.put('persisted', 'value');
          await box.close();
          firstContainer.dispose();

          final secondContainer = ProviderContainer(
            overrides: createStorageOverridesForPlatform(
              persistentHiveInitializer: () => RealHiveInitializer(
                sharedSecureStorage,
              ),
              persistentSecureStorage: () => sharedSecureStorage,
            ),
          );
          final secondInitializer = secondContainer.read(
            hiveInitializerProvider,
          );
          await secondInitializer.initialize();
          final restoredBox = await secondInitializer.openEncryptedBox<String>(
            'test.box',
          );
          final restored = await restoredBox.get('persisted');

          expect(restored, 'value');
          await restoredBox.clear();
          await restoredBox.close();
          secondContainer.dispose();
          await Hive.deleteFromDisk();
        },
      );
    });

    test('falls back to in-memory storage on web', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final container = ProviderContainer(
        overrides: createStorageOverridesForPlatform(isWebOverride: true),
      );

      expect(
        container.read(hiveInitializerProvider),
        isA<InMemoryHiveInitializer>(),
      );
      expect(
        container.read(secureStorageProvider),
        isA<InMemorySecureStorage>(),
      );

      container.dispose();
    });
  });
}
