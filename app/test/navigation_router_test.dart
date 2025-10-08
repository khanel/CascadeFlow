import 'package:cascade_flow_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const String _captureDetailsRoutePath = '/capture/details';

const List<_BranchNavigation> _branchNavigations = <_BranchNavigation>[
  _BranchNavigation(
    tabLabel: 'Capture',
    rootText: 'Capture placeholder',
    rootRoutePath: '/capture',
    detailRoutePath: '/capture/details',
    detailText: 'Capture details placeholder',
  ),
  _BranchNavigation(
    tabLabel: 'Plan',
    rootText: 'Plan placeholder',
    rootRoutePath: '/plan',
    detailRoutePath: '/plan/details',
    detailText: 'Plan details placeholder',
  ),
  _BranchNavigation(
    tabLabel: 'Execute',
    rootText: 'Execute placeholder',
    rootRoutePath: '/execute',
    detailRoutePath: '/execute/details',
    detailText: 'Execute details placeholder',
  ),
  _BranchNavigation(
    tabLabel: 'Review',
    rootText: 'Review placeholder',
    rootRoutePath: '/review',
    detailRoutePath: '/review/details',
    detailText: 'Review details placeholder',
  ),
  _BranchNavigation(
    tabLabel: 'Insights',
    rootText: 'Insights placeholder',
    rootRoutePath: '/insights',
    detailRoutePath: '/insights/details',
    detailText: 'Insights details placeholder',
  ),
  _BranchNavigation(
    tabLabel: 'Settings',
    rootText: 'Settings placeholder',
    rootRoutePath: '/settings',
    detailRoutePath: '/settings/details',
    detailText: 'Settings details placeholder',
  ),
];

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

      for (final navigation in _branchNavigations) {
        await _verifyBranchDetailRoute(tester, routerConfig, navigation);
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
  _BranchNavigation navigation,
) async {
  final rootFinder = find.text(navigation.rootText);
  final detailFinder = find.text(navigation.detailText);

  router.go(navigation.rootRoutePath);
  await tester.pumpAndSettle();
  expect(rootFinder, findsOneWidget);

  router.go(navigation.detailRoutePath);
  await tester.pumpAndSettle();
  expect(detailFinder, findsOneWidget);

  router.go(navigation.rootRoutePath);
  await tester.pumpAndSettle();
  expect(rootFinder, findsOneWidget);
}

class _BranchNavigation {
  const _BranchNavigation({
    required this.tabLabel,
    required this.rootText,
    required this.rootRoutePath,
    required this.detailRoutePath,
    required this.detailText,
  });

  final String tabLabel;
  final String rootText;
  final String rootRoutePath;
  final String detailRoutePath;
  final String detailText;
}
