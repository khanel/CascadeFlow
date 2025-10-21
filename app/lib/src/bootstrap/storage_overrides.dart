import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:flutter/foundation.dart';
// ignore: implementation_imports
import 'package:riverpod/src/framework.dart' show Override;

typedef HiveInitializerFactory = HiveInitializer Function();
typedef SecureStorageFactory = SecureStorage Function();

const Set<TargetPlatform> _persistentPlatforms = <TargetPlatform>{
  TargetPlatform.android,
  TargetPlatform.iOS,
  TargetPlatform.macOS,
  TargetPlatform.windows,
  TargetPlatform.linux,
};

List<Override> createStorageOverridesForPlatform({
  TargetPlatform? platformOverride,
  bool? isWebOverride,
  HiveInitializerFactory? persistentHiveInitializer,
  SecureStorageFactory? persistentSecureStorage,
}) {
  final platform = platformOverride ?? defaultTargetPlatform;
  final isWeb = isWebOverride ?? kIsWeb;
  final usePersistentStorage = !isWeb && _persistentPlatforms.contains(
    platform,
  );

  final hiveInitializer = usePersistentStorage
      ? (persistentHiveInitializer?.call() ?? RealHiveInitializer())
      : InMemoryHiveInitializer();

  final secureStorage = usePersistentStorage
      ? (persistentSecureStorage?.call() ?? FlutterSecureStorageAdapter())
      : InMemorySecureStorage();

  return <Override>[
    hiveInitializerProvider.overrideWithValue(hiveInitializer),
    secureStorageProvider.overrideWithValue(secureStorage),
  ];
}
