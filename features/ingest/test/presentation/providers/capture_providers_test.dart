import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/preferences/capture_inbox_filter_store.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_constants.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

import '../../test_utils/capture_test_data.dart';

void main() {
  group('captureInboxItemsProvider', () {
    test('loads inbox items once per read', () async {
      // ARRANGE
      final repository = _RecordingCaptureRepository()
        ..inboxItems = <CaptureItem>[
          buildTestCaptureItem(
            id: 'capture-1',
            createdMicros: 10,
            updatedMicros: 10,
          ),
          buildTestCaptureItem(
            id: 'capture-2',
            createdMicros: 20,
            updatedMicros: 20,
          ),
        ];
      final container = ProviderContainer(
        overrides: [
          captureRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final inbox = await container.read(captureInboxItemsProvider.future);

      // ASSERT
      expect(inbox, equals(repository.inboxItems));
      expect(repository.loadInboxInvocations, equals(1));
    });

    test(
      'requests default batch size when loading inbox items',
      () async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(id: 'capture-1'),
            buildTestCaptureItem(id: 'capture-2'),
            buildTestCaptureItem(id: 'capture-3'),
          ];
        final container = ProviderContainer(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        // ACT
        final items = await container.read(captureInboxItemsProvider.future);

        // ASSERT
        expect(
          repository.lastLimit,
          equals(CaptureInboxConstants.defaultBatchSize),
        );
        expect(items, equals(repository.inboxItems));
      },
    );
  });

  group('captureInboxPageProvider', () {
    test(
      'loads items after provided cursor using custom limit',
      () async {
        // ARRANGE
        final newest = buildTestCaptureItem(id: 'capture-newest');
        final middle = buildTestCaptureItem(id: 'capture-middle');
        final oldest = buildTestCaptureItem(id: 'capture-oldest');
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[newest, middle, oldest];
        final container = ProviderContainer(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
          ],
        );
        addTearDown(container.dispose);

        // ACT
        final page = await container.read(
          captureInboxPageProvider(
            (limit: 2, startAfter: newest.id),
          ).future,
        );

        // ASSERT
        expect(repository.lastLimit, equals(2));
        expect(repository.lastStartAfterId, equals(newest.id));
        expect(page, equals(<CaptureItem>[middle, oldest]));
      },
    );
  });

  group('captureInboxPaginationControllerProvider', () {
    test('loads initial page with hasMore flag', () async {
      // ARRANGE
      final repository = _RecordingCaptureRepository()
        ..inboxItems = <CaptureItem>[
          buildTestCaptureItem(id: 'capture-1'),
          buildTestCaptureItem(id: 'capture-2'),
        ];
      final container = ProviderContainer(
        overrides: [
          captureRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final controller = container.read(
        captureInboxPaginationControllerProvider.notifier,
      );
      await controller.whenReady();
      final state = container.read(captureInboxPaginationControllerProvider);

      // ASSERT
      expect(state, isA<AsyncData<CaptureInboxPaginationState>>());
      expect(
        state.requireValue.items,
        equals(repository.inboxItems),
      );
      expect(state.requireValue.hasMore, isFalse);
      expect(repository.loadInboxInvocations, equals(1));
    });

    test('appends next page when loadNextPage is invoked', () async {
      // ARRANGE
      const totalItems = CaptureInboxConstants.defaultBatchSize + 5;
      final repository = _RecordingCaptureRepository()
        ..inboxItems = List<CaptureItem>.generate(
          totalItems,
          (index) => buildTestCaptureItem(
            id: 'capture-${index + 1}',
            createdMicros: 100 + index,
            updatedMicros: 200 + index,
          ),
        );
      final container = ProviderContainer(
        overrides: [
          captureRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        captureInboxPaginationControllerProvider.notifier,
      );

      // ACT
      await controller.whenReady();
      final initial = container.read(captureInboxPaginationControllerProvider);
      expect(
        initial.requireValue.items.length,
        CaptureInboxConstants.defaultBatchSize,
      );
      expect(initial.requireValue.hasMore, isTrue);

      await controller.loadNextPage();

      final updated = container
          .read(captureInboxPaginationControllerProvider)
          .maybeWhen(
            data: (value) => value,
            orElse: () => null,
          );

      // ASSERT
      expect(updated, isNotNull);
      expect(updated!.items.length, equals(totalItems));
      expect(updated.hasMore, isFalse);
      expect(updated.isLoadingMore, isFalse);
      expect(repository.loadInboxInvocations, equals(2));
    });

    test('ignores loadNextPage when no more items remain', () async {
      // ARRANGE
      final repository = _RecordingCaptureRepository()
        ..inboxItems = <CaptureItem>[
          buildTestCaptureItem(id: 'capture-1'),
        ];
      final container = ProviderContainer(
        overrides: [
          captureRepositoryProvider.overrideWithValue(repository),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        captureInboxPaginationControllerProvider.notifier,
      );

      // ACT
      await controller.whenReady();
      final state = container.read(captureInboxPaginationControllerProvider);
      expect(state.requireValue.hasMore, isFalse);

      await controller.loadNextPage();

      // ASSERT
      expect(repository.loadInboxInvocations, equals(1));
    });
  });

  group('captureQuickEntryControllerProvider', () {
    test(
      'persists capture and exposes success state when request is valid',
      () async {
        // ARRANGE
        final repository = _RecordingCaptureRepository();
        final generatedId = EntityId('capture-generated');
        final timestamp = Timestamp(DateTime.utc(2025));
        final publishedEvents = <DomainEvent>[];
        final container = ProviderContainer(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
            captureQuickEntryUseCaseProvider.overrideWithValue(
              CaptureQuickEntry(
                idGenerator: () => generatedId,
                nowProvider: () => timestamp,
                publishEvent: publishedEvents.add,
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read<CaptureQuickEntryController>(
          captureQuickEntryControllerProvider.notifier,
        );

        // ACT
        await controller.submit(
          request: const CaptureQuickEntryRequest(
            rawContent: 'Log meeting notes',
          ),
        );

        // ASSERT
        expect(repository.savedItems.single.id, generatedId);
        expect(repository.savedItems.single.content, 'Log meeting notes');
        expect(publishedEvents, isNotEmpty);

        final state = container.read<CaptureQuickEntryState>(
          captureQuickEntryControllerProvider,
        );
        expect(state.status, CaptureQuickEntryStatus.success);
        expect(state.item?.id, generatedId);
        expect(state.failure, isNull);
      },
    );

    test(
      'captures failure state without persisting when use case fails',
      () async {
        // ARRANGE
        final repository = _RecordingCaptureRepository();
        final container = ProviderContainer(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
            captureQuickEntryUseCaseProvider.overrideWithValue(
              CaptureQuickEntry(
                idGenerator: () => EntityId('ignored'),
                nowProvider: () => Timestamp(DateTime.utc(2025)),
                publishEvent: (_) {},
              ),
            ),
          ],
        );
        addTearDown(container.dispose);
        final controller = container.read<CaptureQuickEntryController>(
          captureQuickEntryControllerProvider.notifier,
        );

        // ACT
        await controller.submit(
          request: const CaptureQuickEntryRequest(rawContent: '   '),
        );

        // ASSERT
        expect(repository.savedItems, isEmpty);
        final state = container.read<CaptureQuickEntryState>(
          captureQuickEntryControllerProvider,
        );
        expect(state.status, CaptureQuickEntryStatus.error);
        expect(state.failure, isA<Failure>());
        expect(state.item, isNull);
      },
    );
  });

  group('captureInboxFilterProvider', () {
    test('restores persisted filter on initialization', () async {
      // ARRANGE
      final storage = InMemorySecureStorage();
      final store = CaptureInboxFilterStore(secureStorage: storage);
      await store.save(
        const CaptureInboxFilter(
          source: CaptureSource.voice,
          channel: 'voice_memos',
        ),
      );
      final container = ProviderContainer(
        overrides: [
          captureInboxFilterStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);

      // ACT
      final controller = container.read(
        captureInboxFilterProvider.notifier,
      );
      await controller.whenReady();
      final filter = container.read(captureInboxFilterProvider);

      // ASSERT
      expect(filter.source, CaptureSource.voice);
      expect(filter.channel, 'voice_memos');
    });

    test('persists updates when filter selections change', () async {
      // ARRANGE
      final storage = InMemorySecureStorage();
      final store = CaptureInboxFilterStore(secureStorage: storage);
      final container = ProviderContainer(
        overrides: [
          captureInboxFilterStoreProvider.overrideWithValue(store),
        ],
      );
      addTearDown(container.dispose);
      final controller = container.read(
        captureInboxFilterProvider.notifier,
      );
      await controller.whenReady();

      // ACT
      controller
        ..setSource(CaptureSource.automation)
        ..setChannel('integration');
      await Future<void>.delayed(Duration.zero);
      final storedAfterSet = await store.load();

      controller.clear();
      await Future<void>.delayed(Duration.zero);
      final storedAfterClear = await store.load();

      // ASSERT
      expect(storedAfterSet.source, CaptureSource.automation);
      expect(storedAfterSet.channel, 'integration');
      expect(storedAfterClear, CaptureInboxFilter.empty);
    });
  });
}

class _RecordingCaptureRepository implements CaptureRepository {
  List<CaptureItem> inboxItems = <CaptureItem>[];
  final List<CaptureItem> savedItems = <CaptureItem>[];
  final List<EntityId> deletedIds = <EntityId>[];
  int loadInboxInvocations = 0;
  int? lastLimit;
  EntityId? lastStartAfterId;

  @override
  Future<void> save(CaptureItem item) async {
    savedItems.add(item);
  }

  @override
  Future<List<CaptureItem>> loadInbox({
    int? limit,
    EntityId? startAfter,
  }) async {
    loadInboxInvocations++;
    lastLimit = limit;
    lastStartAfterId = startAfter;
    final startIndex = startAfter == null
        ? -1
        : inboxItems.indexWhere((item) => item.id == startAfter);
    final sliced = startIndex >= 0 && startIndex + 1 < inboxItems.length
        ? inboxItems.sublist(startIndex + 1)
        : startIndex >= 0
        ? <CaptureItem>[]
        : List<CaptureItem>.from(inboxItems);
    final items = limit == null ? sliced : sliced.take(limit).toList();
    return List.unmodifiable(items);
  }

  @override
  Future<void> delete(EntityId id) async {
    deletedIds.add(id);
  }
}
