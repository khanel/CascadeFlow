import 'package:cascade_flow_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  testWidgets('MyApp uses StatefulShellRoute with six navigation branches',
      (tester) async {
    await tester.pumpWidget(const CascadeFlowApp());

    final materialAppFinder = find.byType(MaterialApp);
    expect(materialAppFinder, findsOneWidget);

    final materialApp = tester.widget<MaterialApp>(materialAppFinder);
    final routerConfig = materialApp.routerConfig;

    expect(routerConfig, isA<GoRouter>());
    if (routerConfig is! GoRouter) {
      return;
    }

    final goRouter = routerConfig;
    final routes = goRouter.configuration.routes;
    expect(routes, hasLength(1));

    final rootRoute = routes.single;
    expect(rootRoute, isA<StatefulShellRoute>());
    if (rootRoute is! StatefulShellRoute) {
      return;
    }

    expect(rootRoute.branches, hasLength(6));
  });

  testWidgets(
    'Switching tabs preserves branch stacks while reselecting resets to root',
    (tester) async {
      // ARRANGE: load app and ensure capture branch root is visible
      await tester.pumpWidget(const CascadeFlowApp());
      await _pumpUntilVisible(
        tester,
        find.text('Capture placeholder'),
      );

      final BuildContext captureContext =
          tester.element(find.text('Capture placeholder'));

      // ACT: navigate into capture details via router and switch tabs
      GoRouter.of(captureContext).go('/capture/details');
      await _pumpUntilVisible(
        tester,
        find.text('Capture details placeholder'),
      );

      await tester.tap(find.text('Plan'));
      await tester.pumpAndSettle();

      // ASSERT: plan branch is visible and capture details hidden
      expect(find.text('Plan placeholder'), findsOneWidget);
      expect(find.text('Capture details placeholder'), findsNothing);

      // ACT: switch back to capture tab (should preserve stack)
      // ACT: reselect capture tab to trigger stack reset
      await tester.tap(find.text('Capture'));
      await tester.pumpAndSettle();

      // ASSERT: capture details restored when returning to branch
      expect(find.text('Capture details placeholder'), findsOneWidget);

      await tester.tap(find.text('Capture'));
      await tester.pumpAndSettle();

      // ASSERT: reselecting capture resets stack to root screen
      expect(find.text('Capture placeholder'), findsOneWidget);
      expect(find.text('Capture details placeholder'), findsNothing);
    },
  );
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  const Duration timeout = Duration(seconds: 2);
  final DateTime end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Finder $finder not visible after $timeout.');
}
