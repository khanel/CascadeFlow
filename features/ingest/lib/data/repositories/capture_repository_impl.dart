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
    final result = await _localDataSource.save(model);
    if (result case FailureResult(failure: final failure)) {
      throw failure;
    }
  }

  /// Loads all inbox capture items ordered by newest creation time first.
  ///
  /// This method uses Hive queries to efficiently filter and sort inbox items.
  @override
  Future<List<CaptureItem>> loadInbox({
    int? limit,
    EntityId? startAfter,
  }) async {
    if (limit != null && limit < 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'Limit must be greater than or equal to zero',
      );
    }

    final result = await _localDataSource.readInbox();
    if (result case FailureResult(failure: final failure)) {
      throw failure;
    }

    final models =
        (result
                as SuccessResult<
                  List<CaptureItemHiveModel>,
                  InfrastructureFailure
                >)
            .value;
    final sortedInbox = models.map((model) => model.toDomain()).toList();

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
