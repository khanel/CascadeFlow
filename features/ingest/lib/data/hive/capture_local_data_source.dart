import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';

/// Hive box name for capture inbox items.
const String captureItemsBoxName = 'capture_items';

/// Local data source responsible for interacting with the capture inbox box.
class CaptureLocalDataSource {
  /// Creates a data source backed by the provided [initializer].
  CaptureLocalDataSource({required InMemoryHiveInitializer initializer})
    : _initializer = initializer;

  final InMemoryHiveInitializer _initializer;

  /// Ensures the capture inbox box is opened before use.
  Future<void> warmUp() async {
    await _initializer.initialize();
    await _initializer.openEncryptedBox<CaptureItemHiveModel>(
      captureItemsBoxName,
    );
  }
}
