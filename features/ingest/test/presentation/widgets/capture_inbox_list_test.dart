import 'dart:async';

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
        captureInboxDefaultBatchSize,
        (index) => buildTestCaptureItem(
          id: 'capture-${index + 1}',
          createdMicros: index,
          updatedMicros: index,
        ),
      );
      final remainingItems = List<CaptureItem>.generate(
        5,
        (index) => buildTestCaptureItem(
          id: 'capture-${captureInboxDefaultBatchSize + index + 1}',
          createdMicros: captureInboxDefaultBatchSize + index,
          updatedMicros: captureInboxDefaultBatchSize + index,
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
      expect(secondLoad.limit, equals(captureInboxDefaultBatchSize));
      expect(secondLoad.startAfter, equals(firstPage.last.id));
    });

    testWidgets('shows file dialog on long press and files item',
        (tester) async {
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

      final tileFinder =
          find.byKey(CaptureInboxListKeys.itemTile(item.id.value));
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
  });
}

class _StubCaptureRepository implements CaptureRepository {
  _StubCaptureRepository({
    required this.onLoadInbox,
  });

  final Future<List<CaptureItem>> Function({
    int? limit,
    EntityId? startAfter,
  }) onLoadInbox;

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
