import 'dart:io';

import 'package:cascade_flow_app/src/bootstrap/storage_overrides.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:riverpod/riverpod.dart';

class _TestPathProvider extends Fake with MockPlatformInterfaceMixin
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

    Future<void> _expectPersistentStorage(TargetPlatform platform) async {
      debugDefaultTargetPlatformOverride = platform;
      FlutterSecureStorage.setMockInitialValues({});

      final tempDir = await Directory.systemTemp.createTemp();
      PathProviderPlatform.instance = _TestPathProvider(tempDir.path);

      final container = ProviderContainer(
        overrides: createStorageOverridesForPlatform(),
      );

      final initializer = container.read(hiveInitializerProvider);
      final secureStorage = container.read(secureStorageProvider);

      expect(initializer, isA<RealHiveInitializer>());
      expect(secureStorage, isA<SecureStorage>());
      expect(secureStorage, isNot(isA<InMemorySecureStorage>()));

      container.dispose();
      await tempDir.delete(recursive: true);
    }

    test('uses persistent storage on Android', () async {
      await _expectPersistentStorage(TargetPlatform.android);
    });

    test('uses persistent storage on iOS', () async {
      await _expectPersistentStorage(TargetPlatform.iOS);
    });

    test('uses persistent storage on macOS', () async {
      await _expectPersistentStorage(TargetPlatform.macOS);
    });

    test('uses persistent storage on Windows', () async {
      await _expectPersistentStorage(TargetPlatform.windows);
    });

    test('uses persistent storage on Linux', () async {
      await _expectPersistentStorage(TargetPlatform.linux);
    });

    test('persists data across container restarts on Android', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FlutterSecureStorage.setMockInitialValues({});

      final tempDir = await Directory.systemTemp.createTemp();
      PathProviderPlatform.instance = _TestPathProvider(tempDir.path);

      final firstContainer = ProviderContainer(
        overrides: createStorageOverridesForPlatform(),
      );
      final firstInitializer = firstContainer.read(hiveInitializerProvider);
      await firstInitializer.initialize();
      final box = await firstInitializer.openEncryptedBox<String>('test.box');
      await box.put('persisted', 'value');
      await box.close();
      firstContainer.dispose();

      final secondContainer = ProviderContainer(
        overrides: createStorageOverridesForPlatform(),
      );
      final secondInitializer = secondContainer.read(hiveInitializerProvider);
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
      await tempDir.delete(recursive: true);
    });

    test('falls back to in-memory storage on web', () async {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      FlutterSecureStorage.setMockInitialValues({});

      final container = ProviderContainer(
        overrides: createStorageOverridesForPlatform(isWebOverride: true),
      );

      expect(
        container.read(hiveInitializerProvider),
        isA<InMemoryHiveInitializer>(),
      );
      expect(container.read(secureStorageProvider), isA<InMemorySecureStorage>());

      container.dispose();
    });
  });
}
