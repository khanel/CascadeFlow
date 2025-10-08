import 'package:cascade_flow_app/main.dart';
import 'package:cascade_flow_presentation/cascade_flow_presentation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const String _captureDetailsRoutePath = '/capture/details';

void main() {
  testWidgets('MyApp uses StatefulShellRoute with six navigation branches', (
    tester,
  ) async {
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
      final captureRootFinder = find.byKey(
        PresentationScaffoldKeys.root('capture'),
      );
      final captureDetailsFinder = find.byKey(
        PresentationScaffoldKeys.detail('capture'),
      );
      final planRootFinder = find.byKey(PresentationScaffoldKeys.root('plan'));
      final captureWorkspaceText = find.text(
        PresentationScaffoldMessages.workspace('Capture'),
      );
      final planWorkspaceText = find.text(
        PresentationScaffoldMessages.workspace('Plan'),
      );

      // ARRANGE: load app and ensure capture branch root is visible
      await tester.pumpWidget(const CascadeFlowApp());
      await _pumpUntilVisible(
        tester,
        captureRootFinder,
      );

      final BuildContext captureContext = tester.element(captureRootFinder);

      // ACT: navigate into capture details via router and switch tabs
      GoRouter.of(captureContext).go(_captureDetailsRoutePath);
      await _pumpUntilVisible(
        tester,
        captureDetailsFinder,
      );

      await tester.tap(planTab);
      await tester.pumpAndSettle();

      // ASSERT: plan branch is visible and capture details hidden
      expect(planRootFinder, findsOneWidget);
      expect(planWorkspaceText, findsOneWidget);
      expect(captureDetailsFinder, findsNothing);

      // ACT: switch back to capture tab (should preserve stack)
      await tester.tap(captureTab);
      await tester.pumpAndSettle();

      // ASSERT: capture details restored when returning to branch
      expect(captureDetailsFinder, findsOneWidget);
      expect(
        find.text(PresentationScaffoldMessages.detail('Capture')),
        findsOneWidget,
      );

      // ACT: reselect capture tab to trigger stack reset
      await tester.tap(captureTab);
      await tester.pumpAndSettle();

      // ASSERT: reselecting capture resets stack to root screen
      expect(captureRootFinder, findsOneWidget);
      expect(captureWorkspaceText, findsOneWidget);
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
      final destinations = navigationBar.destinations
          .cast<NavigationDestination>();

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
  final branchId = _branchIdFromPath(branchRoute.path);
  final rootFinder = find.byKey(PresentationScaffoldKeys.root(branchId));
  final rootTextFinder = find.text(
    PresentationScaffoldMessages.workspace(label),
  );
  final detailFinder = find.byKey(PresentationScaffoldKeys.detail(branchId));
  final detailTextFinder = find.text(
    PresentationScaffoldMessages.detail(label),
  );

  router.go(branchRoute.path);
  await tester.pumpAndSettle();
  expect(rootFinder, findsOneWidget);
  expect(rootTextFinder, findsOneWidget);

  final detailPath = '${branchRoute.path}/${detailRoute.path}';
  router.go(detailPath);
  await tester.pumpAndSettle();
  expect(detailFinder, findsOneWidget);
  expect(detailTextFinder, findsOneWidget);

  router.go(branchRoute.path);
  await tester.pumpAndSettle();
  expect(rootFinder, findsOneWidget);
  expect(rootTextFinder, findsOneWidget);
}

String _branchIdFromPath(String path) =>
    path.startsWith('/') ? path.substring(1) : path;
