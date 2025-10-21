import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter/foundation.dart';
// Riverpod currently exposes `Override` only from its internal framework
// library. Once a public export becomes available we can drop this import.
// ignore: implementation_imports
import 'package:riverpod/src/framework.dart' show Override;

/// Factory signature for creating a [HiveInitializer].
typedef HiveInitializerFactory = HiveInitializer Function();

/// Factory signature for creating a [SecureStorage].
typedef SecureStorageFactory = SecureStorage Function();

const Set<TargetPlatform> _persistentPlatforms = <TargetPlatform>{
  TargetPlatform.android,
  TargetPlatform.iOS,
  TargetPlatform.macOS,
  TargetPlatform.windows,
  TargetPlatform.linux,
};

/// Determines whether persistent storage should be used for the given
/// [platform] / [isWeb] combination.
bool _shouldUsePersistentStorage({
  required TargetPlatform platform,
  required bool isWeb,
}) => !isWeb && _persistentPlatforms.contains(platform);

/// Builds the storage overrides appropriate for the current platform.
List<Override> createStorageOverridesForPlatform({
  TargetPlatform? platformOverride,
  bool? isWebOverride,
  HiveInitializerFactory? persistentHiveInitializer,
  SecureStorageFactory? persistentSecureStorage,
}) {
  final platform = platformOverride ?? defaultTargetPlatform;
  final isWeb = isWebOverride ?? kIsWeb;
  final usePersistentStorage = _shouldUsePersistentStorage(
    platform: platform,
    isWeb: isWeb,
  );

  final hiveInitializer = usePersistentStorage
      ? (persistentHiveInitializer ?? RealHiveInitializer.new)()
      : InMemoryHiveInitializer();

  final secureStorage = usePersistentStorage
      ? (persistentSecureStorage ?? FlutterSecureStorageAdapter.new)()
      : InMemorySecureStorage();

  return <Override>[
    hiveInitializerProvider.overrideWithValue(hiveInitializer),
    secureStorageProvider.overrideWithValue(secureStorage),
  ];
}
