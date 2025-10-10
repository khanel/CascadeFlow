import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:cascade_flow_ingest/presentation/widgets/capture_quick_add_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'submits quick entry, emits success, and clears the input field',
    (WidgetTester tester) async {
      // ARRANGE
      final repository = _RecordingCaptureRepository();
      final events = <DomainEvent>[];
      final useCase = CaptureQuickEntry(
        idGenerator: () => EntityId('quick-entry-test'),
        nowProvider: () => Timestamp(DateTime.utc(2025)),
        publishEvent: events.add,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
            captureQuickEntryEventPublisherProvider.overrideWithValue(
              events.add,
            ),
            captureQuickEntryUseCaseProvider.overrideWithValue(useCase),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureQuickAddSheet(),
            ),
          ),
        ),
      );

      const rawContent = '  Draft weekly recap  ';

      // ACT
      await tester.enterText(
        find.byKey(CaptureQuickAddSheetKeys.contentField),
        rawContent,
      );
      await tester.pump();
      await tester.tap(find.byKey(CaptureQuickAddSheetKeys.submitButton));
      await tester.pump(); // allow the controller to process the request

      // ASSERT
      expect(repository.savedItems, hasLength(1));
      expect(repository.savedItems.single.content, 'Draft weekly recap');
      expect(events, isNotEmpty);

      final context = tester.element(find.byType(CaptureQuickAddSheet));
      final container = ProviderScope.containerOf(context, listen: false);
      final state = container.read(captureQuickEntryControllerProvider);
      expect(state.status, CaptureQuickEntryStatus.success);

      expect(find.text('Draft weekly recap'), findsNothing);
    },
  );
}

class _RecordingCaptureRepository implements CaptureRepository {
  final List<CaptureItem> savedItems = <CaptureItem>[];

  @override
  Future<void> save(CaptureItem item) async {
    savedItems.add(item);
  }

  @override
  Future<List<CaptureItem>> loadInbox() async => <CaptureItem>[];

  @override
  Future<void> delete(EntityId id) async {}
}
