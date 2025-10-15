import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
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
        expect(repository.lastLimit, equals(captureInboxDefaultBatchSize));
        expect(items, equals(repository.inboxItems));
      },
    );
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
    final items = limit == null
        ? List<CaptureItem>.from(inboxItems)
        : inboxItems.take(limit).toList();
    return List.unmodifiable(items);
  }

  @override
  Future<void> delete(EntityId id) async {
    deletedIds.add(id);
  }
}
