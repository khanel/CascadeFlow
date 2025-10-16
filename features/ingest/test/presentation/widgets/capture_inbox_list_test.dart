import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:cascade_flow_ingest/presentation/widgets/capture_inbox_list.dart';
import 'package:cascade_flow_ingest/shared/capture_inbox_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/capture_test_data.dart';

void main() {
  group('CaptureInboxList', () {
    testWidgets('shows loading indicator while inbox loads', (tester) async {
      final completer = Completer<List<CaptureItem>>();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(
              _StubCaptureRepository(
                onLoadInbox: ({limit, startAfter}) => completer.future,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );

      expect(
        find.byKey(CaptureInboxListKeys.loadingIndicator),
        findsOneWidget,
      );

      completer.complete(<CaptureItem>[]);
      await tester.pump();
      await tester.pump();
    });

    testWidgets('renders empty state when there are no inbox items', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(
              _StubCaptureRepository(
                onLoadInbox: ({limit, startAfter}) async => <CaptureItem>[],
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(CaptureInboxListKeys.emptyState), findsOneWidget);
    });

    testWidgets('renders inbox items using the provided data', (tester) async {
      final items = <CaptureItem>[
        buildTestCaptureItem(
          id: 'capture-1',
          content: 'Draft meeting notes',
          channel: 'keyboard',
          createdMicros: 100,
          updatedMicros: 150,
        ),
        buildTestCaptureItem(
          id: 'capture-2',
          content: 'Sync project roadmap',
          channel: 'integration',
          createdMicros: 200,
          updatedMicros: 250,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(
              _StubCaptureRepository(
                onLoadInbox: ({limit, startAfter}) async => items,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.byKey(CaptureInboxListKeys.listView), findsOneWidget);
      expect(find.text('Draft meeting notes'), findsOneWidget);
      expect(find.text('Sync project roadmap'), findsOneWidget);
    });

    testWidgets('renders error state when provider throws', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(
              _StubCaptureRepository(
                onLoadInbox: ({limit, startAfter}) =>
                    Future<List<CaptureItem>>.error(Exception('boom')),
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.textContaining('Failed to load inbox'), findsOneWidget);
    });

    testWidgets('loads next page when scrolled near the end', (
      tester,
    ) async {
      final firstPage = List<CaptureItem>.generate(
        CaptureInboxConstants.defaultBatchSize,
        (index) => buildTestCaptureItem(
          id: 'capture-${index + 1}',
          createdMicros: index,
          updatedMicros: index,
        ),
      );
      final remainingItems = List<CaptureItem>.generate(
        5,
        (index) => buildTestCaptureItem(
          id: 'capture-${CaptureInboxConstants.defaultBatchSize + index + 1}',
          createdMicros: CaptureInboxConstants.defaultBatchSize + index,
          updatedMicros: CaptureInboxConstants.defaultBatchSize + index,
        ),
      );
      final loads = <({int? limit, EntityId? startAfter})>[];
      final repository = _StubCaptureRepository(
        onLoadInbox: ({limit, startAfter}) async {
          loads.add((limit: limit, startAfter: startAfter));
          if (startAfter == null) {
            return firstPage;
          }
          return remainingItems;
        },
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump();

      final listFinder = find.byKey(CaptureInboxListKeys.listView);
      expect(listFinder, findsOneWidget);
      expect(loads.length, 1);

      await tester.dragUntilVisible(
        find.byKey(CaptureInboxListKeys.itemTile(firstPage.last.id.value)),
        listFinder,
        const Offset(0, -200),
      );
      await tester.pumpAndSettle();

      expect(loads.length, greaterThanOrEqualTo(2));
      final secondLoad = loads.last;
      expect(secondLoad.limit, equals(CaptureInboxConstants.defaultBatchSize));
      expect(secondLoad.startAfter, equals(firstPage.last.id));
    });

    testWidgets('shows file dialog on long press and files item', (
      tester,
    ) async {
      final item = buildTestCaptureItem(
        id: 'capture-1',
        content: 'Draft meeting notes',
      );
      final repository = _StubCaptureRepository(
        onLoadInbox: ({limit, startAfter}) async => [item],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tileFinder = find.byKey(
        CaptureInboxListKeys.itemTile(item.id.value),
      );
      expect(tileFinder, findsOneWidget);

      await tester.longPress(tileFinder);
      await tester.pumpAndSettle();

      final fileButtonFinder = find.text('File');
      expect(fileButtonFinder, findsOneWidget);

      await tester.tap(fileButtonFinder);
      await tester.pumpAndSettle();

      expect(repository.savedItems.length, 1);
      final savedItem = repository.savedItems.first;
      expect(savedItem.id, item.id);
      expect(savedItem.status, CaptureStatus.filed);
    });

    testWidgets('filters inbox items by capture source', (tester) async {
      final items = <CaptureItem>[
        buildTestCaptureItem(
          id: 'capture-1',
          content: 'Quick entry item',
        ),
        buildTestCaptureItem(
          id: 'capture-2',
          content: 'Automation item',
          source: CaptureSource.automation,
          channel: 'automation_flow',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(
              _StubCaptureRepository(
                onLoadInbox: ({limit, startAfter}) async => items,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Quick entry item'), findsOneWidget);
      expect(find.text('Automation item'), findsOneWidget);

      final automationChip = find.text('Automation');
      expect(automationChip, findsOneWidget);

      await tester.tap(automationChip);
      await tester.pumpAndSettle();

      expect(find.text('Automation item'), findsOneWidget);
      expect(find.text('Quick entry item'), findsNothing);
    });

    testWidgets('filters inbox items by capture channel', (tester) async {
      final items = <CaptureItem>[
        buildTestCaptureItem(
          id: 'capture-1',
          content: 'Keyboard capture',
          channel: 'keyboard',
        ),
        buildTestCaptureItem(
          id: 'capture-2',
          content: 'Voice capture',
          source: CaptureSource.voice,
          channel: 'voice_memo',
        ),
        buildTestCaptureItem(
          id: 'capture-3',
          content: 'Integration capture',
          source: CaptureSource.automation,
          channel: 'integration_event',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(
              _StubCaptureRepository(
                onLoadInbox: ({limit, startAfter}) async => items,
              ),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: CaptureInboxList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Keyboard capture'), findsOneWidget);
      expect(find.text('Voice capture'), findsOneWidget);
      expect(find.text('Integration capture'), findsOneWidget);

      final channelChip = find.text('integration_event');
      expect(channelChip, findsOneWidget);

      await tester.tap(channelChip);
      await tester.pumpAndSettle();

      expect(find.text('Integration capture'), findsOneWidget);
      expect(find.text('Keyboard capture'), findsNothing);
      expect(find.text('Voice capture'), findsNothing);
    });
  });
}

class _StubCaptureRepository implements CaptureRepository {
  _StubCaptureRepository({
    required this.onLoadInbox,
  });

  final Future<List<CaptureItem>> Function({
    int? limit,
    EntityId? startAfter,
  })
  onLoadInbox;

  final List<CaptureItem> savedItems = [];

  @override
  Future<void> save(CaptureItem item) async {
    savedItems.add(item);
  }

  @override
  Future<void> delete(EntityId id) async {}

  @override
  Future<List<CaptureItem>> loadInbox({
    int? limit,
    EntityId? startAfter,
  }) {
    return onLoadInbox(
      limit: limit,
      startAfter: startAfter,
    );
  }
}
