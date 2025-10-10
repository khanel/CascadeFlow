import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

/// Contract describing persistence operations for capture items.
abstract class CaptureRepository {
  /// Persists the provided [item] into storage.
  Future<void> save(CaptureItem item);

  /// Returns all capture items that remain in the inbox.
  Future<List<CaptureItem>> loadInbox();

  /// Removes the capture item identified by [id] from storage.
  Future<void> delete(EntityId id);
}
