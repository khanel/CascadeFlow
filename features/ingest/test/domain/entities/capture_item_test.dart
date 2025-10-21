import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureItem.create', () {
    test('normalises content and applies defaults', () {
      // Arrange
      final createdAt = Timestamp(DateTime.utc(2025, 10, 1, 12));
      final context = CaptureContext(
        source: CaptureSource.quickCapture,
        channel: 'keyboard',
      );
      const content = '   File the design idea  ';
      const metadata = {'source_app': 'workspace', 'note_id': 'note_42'};

      // Act
      final item = CaptureItem.create(
        id: EntityId('capture_123'),
        content: content,
        context: context,
        createdAt: createdAt,
        metadata: metadata,
      );

      // Assert
      expect(item.id, EntityId('capture_123'));
      expect(item.content, 'File the design idea');
      expect(item.context.source, CaptureSource.quickCapture);
      expect(item.context.channel, 'keyboard');
      expect(item.status, CaptureStatus.inbox);
      expect(item.createdAt, createdAt);
      expect(item.updatedAt, createdAt);
      expect(item.metadata, containsPair('source_app', 'workspace'));
    });

    test('throws when content is blank', () {
      // Arrange
      final createdAt = Timestamp(DateTime.utc(2025, 10, 1, 12));
      final context = CaptureContext(
        source: CaptureSource.quickCapture,
        channel: 'keyboard',
      );

      // Act
      void act() => CaptureItem.create(
        id: EntityId.generate(),
        content: '   ',
        context: context,
        createdAt: createdAt,
      );

      // Assert
      expect(
        act,
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.message,
            'message',
            contains('content'),
          ),
        ),
      );
    });

    test('throws when metadata keys are not snake_case', () {
      // Arrange
      final createdAt = Timestamp(DateTime.utc(2025, 10, 1, 12));
      final context = CaptureContext(
        source: CaptureSource.quickCapture,
        channel: 'keyboard',
      );
      const metadata = {'BadKey': 'value'};

      // Act
      void act() => CaptureItem.create(
        id: EntityId.generate(),
        content: 'Check bad metadata',
        context: context,
        createdAt: createdAt,
        metadata: metadata,
      );

      // Assert
      expect(
        act,
        throwsA(
          isA<ValidationFailure>().having(
            (failure) => failure.message,
            'message',
            contains('metadata'),
          ),
        ),
      );
    });
  });
}
