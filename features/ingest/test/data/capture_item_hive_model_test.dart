import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureItemHiveModel', () {
    test('round trips between domain entity and hive model', () {
      // ARRANGE
      final createdAt = Timestamp(DateTime.utc(2025, 1, 1));
      final updatedAt = Timestamp(DateTime.utc(2025, 1, 2));
      final domain = CaptureItem.create(
        id: EntityId('capture-101'),
        content: 'Hive content',
        context: CaptureContext(
          source: CaptureSource.quickCapture,
          channel: 'quick_sheet',
        ),
        createdAt: createdAt,
        updatedAt: updatedAt,
        metadata: {'foo_bar': 'baz'},
        status: CaptureStatus.inbox,
      );

      // ACT
      final model = CaptureItemHiveModel.fromDomain(domain);
      final restored = model.toDomain();

      // ASSERT
      expect(model.id, domain.id.value);
      expect(model.content, domain.content);
      expect(model.channel, domain.context.channel);
      expect(model.source, domain.context.source.name);
      expect(model.createdAtMicros, createdAt.value.microsecondsSinceEpoch);
      expect(model.updatedAtMicros, updatedAt.value.microsecondsSinceEpoch);
      expect(model.status, domain.status.name);
      expect(model.metadata, {'foo_bar': 'baz'});

      expect(restored, equals(domain));
    });
  });
}
