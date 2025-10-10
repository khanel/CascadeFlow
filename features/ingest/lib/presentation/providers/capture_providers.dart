import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:cascade_flow_ingest/data/repositories/capture_repository_impl.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:meta/meta.dart';
import 'package:riverpod/riverpod.dart';

/// Provides the Hive-backed data source for capture inbox operations.
final captureLocalDataSourceProvider = Provider<CaptureLocalDataSource>((ref) {
  final initializer = ref.watch(hiveInitializerProvider);
  return CaptureLocalDataSource(initializer: initializer);
});

/// Supplies the repository used by the Ingest presentation layer.
final captureRepositoryProvider = Provider<CaptureRepository>((ref) {
  final dataSource = ref.watch(captureLocalDataSourceProvider);
  return CaptureRepositoryImpl(localDataSource: dataSource);
});

/// Publishes domain events emitted by the quick entry use case.
final captureQuickEntryEventPublisherProvider =
    Provider<CaptureQuickEntryEventPublisher>(
      (ref) => (_) {},
    );

/// Builds the capture quick-entry use case used by the controller.
final captureQuickEntryUseCaseProvider = Provider<CaptureQuickEntry>((ref) {
  return CaptureQuickEntry(
    idGenerator: EntityId.generate,
    nowProvider: () => Timestamp(DateTime.now().toUtc()),
    publishEvent: ref.watch(captureQuickEntryEventPublisherProvider),
  );
});

/// Loads capture inbox items for presentation.
final captureInboxItemsProvider = FutureProvider.autoDispose<List<CaptureItem>>(
  (ref) async {
    final repository = ref.watch(captureRepositoryProvider);
    return repository.loadInbox();
  },
);

/// Describes the submission lifecycle for the quick-entry controller.
enum CaptureQuickEntryStatus { idle, submitting, success, error }

/// State consumed by widgets interacting with the quick-entry controller.
@immutable
class CaptureQuickEntryState {
  /// Builds a state object backing the quick-entry workflow.
  const CaptureQuickEntryState({
    required this.status,
    this.item,
    this.failure,
  });

  /// Creates the initial idle state.
  const CaptureQuickEntryState.initial()
    : this(status: CaptureQuickEntryStatus.idle);

  /// Submission status of the controller.
  final CaptureQuickEntryStatus status;

  /// Latest capture item produced by the controller.
  final CaptureItem? item;

  /// Failure emitted by the use case when submission fails.
  final Failure? failure;
}

/// State notifier that orchestrates the quick-entry submission flow.
class CaptureQuickEntryController extends Notifier<CaptureQuickEntryState> {
  @override
  CaptureQuickEntryState build() => const CaptureQuickEntryState.initial();

  /// Submits a quick-entry request, persisting successful captures.
  Future<void> submit({
    required CaptureQuickEntryRequest request,
  }) async {
    state = const CaptureQuickEntryState(
      status: CaptureQuickEntryStatus.submitting,
    );

    final captureQuickEntry = ref.read(captureQuickEntryUseCaseProvider);
    final repository = ref.read(captureRepositoryProvider);
    final result = captureQuickEntry(request: request);

    if (result is SuccessResult<CaptureItem, Failure>) {
      final item = result.value;
      await repository.save(item);
      state = CaptureQuickEntryState(
        status: CaptureQuickEntryStatus.success,
        item: item,
      );
      ref.invalidate(captureInboxItemsProvider);
      return;
    }

    if (result is FailureResult<CaptureItem, Failure>) {
      state = CaptureQuickEntryState(
        status: CaptureQuickEntryStatus.error,
        failure: result.failure,
      );
    }
  }
}

/// Provider exposing the quick-entry controller to presentation code.
final captureQuickEntryControllerProvider =
    NotifierProvider.autoDispose<
      CaptureQuickEntryController,
      CaptureQuickEntryState
    >(CaptureQuickEntryController.new);
