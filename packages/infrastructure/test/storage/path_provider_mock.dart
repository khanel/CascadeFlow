import 'dart:io';

class MockPathProviderPlatform {
  Future<String> getTemporaryPath() async {
    final directory = await Directory.systemTemp.createTemp('hive_test_');
    return directory.path;
  }
}
