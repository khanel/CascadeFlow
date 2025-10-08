import 'package:cascade_flow_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const String _captureDetailsRoutePath = '/capture/details';

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
      final captureTab = find.text('Capture');
      final planTab = find.text('Plan');
      final capturePlaceholderFinder = find.text('Capture placeholder');
      final captureDetailsFinder = find.text('Capture details placeholder');
      final planPlaceholderFinder = find.text('Plan placeholder');

      // ARRANGE: load app and ensure capture branch root is visible
      await tester.pumpWidget(const CascadeFlowApp());
      await _pumpUntilVisible(
        tester,
        capturePlaceholderFinder,
      );

      final BuildContext captureContext =
          tester.element(capturePlaceholderFinder);

      // ACT: navigate into capture details via router and switch tabs
      GoRouter.of(captureContext).go(_captureDetailsRoutePath);
      await _pumpUntilVisible(
        tester,
        captureDetailsFinder,
      );

      await tester.tap(planTab);
      await tester.pumpAndSettle();

      // ASSERT: plan branch is visible and capture details hidden
      expect(planPlaceholderFinder, findsOneWidget);
      expect(captureDetailsFinder, findsNothing);

      // ACT: switch back to capture tab (should preserve stack)
      await tester.tap(captureTab);
      await tester.pumpAndSettle();

      // ASSERT: capture details restored when returning to branch
      expect(captureDetailsFinder, findsOneWidget);

      // ACT: reselect capture tab to trigger stack reset
      await tester.tap(captureTab);
      await tester.pumpAndSettle();

      // ASSERT: reselecting capture resets stack to root screen
      expect(capturePlaceholderFinder, findsOneWidget);
      expect(captureDetailsFinder, findsNothing);
    },
  );

  testWidgets(
    'Each navigation branch exposes placeholder detail route',
    (tester) async {
      await tester.pumpWidget(const CascadeFlowApp());
      await tester.pump();

      final materialAppFinder = find.byType(MaterialApp);
      final materialApp = tester.widget<MaterialApp>(materialAppFinder);
      final routerConfig = materialApp.routerConfig;

      expect(routerConfig, isA<GoRouter>());
      if (routerConfig is! GoRouter) {
        return;
      }

      final routes = routerConfig.configuration.routes;
      expect(routes, hasLength(1));

      final rootRoute = routes.single;
      expect(rootRoute, isA<StatefulShellRoute>());
      if (rootRoute is! StatefulShellRoute) {
        return;
      }

      final navigationBarFinder = find.byType(NavigationBar);
      final navigationBar = tester.widget<NavigationBar>(navigationBarFinder);
      final destinations =
          navigationBar.destinations.cast<NavigationDestination>();

      expect(destinations, hasLength(rootRoute.branches.length));

      for (var index = 0; index < rootRoute.branches.length; index++) {
        final branch = rootRoute.branches[index];
        final destination = destinations[index];
        final branchRoutes = branch.routes.whereType<GoRoute>().toList();

        expect(branchRoutes, hasLength(1));
        final branchRoute = branchRoutes.single;

        final detailRoutes = branchRoute.routes.whereType<GoRoute>().toList();
        expect(detailRoutes, hasLength(1));

        await _verifyBranchDetailRoute(
          tester,
          routerConfig,
          destination,
          branchRoute,
          detailRoutes.single,
        );
      }
    },
  );
}

Future<void> _pumpUntilVisible(WidgetTester tester, Finder finder) async {
  const timeout = Duration(seconds: 2);
  final end = DateTime.now().add(timeout);
  while (DateTime.now().isBefore(end)) {
    await tester.pump();
    if (finder.evaluate().isNotEmpty) {
      return;
    }
  }

  fail('Finder $finder not visible after $timeout.');
}

Future<void> _verifyBranchDetailRoute(
  WidgetTester tester,
  GoRouter router,
  NavigationDestination destination,
  GoRoute branchRoute,
  GoRoute detailRoute,
) async {
  final label = destination.label;
  final rootFinder = find.text('$label placeholder');
  final detailFinder = find.text('$label details placeholder');

  router.go(branchRoute.path);
  await tester.pumpAndSettle();
  expect(rootFinder, findsOneWidget);

  final detailPath = '${branchRoute.path}/${detailRoute.path}';
  router.go(detailPath);
  await tester.pumpAndSettle();
  expect(detailFinder, findsOneWidget);

  router.go(branchRoute.path);
  await tester.pumpAndSettle();
  expect(rootFinder, findsOneWidget);
}
