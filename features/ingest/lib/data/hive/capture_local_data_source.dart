import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';

/// Hive box name for capture inbox items.
const String captureItemsBoxName = 'capture_items';

// BLUE Phase Refactoring Complete: Applied TDD guidelines
// ✅ Minimal Complexity: Simplified _ensureBox() logic, removed redundant
//    variable assignment
// ✅ Clear Logic Flow: Direct null check for improved readability
// ✅ Single Responsibility: Maintained focused method responsibilities

/// Local data source responsible for interacting with the
/// capture inbox box.
class CaptureLocalDataSource {
  /// Creates a data source backed by the provided [initializer].
  CaptureLocalDataSource({required HiveInitializer initializer})
    : _initializer = initializer;

  final HiveInitializer _initializer;
  Future<HiveBox<CaptureItemHiveModel>>? _captureBoxFuture;

  /// Ensures the capture inbox box is opened before use.
  Future<void> warmUp() async {
    await _initializer.initialize();
    _captureBoxFuture ??= _initializer.openEncryptedBox<CaptureItemHiveModel>(
      captureItemsBoxName,
    );
    await _captureBoxFuture;
  }

  /// Persists the provided capture [model] to the inbox box.
  Future<void> save(CaptureItemHiveModel model) async {
    await _useBox((box) => box.put(model.id, model));
  }

  /// Persists [model] and returns a [Result] describing success or failure.
  Future<Result<void, InfrastructureFailure>> saveResult(
    CaptureItemHiveModel model,
  ) {
    return Result.guardAsync<void, InfrastructureFailure>(
      body: () => save(model),
      onError: (error, stackTrace) => _wrapOperationError(
        error: error,
        stackTrace: stackTrace,
        operation: 'save',
        id: model.id,
      ),
    );
  }

  /// Reads a capture model for the given [id], returning null when missing.
  Future<CaptureItemHiveModel?> read(String id) async {
    return _useBox((box) => box.get(id));
  }

  /// Reads a capture model as a [Result], preserving Hive failure context.
  Future<Result<CaptureItemHiveModel?, InfrastructureFailure>> readResult(
    String id,
  ) {
    return Result.guardAsync<CaptureItemHiveModel?, InfrastructureFailure>(
      body: () => read(id),
      onError: (error, stackTrace) => _wrapOperationError(
        error: error,
        stackTrace: stackTrace,
        operation: 'read',
        id: id,
      ),
    );
  }

  /// Deletes the capture model identified by [id], ignoring missing entries.
  Future<void> delete(String id) async {
    await _useBox((box) => box.delete(id));
  }

  /// Deletes the capture model identified by [id] and returns a [Result]
  /// describing success or failure, ignoring missing entries.
  Future<Result<void, InfrastructureFailure>> deleteResult(String id) {
    return Result.guardAsync<void, InfrastructureFailure>(
      body: () => delete(id),
      onError: (error, stackTrace) => _wrapOperationError(
        error: error,
        stackTrace: stackTrace,
        operation: 'delete',
        id: id,
      ),
    );
  }

  /// Returns a snapshot of every stored capture model.
  Future<List<CaptureItemHiveModel>> readAll() async {
    return _useBox((box) => box.values());
  }

  Future<HiveBox<CaptureItemHiveModel>> _ensureBox() async {
    if (_captureBoxFuture != null) {
      return _captureBoxFuture!;
    }
    await warmUp();
    return _captureBoxFuture!;
  }

  Future<T> _useBox<T>(
    Future<T> Function(HiveBox<CaptureItemHiveModel> box) action,
  ) async {
    final box = await _ensureBox();
    return action(box);
  }

  InfrastructureFailure _wrapOperationError({
    required Object error,
    required StackTrace stackTrace,
    required String operation,
    required String id,
  }) {
    if (error is InfrastructureFailure) {
      return InfrastructureFailure(
        message: error.message,
        cause: error.cause,
        stackTrace: error.stackTrace ?? stackTrace,
      );
    }
    return InfrastructureFailure(
      message: 'Failed to $operation capture model "$id".',
      cause: error,
      stackTrace: stackTrace,
    );
  }
}
