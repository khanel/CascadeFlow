import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';

/// Repository implementation that persists capture items via Hive.
class CaptureRepositoryImpl {
  /// Creates a repository backed by the provided [localDataSource].
  CaptureRepositoryImpl({required CaptureLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final CaptureLocalDataSource _localDataSource;

  /// Persists the provided [item] into storage.
  Future<void> save(CaptureItem item) async {
    final model = CaptureItemHiveModel.fromDomain(item);
    await _localDataSource.save(model);
  }

  /// Loads all inbox capture items ordered by creation time.
  Future<List<CaptureItem>> loadInbox() async {
    final models = await _localDataSource.readAll();
    final mapped = models.map((model) => model.toDomain());
    final inboxItems = mapped.where(
      (item) => item.status == CaptureStatus.inbox,
    );
    final sorted = inboxItems.toList()
      ..sort(
        (CaptureItem a, CaptureItem b) =>
            a.createdAt.compareTo(b.createdAt),
      );
    return sorted;
  }
}
