import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureQuickEntry', () {
    late EntityId captureId;
    late Timestamp now;
    late List<DomainEvent> publishedEvents;
    late CaptureQuickEntry useCase;

    setUp(() {
      captureId = EntityId('capture-123');
      now = Timestamp(DateTime.utc(2025));
      publishedEvents = <DomainEvent>[];
      useCase = CaptureQuickEntry(
        idGenerator: () => captureId,
        nowProvider: () => now,
        publishEvent: publishedEvents.add,
      );
    });

    test('creates capture item with defaults and publishes event', () async {
      // ARRANGE

      // ACT
      final result = useCase(
        request: const CaptureQuickEntryRequest(
          rawContent: '  Capture idea ',
          channel: 'quick_sheet',
          metadata: {'foo_bar': ' baz '},
        ),
      );

      // ASSERT
      expect(result, isA<SuccessResult<CaptureItem, Failure>>());
      final success = result as SuccessResult<CaptureItem, Failure>;
      final item = success.value;
      expect(item.id, captureId);
      expect(item.content, 'Capture idea');
      expect(item.context.source, CaptureSource.quickCapture);
      expect(item.context.channel, 'quick_sheet');
      expect(item.status, CaptureStatus.inbox);
      expect(item.createdAt, now);
      expect(item.updatedAt, now);
      expect(item.metadata, {'foo_bar': 'baz'});

      expect(publishedEvents, hasLength(1));
      final event = publishedEvents.single as CaptureItemFiled;
      expect(event.captureId, captureId);
      expect(event.summary, 'Capture idea');
      expect(event.occurredOn, now);
    });

    test('returns validation failure when content is blank', () async {
      // ARRANGE
      captureId = EntityId('capture-001');

      // ACT
      final result = useCase(
        request: const CaptureQuickEntryRequest(
          rawContent: '   ',
        ),
      );

      // ASSERT
      expect(result, isA<FailureResult<CaptureItem, Failure>>());
      final failure = result as FailureResult<CaptureItem, Failure>;
      expect(failure.failure, isA<ValidationFailure>());
      expect(publishedEvents, isEmpty);
    });
  });
}
