import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Hive box storing adapter registration metadata.
const String adapterRegistryBoxName = 'app.adapter_registry';

/// Registry key used for capture inbox adapter registration diagnostics.
const String captureAdapterRegistryKey = 'features.ingest.capture_items';

/// Status value written when an adapter registration succeeds.
const String adapterRegistrationStatusRegistered = 'registered';

/// Generates a registration metadata record for the adapter registry.
Map<String, Object?> createAdapterRegistrationMetadata({
  Map<String, Object?> extras = const <String, Object?>{},
}) {
  return <String, Object?>{
    'status': adapterRegistrationStatusRegistered,
    'timestamp': DateTime.now().toUtc().toIso8601String(),
    ...extras,
  };
}

/// Builds the Hive adapter registrar responsible for wiring feature adapters.
HiveAdapterRegistrar appHiveAdapterRegistrar(Ref ref) {
  final initializer = ref.watch(hiveInitializerProvider);

  return () async {
    await registerCaptureItemHiveAdapter();
    final registryBox =
        await initializer.openEncryptedBox<Map<dynamic, dynamic>>(
          adapterRegistryBoxName,
        );
    await registryBox.put(
      captureAdapterRegistryKey,
      createAdapterRegistrationMetadata(
        extras: <String, Object?>{
          'box': captureItemsBoxName,
          'adapter': 'CaptureItemHiveModel',
        },
      ),
    );

    await initializer.openEncryptedBox<CaptureItemHiveModel>(
      captureItemsBoxName,
    );
  };
}
