import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:cascade_flow_ingest/presentation/widgets/capture_inbox_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/capture_test_data.dart';

void main() {
  testWidgets('renders capture items returned by the repository',
      (WidgetTester tester) async {
    // ARRANGE
    final repository = _RecordingCaptureRepository()
      ..inboxItems = <CaptureItem>[
        buildTestCaptureItem(
          id: 'capture-1',
          content: 'Draft project outline',
          createdMicros: 1,
          updatedMicros: 1,
        ),
        buildTestCaptureItem(
          id: 'capture-2',
          content: 'Plan weekly review',
          createdMicros: 2,
          updatedMicros: 2,
        ),
      ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          captureRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CaptureInboxList()),
        ),
      ),
    );

    // Loading state
    expect(find.byKey(CaptureInboxListKeys.loadingIndicator), findsOneWidget);

    // ACT
    await tester.pump();

    // ASSERT
    expect(find.byKey(CaptureInboxListKeys.loadingIndicator), findsNothing);
    expect(find.byKey(CaptureInboxListKeys.emptyState), findsNothing);
    expect(find.byKey(CaptureInboxListKeys.listView), findsOneWidget);
    expect(find.text('Draft project outline'), findsOneWidget);
    expect(find.text('Plan weekly review'), findsOneWidget);
  });

  testWidgets('shows empty placeholder when inbox is clear',
      (WidgetTester tester) async {
    // ARRANGE
    final repository = _RecordingCaptureRepository();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          captureRepositoryProvider.overrideWithValue(repository),
        ],
        child: const MaterialApp(
          home: Scaffold(body: CaptureInboxList()),
        ),
      ),
    );

    // ACT
    await tester.pump();

    // ASSERT
    expect(find.byKey(CaptureInboxListKeys.listView), findsNothing);
    expect(find.byKey(CaptureInboxListKeys.emptyState), findsOneWidget);
    expect(find.textContaining('inbox is clear', findRichText: true),
        findsOneWidget);
  });
}

class _RecordingCaptureRepository implements CaptureRepository {
  List<CaptureItem> inboxItems = <CaptureItem>[];

  @override
  Future<void> save(CaptureItem item) async {}

  @override
  Future<List<CaptureItem>> loadInbox() async => inboxItems;

  @override
  Future<void> delete(EntityId id) async {}
}
