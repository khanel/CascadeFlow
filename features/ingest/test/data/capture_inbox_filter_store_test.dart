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
      await store.save(
        const CaptureInboxFilter(channel: 'keyboard'),
      );

      await store.clear();
      final restored = await store.load();

      expect(restored, CaptureInboxFilter.empty);
    });
  });
}
