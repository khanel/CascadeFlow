import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureFilterPreset', () {
    test('should create a preset with name and filter', () {
      // Arrange
      final filter = CaptureInboxFilter.empty;
      const name = 'Test Preset';

      // Act
      final preset = CaptureFilterPreset(name: name, filter: filter);

      // Assert
      expect(preset.name, name);
      expect(preset.filter, filter);
      expect(preset.createdAt, isNull);
    });

    test('should serialize to JSON correctly', () {
      // Arrange
      final filter = CaptureInboxFilter(source: CaptureSource.quickCapture);
      final createdAt = DateTime(2023, 1, 1);
      final preset = CaptureFilterPreset(
        name: 'Test Preset',
        filter: filter,
        createdAt: createdAt,
      );

      // Act
      final json = preset.toJson();

      // Assert
      expect(json['name'], 'Test Preset');
      expect(json['filter']['source'], 'quickCapture');
      expect(json['createdAt'], '2023-01-01T00:00:00.000');
    });

    test('should deserialize from JSON correctly', () {
      // Arrange
      final json = {
        'name': 'Test Preset',
        'filter': {'source': 'quickCapture'},
        'createdAt': '2023-01-01T00:00:00.000',
      };

      // Act
      final preset = CaptureFilterPreset.fromJson(json);

      // Assert
      expect(preset.name, 'Test Preset');
      expect(preset.filter.source, CaptureSource.quickCapture);
      expect(preset.createdAt, DateTime(2023, 1, 1));
    });
  });
}
