import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/archive_capture_item.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:cascade_flow_ingest/presentation/widgets/capture_inbox_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../test_utils/capture_test_data.dart';

/// Comprehensive tests for archive and delete gestures in capture inbox list.
///
/// These tests verify Dismissible swipe gestures work correctly.
void main() {
  group('CaptureInboxList Archive Gestures', () {
    testWidgets(
      'displays archive background when swiping item to the right',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Archive me',
              createdMicros: 1,
              updatedMicros: 1,
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
        await tester.pump();

        // ACT - Swipe right partially
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(100, 0),
        );
        await tester.pump();

        // ASSERT
        expect(find.text('Archive'), findsOneWidget);
        expect(find.byIcon(Icons.archive), findsOneWidget);
      },
    );

    testWidgets(
      'archives item when swiped far enough to the right',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Archive me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ];

        final archiveUseCase = _RecordingArchiveCaptureItem();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
              archiveCaptureItemUseCaseProvider.overrideWithValue(
                archiveUseCase,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: CaptureInboxList()),
            ),
          ),
        );
        await tester.pump();

        // ACT - Swipe far enough to dismiss
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        // ASSERT
        expect(archiveUseCase.archivedItems, hasLength(1));
        expect(archiveUseCase.archivedItems.first.id.value, 'capture-1');
        expect(repository.savedItems, hasLength(1));
        expect(repository.savedItems.first.status, CaptureStatus.archived);
      },
    );

    testWidgets(
      'displays success snackbar with undo after archiving',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Archive me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ];

        final archiveUseCase = _RecordingArchiveCaptureItem();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
              archiveCaptureItemUseCaseProvider.overrideWithValue(
                archiveUseCase,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: CaptureInboxList()),
            ),
          ),
        );
        await tester.pump();

        // ACT
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.textContaining('archived', findRichText: true),
          findsOneWidget,
        );
        expect(find.widgetWithText(SnackBarAction, 'Undo'), findsOneWidget);
      },
    );

    testWidgets(
      'restores item to inbox when undo is tapped',
      (WidgetTester tester) async {
        // ARRANGE
        final originalItem = buildTestCaptureItem(
          id: 'capture-1',
          content: 'Archive me',
          createdMicros: 1,
          updatedMicros: 1,
        );

        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[originalItem];

        final archiveUseCase = _RecordingArchiveCaptureItem();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
              archiveCaptureItemUseCaseProvider.overrideWithValue(
                archiveUseCase,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: CaptureInboxList()),
            ),
          ),
        );
        await tester.pump();

        // Archive item
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        // ACT - Tap undo
        await tester.tap(find.widgetWithText(SnackBarAction, 'Undo'));
        repository.inboxItems.add(originalItem);
        await tester.pumpAndSettle();

        // ASSERT
        expect(repository.savedItems.last.status, CaptureStatus.inbox);
      },
    );

    testWidgets(
      'displays error snackbar when archive fails',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Archive me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ];

        final archiveUseCase = _RecordingArchiveCaptureItem()
          ..shouldFail = true
          ..failure = const DomainFailure(message: 'Archive failed');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
              archiveCaptureItemUseCaseProvider.overrideWithValue(
                archiveUseCase,
              ),
            ],
            child: const MaterialApp(
              home: Scaffold(body: CaptureInboxList()),
            ),
          ),
        );
        await tester.pump();

        // ACT
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.textContaining('failed', findRichText: true),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'allows archiving multiple items sequentially',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'First',
              createdMicros: 1,
              updatedMicros: 1,
            ),
            buildTestCaptureItem(
              id: 'capture-2',
              content: 'Second',
              createdMicros: 2,
              updatedMicros: 2,
            ),
            buildTestCaptureItem(
              id: 'capture-3',
              content: 'Third',
              createdMicros: 3,
              updatedMicros: 3,
            ),
          ];

        final archiveUseCase = _RecordingArchiveCaptureItem();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
              archiveCaptureItemUseCaseProvider.overrideWithValue(
                archiveUseCase,
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT - Archive first item
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();
        repository.inboxItems.removeAt(0);
        await tester.pump();

        // Archive second item
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-2')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();
        repository.inboxItems.removeAt(0);
        await tester.pump();

        // ASSERT
        expect(archiveUseCase.archivedItems, hasLength(2));
        expect(find.text('Third'), findsOneWidget);
      },
    );
  });

  group('CaptureInboxList Delete Gestures', () {
    testWidgets(
      'displays delete background when swiping item to the left',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Delete me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT - Swipe left partially
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(-100, 0),
        );
        await tester.pump();

        // ASSERT
        expect(find.text('Delete'), findsOneWidget);
        expect(find.byIcon(Icons.delete), findsOneWidget);
      },
    );

    testWidgets(
      'shows confirmation dialog when swiped far enough to delete',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Delete me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.byType(AlertDialog), findsOneWidget);
        expect(find.text('Delete capture?'), findsOneWidget);
        expect(
          find.textContaining('cannot be undone', findRichText: true),
          findsOneWidget,
        );
        expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
        expect(find.widgetWithText(TextButton, 'Delete'), findsOneWidget);
      },
    );

    testWidgets(
      'cancels delete when cancel is tapped in dialog',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Delete me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.text('Delete me'), findsOneWidget);
        expect(repository.deletedIds, isEmpty);
        expect(find.byType(AlertDialog), findsNothing);
      },
    );

    testWidgets(
      'deletes item when confirmed in dialog',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Delete me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
            buildTestCaptureItem(
              id: 'capture-2',
              content: 'Keep me',
              createdMicros: 2,
              updatedMicros: 2,
            ),
          ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();
        repository.inboxItems.removeWhere((i) => i.id.value == 'capture-1');
        await tester.pump();

        // ASSERT
        expect(repository.deletedIds, hasLength(1));
        expect(repository.deletedIds.first.value, 'capture-1');
      },
    );

    testWidgets(
      'displays error snackbar when delete fails',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Delete me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ]
          ..shouldFailDelete = true
          ..deleteError = Exception('Delete failed');

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();

        // ASSERT
        expect(find.byType(SnackBar), findsOneWidget);
        expect(
          find.textContaining('failed', findRichText: true),
          findsOneWidget,
        );
        expect(find.text('Delete me'), findsOneWidget);
      },
    );

    testWidgets(
      'allows deleting multiple items sequentially',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'First',
              createdMicros: 1,
              updatedMicros: 1,
            ),
            buildTestCaptureItem(
              id: 'capture-2',
              content: 'Second',
              createdMicros: 2,
              updatedMicros: 2,
            ),
            buildTestCaptureItem(
              id: 'capture-3',
              content: 'Third',
              createdMicros: 3,
              updatedMicros: 3,
            ),
          ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT - Delete first item
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();
        repository.inboxItems.removeAt(0);
        await tester.pump();

        // Delete second item
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-2')),
          const Offset(-500, 0),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(TextButton, 'Delete'));
        await tester.pumpAndSettle();
        repository.inboxItems.removeAt(0);
        await tester.pump();

        // ASSERT
        expect(repository.deletedIds, hasLength(2));
        expect(find.text('Third'), findsOneWidget);
      },
    );
  });

  group('CaptureInboxList Gesture Interactions', () {
    testWidgets(
      'tap on item does not trigger archive or delete',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'Tap me',
              createdMicros: 1,
              updatedMicros: 1,
            ),
          ];

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // ACT
        await tester.tap(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
        );
        await tester.pumpAndSettle();

        // ASSERT
        expect(repository.deletedIds, isEmpty);
        expect(repository.savedItems, isEmpty);
        expect(find.text('Tap me'), findsOneWidget);
      },
    );

    testWidgets(
      'swipe gestures work after archiving items',
      (WidgetTester tester) async {
        // ARRANGE
        final repository = _RecordingCaptureRepository()
          ..inboxItems = <CaptureItem>[
            buildTestCaptureItem(
              id: 'capture-1',
              content: 'First',
              createdMicros: 1,
              updatedMicros: 1,
            ),
            buildTestCaptureItem(
              id: 'capture-2',
              content: 'Second',
              createdMicros: 2,
              updatedMicros: 2,
            ),
          ];

        final archiveUseCase = _RecordingArchiveCaptureItem();

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              captureRepositoryProvider.overrideWithValue(repository),
              archiveCaptureItemUseCaseProvider.overrideWithValue(
                archiveUseCase,
              ),
            ],
            child: const MaterialApp(home: Scaffold(body: CaptureInboxList())),
          ),
        );
        await tester.pump();

        // Archive first item
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-1')),
          const Offset(500, 0),
        );
        await tester.pumpAndSettle();
        repository.inboxItems.removeAt(0);
        await tester.pump();

        // ACT - Try to delete second item
        await tester.drag(
          find.byKey(CaptureInboxListKeys.itemTile('capture-2')),
          const Offset(-100, 0),
        );
        await tester.pump();

        // ASSERT - Delete gesture still works
        expect(find.byIcon(Icons.delete), findsOneWidget);
      },
    );
  });
}

