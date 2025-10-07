import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/use_cases/archive_capture_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArchiveCaptureItem', () {
    late Timestamp now;
    late List<DomainEvent> publishedEvents;
    late ArchiveCaptureItem useCase;

    setUp(() {
      now = Timestamp(DateTime.utc(2025));
      publishedEvents = <DomainEvent>[];
      useCase = ArchiveCaptureItem(
        nowProvider: () => now,
        publishEvent: publishedEvents.add,
      );
    });

    test('moves capture item to archived status and emits event', () {
      // ARRANGE
      final createdAt = Timestamp(DateTime.utc(2024, 12, 31));
      final item = CaptureItem.create(
        id: EntityId('capture-001'),
        content: 'Archive me',
        context: CaptureContext(
          source: CaptureSource.quickCapture,
          channel: 'quick',
        ),
        createdAt: createdAt,
      );

      // ACT
      final result = useCase(
        request: ArchiveCaptureItemRequest(item: item),
      );

      // ASSERT
      expect(result, isA<SuccessResult<CaptureItem, Failure>>());
      final success = result as SuccessResult<CaptureItem, Failure>;
      final archived = success.value;
      expect(archived.status, CaptureStatus.archived);
      expect(archived.createdAt, createdAt);
      expect(archived.updatedAt, now);
      expect(publishedEvents, hasLength(1));

      final event = publishedEvents.single as CaptureItemArchived;
      expect(event.captureId, item.id);
      expect(event.summary, 'Archive me');
      expect(event.occurredOn, now);
    });

    test('returns domain failure when item already archived', () {
      // ARRANGE
      final archivedItem = CaptureItem.create(
        id: EntityId('capture-archived'),
        content: 'Already archived',
        context: CaptureContext(
          source: CaptureSource.quickCapture,
          channel: 'quick',
        ),
        createdAt: now,
        status: CaptureStatus.archived,
      );

      // ACT
      final result = useCase(
        request: ArchiveCaptureItemRequest(item: archivedItem),
      );

      // ASSERT
      expect(result, isA<FailureResult<CaptureItem, Failure>>());
      final failure = result as FailureResult<CaptureItem, Failure>;
      expect(failure.failure, isA<DomainFailure>());
      expect(publishedEvents, isEmpty);
    });
  });
}
