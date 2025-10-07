import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/data/hive/capture_item_hive_model.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureItemHiveModel', () {
    late Timestamp createdAt;
    late Timestamp updatedAt;
    late CaptureItem domain;

    setUp(() {
      createdAt = Timestamp(DateTime.utc(2025));
      updatedAt = Timestamp(DateTime.utc(2025, 1, 2));
      domain = CaptureItem.create(
        id: EntityId('capture-101'),
        content: 'Hive content',
        context: CaptureContext(
          source: CaptureSource.quickCapture,
          channel: 'quick_sheet',
        ),
        createdAt: createdAt,
        updatedAt: updatedAt,
        metadata: const {'foo_bar': 'baz'},
      );
    });

    test('round trips between domain entity and hive model', () {
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
      expect(model.metadata, const {'foo_bar': 'baz'});

      expect(restored, equals(domain));
    });
  });
}
