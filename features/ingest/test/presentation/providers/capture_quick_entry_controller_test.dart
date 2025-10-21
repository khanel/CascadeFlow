import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';

class _RecordingCaptureRepository implements CaptureRepository {
  final List<CaptureItem> _items = <CaptureItem>[];
  int loadInboxCallCount = 0;
  int saveCallCount = 0;
  final List<EntityId> deletedIds = <EntityId>[];

  @override
  Future<void> save(CaptureItem item) async {
    saveCallCount++;
    _items
      ..removeWhere((existing) => existing.id == item.id)
      ..add(item);
  }

  @override
  Future<List<CaptureItem>> loadInbox({
    int? limit,
    EntityId? startAfter,
  }) async {
    loadInboxCallCount++;
    final inbox = _items
        .where((item) => item.status == CaptureStatus.inbox)
        .toList(growable: false);
    final startIndex = startAfter == null
        ? -1
        : inbox.indexWhere((item) => item.id == startAfter);
    final sliced = startIndex >= 0 && startIndex + 1 < inbox.length
        ? inbox.sublist(startIndex + 1)
        : startIndex >= 0
        ? <CaptureItem>[]
        : inbox;
    final limited = limit == null ? sliced : sliced.take(limit).toList();
    return List.unmodifiable(limited);
  }

  @override
  Future<void> delete(EntityId id) async {
    deletedIds.add(id);
    _items.removeWhere((item) => item.id == id);
  }

  List<CaptureItem> get savedItems => List.unmodifiable(_items);
}

void main() {
  group('CaptureQuickEntryController', () {
    late ProviderContainer container;
    late _RecordingCaptureRepository repository;
    late CaptureQuickEntry useCase;
    late EntityId captureId;
    late Timestamp now;

    setUp(() {
      repository = _RecordingCaptureRepository();
      captureId = EntityId('capture-test');
      now = Timestamp(DateTime.utc(2025));
      useCase = CaptureQuickEntry(
        idGenerator: () => captureId,
        nowProvider: () => now,
        publishEvent: (_) {},
      );

      container = ProviderContainer(
        overrides: [
          captureRepositoryProvider.overrideWithValue(repository),
          captureQuickEntryUseCaseProvider.overrideWithValue(useCase),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('submit persists capture and transitions to success state', () async {
      final states = <CaptureQuickEntryStatus>[];

      final stateSub = container.listen(captureQuickEntryControllerProvider, (
        CaptureQuickEntryState? previous,
        CaptureQuickEntryState next,
      ) {
        states.add(next.status);
      });
      addTearDown(stateSub.close);

      states.add(container.read(captureQuickEntryControllerProvider).status);

      expect(await container.read(captureInboxItemsProvider.future), isEmpty);
      expect(repository.loadInboxCallCount, equals(1));

      final controller = container.read(
        captureQuickEntryControllerProvider.notifier,
      );

      await controller.submit(
        request: const CaptureQuickEntryRequest(
          rawContent: 'Draft meeting notes',
        ),
      );

      final refreshed = await container.read(captureInboxItemsProvider.future);

      expect(states, <CaptureQuickEntryStatus>[
        CaptureQuickEntryStatus.idle,
        CaptureQuickEntryStatus.submitting,
        CaptureQuickEntryStatus.success,
      ]);
      expect(repository.saveCallCount, equals(1));
      expect(repository.loadInboxCallCount, equals(2));
      expect(repository.savedItems, hasLength(1));
      expect(repository.savedItems.single.id, equals(captureId));
      expect(refreshed, hasLength(1));
      expect(refreshed.single.content, equals('Draft meeting notes'));
    });

    test('submit updates state to error when content is empty', () async {
      final states = <CaptureQuickEntryStatus>[];
      final stateSub = container.listen(
        captureQuickEntryControllerProvider,
        (previous, next) => states.add(next.status),
      );
      addTearDown(stateSub.close);
      states.add(container.read(captureQuickEntryControllerProvider).status);

      final controller = container.read(
        captureQuickEntryControllerProvider.notifier,
      );

      await controller.submit(
        request: const CaptureQuickEntryRequest(rawContent: ''),
      );

      expect(states, [
        CaptureQuickEntryStatus.idle,
        CaptureQuickEntryStatus.error,
      ]);
      expect(repository.saveCallCount, isZero);
      final latestState = container.read(captureQuickEntryControllerProvider);
      expect(latestState.failure, isA<ValidationFailure>());
    });

    test(
      'submit updates state to error when content is only whitespace',
      () async {
        final states = <CaptureQuickEntryStatus>[];
        final stateSub = container.listen(
          captureQuickEntryControllerProvider,
          (previous, next) => states.add(next.status),
        );
        addTearDown(stateSub.close);
        states.add(container.read(captureQuickEntryControllerProvider).status);

        final controller = container.read(
          captureQuickEntryControllerProvider.notifier,
        );

        await controller.submit(
          request: const CaptureQuickEntryRequest(rawContent: '   '),
        );

        expect(states, [
          CaptureQuickEntryStatus.idle,
          CaptureQuickEntryStatus.error,
        ]);
        expect(repository.saveCallCount, isZero);
        final latestState = container.read(captureQuickEntryControllerProvider);
        expect(latestState.failure, isA<ValidationFailure>());
      },
    );
  });
}
