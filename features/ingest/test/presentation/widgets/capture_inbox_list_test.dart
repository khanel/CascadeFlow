import 'dart:async';

import 'package:cascade_flow_ingest/domain/entities/capture_item.dart';
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
            captureInboxItemsProvider.overrideWith(
              (ref) => completer.future,
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
      await tester.pumpAndSettle();
    });

    testWidgets('renders empty state when there are no inbox items', (
      tester,
    ) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureInboxItemsProvider.overrideWith(
              (ref) async => <CaptureItem>[],
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
            captureInboxItemsProvider.overrideWith(
              (ref) async => items,
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

      expect(find.byKey(CaptureInboxListKeys.listView), findsOneWidget);
      expect(find.text('Draft meeting notes'), findsOneWidget);
      expect(find.text('Sync project roadmap'), findsOneWidget);
    });

    testWidgets('renders error state when provider throws', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            captureInboxItemsProvider.overrideWith(
              (ref) => Future<List<CaptureItem>>.error(
                Exception('boom'),
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

      expect(find.textContaining('Failed to load inbox'), findsOneWidget);
    });
  });
}
