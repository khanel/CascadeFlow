import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/use_cases/file_capture_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FileCaptureItem', () {
    late Timestamp now;
    late List<DomainEvent> publishedEvents;
    late FileCaptureItem useCase;

    setUp(() {
      now = Timestamp(DateTime.utc(2025));
      publishedEvents = <DomainEvent>[];
      useCase = FileCaptureItem(
        nowProvider: () => now,
        publishEvent: publishedEvents.add,
      );
    });

    test('moves capture item to filed status and emits event', () {
      // ARRANGE
      final createdAt = Timestamp(DateTime.utc(2024, 12, 31));
      final item = CaptureItem.create(
        id: EntityId('capture-001'),
        content: 'File me',
        context: CaptureContext(
          source: CaptureSource.quickCapture,
          channel: 'quick',
        ),
        createdAt: createdAt,
      );

      // ACT
      final result = useCase(
        request: FileCaptureItemRequest(item: item),
      );

      // ASSERT
      expect(result, isA<SuccessResult<CaptureItem, Failure>>());
      final success = result as SuccessResult<CaptureItem, Failure>;
      final filed = success.value;
      expect(filed.status, CaptureStatus.filed);
      expect(filed.createdAt, createdAt);
      expect(filed.updatedAt, now);
      expect(publishedEvents, hasLength(1));

      final event = publishedEvents.single as CaptureItemFiled;
      expect(event.captureId, item.id);
      expect(event.summary, 'File me');
      expect(event.occurredOn, now);
    });

    test('returns domain failure when item already filed', () {
      // ARRANGE
      final filedItem = CaptureItem.create(
        id: EntityId('capture-filed'),
        content: 'Already filed',
        context: CaptureContext(
          source: CaptureSource.quickCapture,
          channel: 'quick',
        ),
        createdAt: now,
        status: CaptureStatus.filed,
      );

      // ACT
      final result = useCase(
        request: FileCaptureItemRequest(item: filedItem),
      );

      // ASSERT
      expect(result, isA<FailureResult<CaptureItem, Failure>>());
      final failure = result as FailureResult<CaptureItem, Failure>;
      expect(failure.failure, isA<DomainFailure>());
      expect(publishedEvents, isEmpty);
    });
  });
}
