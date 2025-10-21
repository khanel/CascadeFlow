import 'package:cascade_flow_infrastructure/storage.dart';
import 'package:cascade_flow_ingest/data/preferences/capture_inbox_filter_store.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CaptureInboxFilterStore', () {
    test('returns empty filter when nothing persisted', () async {
      final storage = InMemorySecureStorage();
      final store = CaptureInboxFilterStore(secureStorage: storage);

      final filter = await store.load();

      expect(filter, CaptureInboxFilter.empty);
    });

    test('restores previously persisted filter snapshot', () async {
      final storage = InMemorySecureStorage();
      final store = CaptureInboxFilterStore(secureStorage: storage);
      const filter = CaptureInboxFilter(
        source: CaptureSource.automation,
        channel: 'voice_memos',
      );

      await store.save(filter);
      final restored = await store.load();

      expect(restored.channel, 'voice_memos');
      expect(restored.source, CaptureSource.automation);
    });

    test('ignores corrupted payloads by returning empty filter', () async {
      final storage = InMemorySecureStorage();
      final store = CaptureInboxFilterStore(secureStorage: storage);
      await storage.write(key: 'captureInboxFilter', value: '{invalid json');

      final restored = await store.load();

      expect(restored, CaptureInboxFilter.empty);
    });

    test('clears stored snapshot', () async {
      final storage = InMemorySecureStorage();
      final store = CaptureInboxFilterStore(secureStorage: storage);
      await store.save(const CaptureInboxFilter(channel: 'keyboard'));

      await store.clear();
      final restored = await store.load();

      expect(restored, CaptureInboxFilter.empty);
    });

    group('Filter Presets', () {
      test('returns empty list when no presets persisted', () async {
        final storage = InMemorySecureStorage();
        final store = CaptureInboxFilterStore(secureStorage: storage);

        final presets = await store.loadPresets();

        expect(presets, isEmpty);
      });

      test('saves and loads a preset correctly', () async {
        final storage = InMemorySecureStorage();
        final store = CaptureInboxFilterStore(secureStorage: storage);
        const preset = CaptureFilterPreset(
          name: 'Quick Captures',
          filter: CaptureInboxFilter.empty,
        );

        await store.savePreset(preset);
        final presets = await store.loadPresets();

        expect(presets.length, 1);
        expect(presets[0].name, 'Quick Captures');
        expect(presets[0].filter.source, isNull);
      });

      test('updates existing preset when saving with same name', () async {
        final storage = InMemorySecureStorage();
        final store = CaptureInboxFilterStore(secureStorage: storage);
        const initialPreset = CaptureFilterPreset(
          name: 'Test Preset',
          filter: CaptureInboxFilter.empty,
        );
        const updatedPreset = CaptureFilterPreset(
          name: 'Test Preset',
          filter: CaptureInboxFilter(channel: 'updated'),
        );

        await store.savePreset(initialPreset);
        await store.savePreset(updatedPreset);
        final presets = await store.loadPresets();

        expect(presets.length, 1);
        expect(presets[0].filter.channel, 'updated');
      });

      test('deletes a preset by name', () async {
        final storage = InMemorySecureStorage();
        final store = CaptureInboxFilterStore(secureStorage: storage);
        await store.savePreset(
          const CaptureFilterPreset(
            name: 'Preset 1',
            filter: CaptureInboxFilter.empty,
          ),
        );
        await store.savePreset(
          const CaptureFilterPreset(
            name: 'Preset 2',
            filter: CaptureInboxFilter.empty,
          ),
        );

        await store.deletePreset('Preset 1');
        final presets = await store.loadPresets();

        expect(presets.length, 1);
        expect(presets[0].name, 'Preset 2');
      });

      test('clears all presets', () async {
        final storage = InMemorySecureStorage();
        final store = CaptureInboxFilterStore(secureStorage: storage);
        await store.savePreset(
          const CaptureFilterPreset(
            name: 'Preset 1',
            filter: CaptureInboxFilter.empty,
          ),
        );

        await store.clearPresets();
        final presets = await store.loadPresets();

        expect(presets, isEmpty);
      });

      test('handles corrupted preset data gracefully', () async {
        final storage = InMemorySecureStorage();
        final store = CaptureInboxFilterStore(secureStorage: storage);
        await storage.write(
          key: 'captureInboxFilterPresets',
          value: 'invalid json',
        );

        final presets = await store.loadPresets();

        expect(presets, isEmpty);
      });
    });
  });
}
