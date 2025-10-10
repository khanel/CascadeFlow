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
final Provider<CaptureLocalDataSource> captureLocalDataSourceProvider =
    Provider<CaptureLocalDataSource>((ref) {
      final initializer = ref.watch(hiveInitializerProvider);
      return CaptureLocalDataSource(initializer: initializer);
    });

/// Supplies the repository used by the Ingest presentation layer.
final Provider<CaptureRepository> captureRepositoryProvider =
    Provider<CaptureRepository>((ref) {
      final dataSource = ref.watch(captureLocalDataSourceProvider);
      return CaptureRepositoryImpl(localDataSource: dataSource);
    });

/// Publishes domain events emitted by the quick entry use case.
final Provider<CaptureQuickEntryEventPublisher>
captureQuickEntryEventPublisherProvider =
    Provider<CaptureQuickEntryEventPublisher>((ref) => (_) {});

/// Builds the capture quick-entry use case used by the controller.
final Provider<CaptureQuickEntry> captureQuickEntryUseCaseProvider =
    Provider<CaptureQuickEntry>((ref) {
      return CaptureQuickEntry(
        idGenerator: EntityId.generate,
        nowProvider: () => Timestamp(DateTime.now().toUtc()),
        publishEvent: ref.watch(captureQuickEntryEventPublisherProvider),
      );
    });

/// Loads capture inbox items for presentation.
final FutureProvider<List<CaptureItem>> captureInboxItemsProvider =
    FutureProvider.autoDispose<List<CaptureItem>>((ref) async {
      final repository = ref.watch(captureRepositoryProvider);
      return repository.loadInbox();
    });

/// Describes the submission lifecycle for the quick-entry controller.
enum CaptureQuickEntryStatus {
  /// No submission in progress.
  idle,

  /// A quick-entry request is currently being processed.
  submitting,

  /// The latest quick-entry request completed successfully.
  success,

  /// The latest quick-entry request failed.
  error,
}

/// State consumed by widgets interacting with the quick-entry controller.
@immutable
class CaptureQuickEntryState {
  /// Builds a state object backing the quick-entry workflow.
  const CaptureQuickEntryState({
    required CaptureQuickEntryStatus status,
    CaptureItem? item,
    Failure? failure,
  }) : this._(
         status: status,
         item: item,
         failure: failure,
       );

  /// Internal constructor used by the named factories.
  const CaptureQuickEntryState._({
    required this.status,
    this.item,
    this.failure,
  });

  /// Initial idle state before any submissions occur.
  const CaptureQuickEntryState.initial()
    : this._(status: CaptureQuickEntryStatus.idle);

  /// State representing an in-flight submission.
  const CaptureQuickEntryState.submitting()
    : this._(status: CaptureQuickEntryStatus.submitting);

  /// State representing a successful submission.
  const CaptureQuickEntryState.success(CaptureItem item)
    : this._(
        status: CaptureQuickEntryStatus.success,
        item: item,
      );

  /// State representing a failed submission.
  const CaptureQuickEntryState.error(Failure failure)
    : this._(
        status: CaptureQuickEntryStatus.error,
        failure: failure,
      );

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
    state = const CaptureQuickEntryState.submitting();

    final captureQuickEntry = ref.read(captureQuickEntryUseCaseProvider);
    final repository = ref.read(captureRepositoryProvider);
    final result = captureQuickEntry(request: request);

    switch (result) {
      case SuccessResult<CaptureItem, Failure>(value: final item):
        await repository.save(item);
        state = CaptureQuickEntryState.success(item);
        ref.invalidate(captureInboxItemsProvider);
      case FailureResult<CaptureItem, Failure>(failure: final failure):
        state = CaptureQuickEntryState.error(failure);
    }
  }
}

/// Provider exposing the quick-entry controller to presentation code.
final NotifierProvider<CaptureQuickEntryController, CaptureQuickEntryState>
captureQuickEntryControllerProvider =
    NotifierProvider.autoDispose<
      CaptureQuickEntryController,
      CaptureQuickEntryState
    >(CaptureQuickEntryController.new);