// Test doubles

/// Recording repository implementation for testing.
class _RecordingCaptureRepository implements CaptureRepository {
  List<CaptureItem> inboxItems = <CaptureItem>[];
  List<CaptureItem> savedItems = <CaptureItem>[];
  List<EntityId> deletedIds = <EntityId>[];
  bool shouldFailDelete = false;
  Exception? deleteError;

  @override
  Future<void> save(CaptureItem item) async {
    savedItems.add(item);
    final index = inboxItems.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      inboxItems[index] = item;
    } else {
      inboxItems.add(item);
    }
  }

  @override
  Future<List<CaptureItem>> loadInbox({
    int? limit,
    EntityId? startAfter,
  }) async {
    final inbox = inboxItems
        .where((i) => i.status == CaptureStatus.inbox)
        .toList();
    final startIndex = startAfter == null
        ? -1
        : inbox.indexWhere((item) => item.id == startAfter);
    final sliced = startIndex >= 0 && startIndex + 1 < inbox.length
        ? inbox.sublist(startIndex + 1)
        : startIndex >= 0
        ? <CaptureItem>[]
        : inbox;
    final limited = limit == null ? sliced : sliced.take(limit).toList();
    return List.unmodifiable(limited);
  }

  @override
  Future<void> delete(EntityId id) async {
    if (shouldFailDelete) {
      throw deleteError ?? Exception('Delete failed');
    }
    deletedIds.add(id);
    inboxItems.removeWhere((i) => i.id == id);
  }
}

/// Recording archive use case implementation for testing.
class _RecordingArchiveCaptureItem implements ArchiveCaptureItem {
  List<CaptureItem> archivedItems = <CaptureItem>[];
  bool shouldFail = false;
  Failure? failure;
  CaptureItem? archivedItem;

  @override
  Result<CaptureItem, Failure> call({
    required ArchiveCaptureItemRequest request,
  }) {
    if (shouldFail) {
      return FailureResult(failure ?? const DomainFailure(message: 'Failed'));
    }

    final archived =
        archivedItem ??
        request.item.copyWith(
          status: CaptureStatus.archived,
          updatedAt: Timestamp(DateTime.now().toUtc()),
        );

    archivedItems.add(request.item);
    return SuccessResult(archived);
  }
}
