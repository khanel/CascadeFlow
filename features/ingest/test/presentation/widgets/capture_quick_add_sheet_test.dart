import 'dart:async';

import 'package:cascade_flow_core/cascade_flow_core.dart';
import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
import 'package:cascade_flow_ingest/domain/repositories/capture_repository.dart';
import 'package:cascade_flow_ingest/domain/use_cases/capture_quick_entry.dart';
import 'package:cascade_flow_ingest/presentation/providers/capture_providers.dart';
import 'package:cascade_flow_ingest/presentation/widgets/capture_quick_add_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _RecordingCaptureRepository implements CaptureRepository {
  _RecordingCaptureRepository({Completer<void>? saveCompleter})
    : _saveCompleter = saveCompleter;

  final Completer<void>? _saveCompleter;
  final List<CaptureItem> savedItems = <CaptureItem>[];
  int saveCallCount = 0;

  @override
  Future<void> save(CaptureItem item) async {
    saveCallCount++;
    savedItems
      ..removeWhere((existing) => existing.id == item.id)
      ..add(item);
    final completer = _saveCompleter;
    if (completer != null && !completer.isCompleted) {
      await completer.future;
    }
  }

  @override
  Future<List<CaptureItem>> loadInbox({
    int? limit,
    EntityId? startAfter,
  }) async {
    final base = limit == null
        ? List<CaptureItem>.from(savedItems)
        : savedItems.take(limit).toList();
    if (startAfter == null) {
      return List.unmodifiable(base);
    }
    final index = base.indexWhere((item) => item.id == startAfter);
    if (index < 0) {
      return List.unmodifiable(base);
    }
    if (index + 1 >= base.length) {
      return const <CaptureItem>[];
    }
    final sliced = base.sublist(index + 1);
    return List.unmodifiable(sliced);
  }

  @override
  Future<void> delete(EntityId id) async {
    savedItems.removeWhere((item) => item.id == id);
  }
}

class _FailureCaptureQuickEntry extends CaptureQuickEntry {
  _FailureCaptureQuickEntry()
    : super(
        idGenerator: EntityId.generate,
        nowProvider: Timestamp.now,
        publishEvent: (_) {},
      );

  @override
  Result<CaptureItem, Failure> call({
    required CaptureQuickEntryRequest request,
  }) {
    return const FailureResult<CaptureItem, Failure>(
      DomainFailure(message: 'Capture failed'),
    );
  }
}

void main() {
  group('CaptureQuickAddSheet', () {
    testWidgets('disables submit during save and clears field after success', (
      tester,
    ) async {
      final saveCompleter = Completer<void>();
      final repository = _RecordingCaptureRepository(
        saveCompleter: saveCompleter,
      );
      final captureId = EntityId('capture-ui');
      final now = Timestamp(DateTime.utc(2025));
      final useCase = CaptureQuickEntry(
        idGenerator: () => captureId,
        nowProvider: () => now,
        publishEvent: (_) {},
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
            captureQuickEntryUseCaseProvider.overrideWithValue(useCase),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CaptureQuickAddSheet()),
          ),
        ),
      );

      final fieldFinder = find.byKey(CaptureQuickAddSheetKeys.contentField);
      final buttonFinder = find.byKey(CaptureQuickAddSheetKeys.submitButton);

      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNull);

      await tester.enterText(fieldFinder, 'Refine capture workflow');
      await tester.pump();

      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNotNull);

      await tester.tap(buttonFinder);
      await tester.pump();

      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      saveCompleter.complete();
      await tester.pump();
      await tester.pump();

      expect(repository.saveCallCount, equals(1));
      expect(repository.savedItems.single.id, equals(captureId));
      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNull);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      final field = tester.widget<TextField>(fieldFinder);
      expect(field.controller?.text ?? '', isEmpty);
    });

    testWidgets('shows snackbar when submission fails', (tester) async {
      final repository = _RecordingCaptureRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureRepositoryProvider.overrideWithValue(repository),
            captureQuickEntryUseCaseProvider.overrideWithValue(
              _FailureCaptureQuickEntry(),
            ),
          ],
          child: const MaterialApp(
            home: Scaffold(body: CaptureQuickAddSheet()),
          ),
        ),
      );

      final fieldFinder = find.byKey(CaptureQuickAddSheetKeys.contentField);
      final buttonFinder = find.byKey(CaptureQuickAddSheetKeys.submitButton);

      await tester.enterText(fieldFinder, 'Attempt failure path');
      await tester.pump();
      await tester.tap(buttonFinder);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(repository.saveCallCount, equals(0));
      expect(find.text('Capture failed'), findsOneWidget);
      expect(tester.widget<FilledButton>(buttonFinder).onPressed, isNotNull);
    });
  });
}
