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
  Future<InMemoryHiveBox<CaptureItemHiveModel>>?
      _captureBoxFuture;

  /// Ensures the capture inbox box is opened before use.
  Future<void> warmUp() async {
    await _initializer.initialize();
    _captureBoxFuture ??=
        _initializer.openEncryptedBox<CaptureItemHiveModel>(
          captureItemsBoxName,
        );
    await _captureBoxFuture;
  }

  /// Persists the provided capture [model] to the inbox box.
  Future<void> save(CaptureItemHiveModel model) async {
    final box = await _ensureBox();
    await box.put(model.id, model);
  }

  /// Reads a capture model for the given [id], returning null when missing.
  Future<CaptureItemHiveModel?> read(String id) async {
    final box = await _ensureBox();
    return box.get(id);
  }

  /// Returns a snapshot of every stored capture model.
  Future<List<CaptureItemHiveModel>> readAll() async {
    final box = await _ensureBox();
    return box.values();
  }

  Future<InMemoryHiveBox<CaptureItemHiveModel>> _ensureBox() async {
    final existing = _captureBoxFuture;
    if (existing != null) {
      return existing;
    }
    await warmUp();
    return _captureBoxFuture!;
  }
}
