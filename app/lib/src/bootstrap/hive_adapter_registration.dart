import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:riverpod/riverpod.dart';

/// Hive box storing adapter registration metadata.
const String adapterRegistryBoxName = 'app.adapter_registry';

/// Registry key used for capture inbox adapter registration diagnostics.
const String captureAdapterRegistryKey = 'features.ingest.capture_items';

/// Builds the Hive adapter registrar responsible for wiring feature adapters.
HiveAdapterRegistrar appHiveAdapterRegistrar(Ref ref) {
  final initializer = ref.watch(hiveInitializerProvider);

  return () async {
    final registryBox =
        await initializer.openEncryptedBox<Map<String, Object?>>(
          adapterRegistryBoxName,
        );
    await registryBox.put(
      captureAdapterRegistryKey,
      <String, Object?>{
        'box': captureItemsBoxName,
        'adapter': 'CaptureItemHiveModel',
        'status': 'registered',
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      },
    );

    await initializer.openEncryptedBox<CaptureItemHiveModel>(
      captureItemsBoxName,
    );
  };
}
