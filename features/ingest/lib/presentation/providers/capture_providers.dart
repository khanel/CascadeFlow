import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:cascade_flow_ingest/data/hive/capture_local_data_source.dart';
import 'package:cascade_flow_ingest/data/preferences/capture_inbox_filter_store.dart';
import 'package:cascade_flow_ingest/data/repositories/capture_repository_impl.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/archive_capture_item.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/domain/use_cases/file_capture_item.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_constants.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_exceptions.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

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

/// Provides access to persisted capture inbox filter selections.
final Provider<CaptureInboxFilterStore> captureInboxFilterStoreProvider =
    Provider<CaptureInboxFilterStore>((ref) {
      final storage = ref.watch(secureStorageProvider);
      return CaptureInboxFilterStore(secureStorage: storage);
    });

/// Maintains the inbox filter selection.
class CaptureInboxFilterController extends Notifier<CaptureInboxFilter> {
  CaptureInboxFilterStore? _store;
  Future<void>? _restoreTask;

  /// Completes when the persisted filter state has been restored.
  Future<void> whenReady() => _restoreTask ?? Future<void>.value();

  @override
  CaptureInboxFilter build() {
    _store ??= ref.read(captureInboxFilterStoreProvider);
    _restoreTask ??= _restoreFromStorage();
    return CaptureInboxFilter.empty;
  }

  /// Clears all filter selections.
  void clear() {
    if (state == CaptureInboxFilter.empty) {
      return;
    }
    state = CaptureInboxFilter.empty;
    _save(state);
  }

  /// Sets the active source filter and resets the channel selection.
  void setSource(CaptureSource? source) {
    final next = state.copyWith(
      source: source,
      channel: null,
    );
    if (next == state) {
      return;
    }
    state = next;
    _save(next);
  }

  /// Sets the active channel filter while preserving the selected source.
  void setChannel(String? channel) {
    final next = state.withChannel(channel);
    if (next == state) {
      return;
    }
    state = next;
    _save(next);
  }

  Future<void> _restoreFromStorage() async {
    final store = _store;
    if (store == null) {
      return;
    }
    try {
      final stored = await store.load();
      if (stored != state) {
        state = stored;
      }
    } on Object {
      // Ignore persistence failures during bootstrap; state remains unchanged.
    }
  }

  void _save(CaptureInboxFilter filter) {
    final store = _store;
    if (store == null) {
      return;
    }

    final persistence = _shouldClearFilter(filter)
        ? store.clear()
        : store.save(filter);

    unawaited(
      persistence.catchError(
        (Object error, StackTrace stackTrace) => null,
      ),
    );
  }

  bool _shouldClearFilter(CaptureInboxFilter filter) =>
      filter == CaptureInboxFilter.empty;
}

/// Provides the current capture inbox filter.
final NotifierProvider<CaptureInboxFilterController, CaptureInboxFilter>
captureInboxFilterProvider =
    NotifierProvider<CaptureInboxFilterController, CaptureInboxFilter>(
      CaptureInboxFilterController.new,
    );

/// Publishes domain events emitted by the quick entry use case.
final Provider<CaptureQuickEntryEventPublisher>
captureQuickEntryEventPublisherProvider =
    Provider<CaptureQuickEntryEventPublisher>((ref) => (_) {});

/// Publishes domain events emitted by the archive use case.
final Provider<ArchiveCaptureItemEventPublisher>
archiveCaptureItemEventPublisherProvider =
    Provider<ArchiveCaptureItemEventPublisher>((ref) => (_) {});

/// Builds the capture quick-entry use case used by the controller.
final Provider<CaptureQuickEntry> captureQuickEntryUseCaseProvider =
    Provider<CaptureQuickEntry>((ref) {
      return CaptureQuickEntry(
        idGenerator: EntityId.generate,
        nowProvider: () => Timestamp(DateTime.now().toUtc()),
        publishEvent: ref.watch(captureQuickEntryEventPublisherProvider),
      );
    });

/// Builds the archive capture item use case used by the inbox gestures.
final Provider<ArchiveCaptureItem> archiveCaptureItemUseCaseProvider =
    Provider<ArchiveCaptureItem>((ref) {
      return ArchiveCaptureItem(
        nowProvider: () => Timestamp(DateTime.now().toUtc()),
        publishEvent: ref.watch(archiveCaptureItemEventPublisherProvider),
      );
    });

/// Publishes domain events emitted by the file use case.
final Provider<FileCaptureItemEventPublisher>
fileCaptureItemEventPublisherProvider = Provider<FileCaptureItemEventPublisher>(
  (ref) => (_) {},
);

/// Builds the file capture item use case used by the inbox gestures.
final Provider<FileCaptureItem> fileCaptureItemUseCaseProvider =
    Provider<FileCaptureItem>((ref) {
      return FileCaptureItem(
        nowProvider: () => Timestamp(DateTime.now().toUtc()),
        publishEvent: ref.watch(fileCaptureItemEventPublisherProvider),
      );
    });

