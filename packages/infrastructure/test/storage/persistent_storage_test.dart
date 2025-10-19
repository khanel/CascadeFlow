import 'dart:io';

import 'package:cascade_flow_infrastructure/src/storage/hive_initializer.dart';
import 'package:cascade_flow_infrastructure/src/storage/real_hive_initializer.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Persistent Storage', () {
    late Directory tempDir;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp();
      PathProviderPlatform.instance = MockPathProviderPlatform(tempDir.path);
      FlutterSecureStorage.setMockInitialValues({});
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      await tempDir.delete(recursive: true);
    });

    test('data is persisted across different Hive instances', () async {
      // Arrange
      final initializer1 = RealHiveInitializer();
      await initializer1.initialize();
      final box1 = await initializer1.openEncryptedBox('testBox');
      await box1.put('key', 'value');
      await box1.close();

      // Act
      final initializer2 = RealHiveInitializer();
      await initializer2.initialize();
      final box2 = await initializer2.openEncryptedBox('testBox');
      final value = await box2.get('key');

      // Assert
      expect(value, 'value');
    });
  });
}

class MockPathProviderPlatform extends Fake
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {
  MockPathProviderPlatform(this.path);

  final String path;

  @override
  Future<String?> getApplicationDocumentsPath() async {
    return path;
  }
}
