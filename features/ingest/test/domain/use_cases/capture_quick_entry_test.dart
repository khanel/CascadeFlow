import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureQuickEntry', () {
    test('creates capture item with defaults and publishes event', () async {
      // ARRANGE
      final generatedId = EntityId('capture-123');
      final now = Timestamp(DateTime.utc(2025, 1, 1));
      final publishedEvents = <DomainEvent>[];

      final useCase = CaptureQuickEntry(
        idGenerator: () => generatedId,
        nowProvider: () => now,
        publishEvent: publishedEvents.add,
      );

      // ACT
      final result = useCase(
        request: CaptureQuickEntryRequest(
          rawContent: '  Capture idea ',
          channel: 'quick_sheet',
          metadata: {'foo_bar': ' baz '},
        ),
      );

      // ASSERT
      expect(result, isA<SuccessResult<CaptureItem, Failure>>());
      final success = result as SuccessResult<CaptureItem, Failure>;
      final item = success.value;
      expect(item.id, generatedId);
      expect(item.content, 'Capture idea');
      expect(item.context.source, CaptureSource.quickCapture);
      expect(item.context.channel, 'quick_sheet');
      expect(item.status, CaptureStatus.inbox);
      expect(item.createdAt, now);
      expect(item.updatedAt, now);
      expect(item.metadata, {'foo_bar': 'baz'});

      expect(publishedEvents, hasLength(1));
      final event = publishedEvents.single as CaptureItemFiled;
      expect(event.captureId, generatedId);
      expect(event.summary, 'Capture idea');
      expect(event.occurredOn, now);
    });

    test('returns validation failure when content is blank', () async {
      // ARRANGE
      final publishedEvents = <DomainEvent>[];
      final useCase = CaptureQuickEntry(
        idGenerator: () => EntityId('capture-001'),
        nowProvider: () => Timestamp(DateTime.utc(2025, 1, 1)),
        publishEvent: publishedEvents.add,
      );

      // ACT
      final result = useCase(
        request: CaptureQuickEntryRequest(
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