/// Arguments describing a paged inbox request.
typedef CaptureInboxPageArgs = ({int? limit, EntityId? startAfter});

/// Provides the default inbox page used by the capture inbox list.
final FutureProvider<List<CaptureItem>> captureInboxItemsProvider =
    FutureProvider.autoDispose<List<CaptureItem>>((ref) async {
      return _loadInboxPage(
        ref,
        limit: CaptureInboxConstants.defaultBatchSize,
      );
    });

/// Loads a paginated slice of the inbox after an optional cursor.
final FutureProvider<List<CaptureItem>> Function(CaptureInboxPageArgs args)
captureInboxPageProvider = FutureProvider.autoDispose
    .family<List<CaptureItem>, CaptureInboxPageArgs>((ref, args) async {
      return _loadInboxPage(
        ref,
        limit: args.limit ?? CaptureInboxConstants.defaultBatchSize,
        startAfter: args.startAfter,
      );
    });

/// State snapshot produced by the inbox pagination controller.
@immutable
class CaptureInboxPaginationState {
  /// Builds a pagination state with the provided [items] and metadata.
  CaptureInboxPaginationState({
    required List<CaptureItem> items,
    required this.hasMore,
    this.isLoadingMore = false,
    this.loadMoreError,
  }) : items = List.unmodifiable(items);

  /// Inbox items currently loaded in memory.
  final List<CaptureItem> items;

  /// Indicates that additional items are available beyond the current page.
  final bool hasMore;

  /// Whether an additional page request is currently in flight.
  final bool isLoadingMore;

  /// Most recent load-more error, cleared on subsequent successful loads.
  final AsyncError<Object>? loadMoreError;

  /// Convenience flag to detect when the inbox has no content.
  bool get isEmpty => items.isEmpty;

  static const Object _sentinel = Object();

  /// Returns an updated copy of the pagination state.
  CaptureInboxPaginationState copyWith({
    List<CaptureItem>? items,
    bool? hasMore,
    bool? isLoadingMore,
    Object? loadMoreError = _sentinel,
  }) {
    return CaptureInboxPaginationState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      loadMoreError: identical(loadMoreError, _sentinel)
          ? this.loadMoreError
          : loadMoreError as AsyncError<Object>?,
    );
  }

  /// Returns a state that reflects an in-flight load-more request.
  CaptureInboxPaginationState beginLoadMore() {
    return copyWith(
      isLoadingMore: true,
      loadMoreError: null,
    );
  }

  /// Returns a state that appends [appended] items and updates [hasMore].
  CaptureInboxPaginationState append(
    List<CaptureItem> appended, {
    required bool hasMore,
  }) {
    final updated = <CaptureItem>[...items, ...appended];
    return CaptureInboxPaginationState(
      items: updated,
      hasMore: hasMore,
    );
  }

  /// Returns a state that captures the error produced during load-more.
  CaptureInboxPaginationState withLoadMoreError(
    Object error,
    StackTrace stackTrace,
  ) {
    return copyWith(
      isLoadingMore: false,
      loadMoreError: AsyncError<Object>(error, stackTrace),
    );
  }
}

