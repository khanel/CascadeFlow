import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';

/// Repository implementation that persists capture items via Hive.
class CaptureRepositoryImpl implements CaptureRepository {
  /// Creates a repository backed by the provided [localDataSource].
  CaptureRepositoryImpl({required CaptureLocalDataSource localDataSource})
    : _localDataSource = localDataSource;

  final CaptureLocalDataSource _localDataSource;

  /// Persists the provided [item] into storage.
  @override
  Future<void> save(CaptureItem item) async {
    final model = CaptureItemHiveModel.fromDomain(item);
    await _localDataSource.save(model);
  }

  /// Loads all inbox capture items ordered by newest creation time first.
  ///
  /// This method loads all items from the data source, then filters for
  /// inbox items and sorts them in memory.
  @override
  Future<List<CaptureItem>> loadInbox({
    int? limit,
    EntityId? startAfter,
  }) async {
    final models = await _localDataSource.readAll();
    final sortedInbox =
        models
            .map((model) => model.toDomain())
            .where((item) => item.status == CaptureStatus.inbox)
            .toList()
          ..sort(
            (CaptureItem a, CaptureItem b) =>
                b.createdAt.compareTo(a.createdAt),
          );

    if (limit != null && limit < 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Limit must be greater than or equal to zero',
      );
    }

    final paged = _sliceAfter(sortedInbox, startAfter);
    final limited = limit == null ? paged : paged.take(limit).toList();
    return List.unmodifiable(limited);
  }

  List<CaptureItem> _sliceAfter(
    List<CaptureItem> items,
    EntityId? cursor,
  ) {
    if (cursor == null) {
      return items;
    }
    final index = items.indexWhere((item) => item.id == cursor);
    if (index < 0) {
      return items;
    }
    if (index + 1 >= items.length) {
      return const <CaptureItem>[];
    }
    return items.sublist(index + 1);
  }

  /// Deletes the capture item identified by [id] from persistence.
  @override
  Future<void> delete(EntityId id) {
    return _localDataSource.delete(id.value);
  }
}