/// Controller that orchestrates paginated inbox loading with Riverpod.
class CaptureInboxPaginationController
    extends Notifier<AsyncValue<CaptureInboxPaginationState>> {
  /// Completes when the current initial load finishes.
  Future<void> whenReady() => _initialLoad ?? Future.value();

  Future<void>? _initialLoad;

  @override
  AsyncValue<CaptureInboxPaginationState> build() {
    _initialLoad = _loadInitial();
    return const AsyncValue.loading();
  }

  Future<void> _loadInitial() async {
    try {
      final items = await _loadPage();
      final hasMore = _hasMoreItems(items);
      state = AsyncValue.data(
        CaptureInboxPaginationState(
          items: items,
          hasMore: hasMore,
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  bool _hasMoreItems(List<CaptureItem> items) =>
      items.length == CaptureInboxConstants.defaultBatchSize;

  /// Requests the next page of inbox items when available.
  Future<void> loadNextPage() async {
    final current = state.maybeWhen(
      data: (value) => value,
      orElse: () => null,
    );

    if (_shouldSkipLoadMore(current)) {
      return;
    }

    final loadingMore = current!.beginLoadMore();
    state = AsyncValue.data(loadingMore);

    final cursor = _getCursorForNextPage(current);

    try {
      final next = await _loadPage(startAfter: cursor);
      state = AsyncValue.data(
        loadingMore.append(
          next,
          hasMore: _hasMoreItems(next),
        ),
      );
    } on Object catch (error, stackTrace) {
      state = AsyncValue.data(loadingMore.withLoadMoreError(error, stackTrace));
    }
  }

  bool _shouldSkipLoadMore(CaptureInboxPaginationState? current) =>
      current == null || current.isLoadingMore || !current.hasMore;

  EntityId? _getCursorForNextPage(CaptureInboxPaginationState current) =>
      current.items.isEmpty ? null : current.items.last.id;

  Future<List<CaptureItem>> _loadPage({EntityId? startAfter}) {
    final repository = ref.read(captureRepositoryProvider);
    return repository.loadInbox(
      limit: CaptureInboxConstants.defaultBatchSize,
      startAfter: startAfter,
    );
  }
}

/// Provider exposing the paginated inbox controller to widgets.
// ignore: specify_nonobvious_property_types
final captureInboxPaginationControllerProvider =
    NotifierProvider.autoDispose<
      CaptureInboxPaginationController,
      AsyncValue<CaptureInboxPaginationState>
    >(CaptureInboxPaginationController.new);

/// Loads a page of inbox items using shared repository lookups.
Future<List<CaptureItem>> _loadInboxPage(
  Ref ref, {
  required int limit,
  EntityId? startAfter,
}) {
  final repository = ref.watch(captureRepositoryProvider);
  return repository.loadInbox(
    limit: limit,
    startAfter: startAfter,
  );
}

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
  static const ValidationFailure _emptyCaptureContentFailure =
      ValidationFailure(message: 'Capture content cannot be empty');

  @override
  CaptureQuickEntryState build() => const CaptureQuickEntryState.initial();

  /// Submits a quick-entry request, persisting successful captures.
  Future<void> submit({
    required CaptureQuickEntryRequest request,
  }) async {
    final validationFailure = _validateRequest(request);
    if (validationFailure != null) {
      state = CaptureQuickEntryState.error(validationFailure);
      return;
    }
    state = const CaptureQuickEntryState.submitting();

    final captureQuickEntry = ref.read(captureQuickEntryUseCaseProvider);
    final repository = ref.read(captureRepositoryProvider);
    final result = captureQuickEntry(request: request);

    switch (result) {
      case SuccessResult<CaptureItem, Failure>(value: final item):
        await repository.save(item);
        state = CaptureQuickEntryState.success(item);
        ref.invalidate(captureInboxItemsProvider);
        ref.invalidate(captureInboxPaginationControllerProvider);
      case FailureResult<CaptureItem, Failure>(failure: final failure):
        state = CaptureQuickEntryState.error(failure);
    }
  }

  ValidationFailure? _validateRequest(CaptureQuickEntryRequest request) {
    if (request.rawContent.trim().isEmpty) {
      return _emptyCaptureContentFailure;
    }
    return null;
  }
}

/// Controller for managing filter presets. Maintains a list of saved presets
/// and provides operations to save, load, and delete them.
class CaptureFilterPresetController
    extends Notifier<AsyncValue<List<CaptureFilterPreset>>> {
  CaptureInboxFilterStore? _store;
  Future<void>? _initialLoad;

  /// Completes when the initial preset load finishes.
  Future<void> whenReady() => _initialLoad ?? Future<void>.value();

  @override
  AsyncValue<List<CaptureFilterPreset>> build() {
    _store ??= ref.read(captureInboxFilterStoreProvider);
    _initialLoad ??= _loadInitial();
    return const AsyncValue.loading();
  }

  Future<void> _loadInitial() async {
    final store = _store;
    if (store == null) {
      state = const AsyncValue.data([]);
      return;
    }

    try {
      final presets = await store.loadPresets();
      state = AsyncValue.data(presets);
    } on FilterPresetException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } on Object catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Reloads presets from storage.
  Future<void> reloadPresets() async {
    await _loadInitial();
  }

  /// Saves a new preset or updates an existing one.
  Future<void> savePreset(CaptureFilterPreset preset) async {
    final store = _store;
    if (store == null) return;

    try {
      await store.savePreset(preset);
      await _loadInitial(); // Refresh state
    } on FilterPresetException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } on Object catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Deletes a preset by name.
  Future<void> deletePreset(String name) async {
    final store = _store;
    if (store == null) return;

    try {
      await store.deletePreset(name);
      await _loadInitial(); // Refresh state
    } on FilterPresetException catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    } on Object catch (error) {
      state = AsyncValue.error(error, StackTrace.current);
    }
  }

  /// Applies a preset's filter to the current filter controller.
  void applyPreset(
    CaptureFilterPreset preset,
    CaptureInboxFilterController filterController,
  ) {
    filterController
      ..state = preset.filter
      .._save(preset.filter);
  }
}

/// Provider for the filter preset controller.
final NotifierProvider<
  CaptureFilterPresetController,
  AsyncValue<List<CaptureFilterPreset>>
>
captureFilterPresetProvider =
    NotifierProvider<
      CaptureFilterPresetController,
      AsyncValue<List<CaptureFilterPreset>>
    >(
      CaptureFilterPresetController.new,
    );

/// Provider exposing the quick-entry controller to presentation code.
final NotifierProvider<CaptureQuickEntryController, CaptureQuickEntryState>
captureQuickEntryControllerProvider =
    NotifierProvider.autoDispose<
      CaptureQuickEntryController,
      CaptureQuickEntryState
    >(CaptureQuickEntryController.new);
