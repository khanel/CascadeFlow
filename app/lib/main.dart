import 'package:cascade_flow_app/src/bootstrap/cascade_app_theme.dart';
import 'package:cascade_flow_app/src/bootstrap/cascade_layout_scope.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(const CascadeBootstrap());
}

/// Wraps the application with global provider overrides shared across slices.
class CascadeBootstrap extends StatelessWidget {
  const CascadeBootstrap({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        loggerProvider.overrideWithValue(const PrintLogger()),
      ],
      child: const CascadeFlowApp(),
    );
  }
}

/// Top-level router configuration for the app.
final GoRouter _router = GoRouter(
  initialLocation: _Paths.capture,
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder:
          (
            BuildContext context,
            GoRouterState state,
            StatefulNavigationShell navigationShell,
          ) => _AppShell(navigationShell: navigationShell),
      branches: <StatefulShellBranch>[
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: _Paths.capture,
              builder: (BuildContext context, GoRouterState state) =>
                  const _CapturePage(),
              routes: <RouteBase>[
                GoRoute(
                  path: 'details',
                  builder: (BuildContext context, GoRouterState state) =>
                      const _CaptureDetailsPage(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: _Paths.plan,
              builder: (BuildContext context, GoRouterState state) =>
                  const _PlanPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: _Paths.execute,
              builder: (BuildContext context, GoRouterState state) =>
                  const _ExecutePage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: _Paths.review,
              builder: (BuildContext context, GoRouterState state) =>
                  const _ReviewPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: _Paths.insights,
              builder: (BuildContext context, GoRouterState state) =>
                  const _InsightsPage(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: <RouteBase>[
            GoRoute(
              path: _Paths.settings,
              builder: (BuildContext context, GoRouterState state) =>
                  const _SettingsPage(),
            ),
          ],
        ),
      ],
    ),
  ],
);

/// Root widget that wires theming and routing.
class CascadeFlowApp extends StatelessWidget {
  /// Creates the CascadeFlow root application widget.
  const CascadeFlowApp({super.key});

  CascadeLayoutData _layoutDataFor(BuildContext context) {
    final width = MediaQuery.maybeOf(context)?.size.width ?? 0;

    const breakpoints = CascadeLayoutBreakpoints.standard;
    return CascadeLayoutData(
      breakpoints: breakpoints,
      size: breakpoints.resolve(width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'CascadeFlow',
      debugShowCheckedModeBanner: false,
      theme: CascadeAppTheme.light,
      darkTheme: CascadeAppTheme.dark,
      builder: (BuildContext context, Widget? child) {
        final layoutData = _layoutDataFor(context);
        final Widget content = child ?? const SizedBox.shrink();

        return CascadeLayoutScope(
          data: layoutData,
          child: content,
        );
      },
      routerConfig: _router,
    );
  }
}

/// Hosts the tabbed shell navigation backed by [StatefulNavigationShell].
class _AppShell extends StatefulWidget {
  const _AppShell({required this.navigationShell});

  final StatefulNavigationShell navigationShell;

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  void _onDestinationSelected(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const <NavigationDestination>[
          NavigationDestination(
            icon: Icon(Icons.inbox_outlined),
            selectedIcon: Icon(Icons.inbox),
            label: 'Capture',
          ),
          NavigationDestination(
            icon: Icon(Icons.event_note_outlined),
            selectedIcon: Icon(Icons.event_note),
            label: 'Plan',
          ),
          NavigationDestination(
            icon: Icon(Icons.play_circle_outline),
            selectedIcon: Icon(Icons.play_circle),
            label: 'Execute',
          ),
          NavigationDestination(
            icon: Icon(Icons.rate_review_outlined),
            selectedIcon: Icon(Icons.rate_review),
            label: 'Review',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _CapturePage extends StatelessWidget {
  const _CapturePage();

  @override
  Widget build(BuildContext context) => const _PlaceholderView('Capture');
}

class _CaptureDetailsPage extends StatelessWidget {
  const _CaptureDetailsPage();

  @override
  Widget build(BuildContext context) =>
      const _PlaceholderView('Capture details');
}

class _PlanPage extends StatelessWidget {
  const _PlanPage();

  @override
  Widget build(BuildContext context) => const _PlaceholderView('Plan');
}

class _ExecutePage extends StatelessWidget {
  const _ExecutePage();

  @override
  Widget build(BuildContext context) => const _PlaceholderView('Execute');
}

class _ReviewPage extends StatelessWidget {
  const _ReviewPage();

  @override
  Widget build(BuildContext context) => const _PlaceholderView('Review');
}

class _InsightsPage extends StatelessWidget {
  const _InsightsPage();

  @override
  Widget build(BuildContext context) => const _PlaceholderView('Insights');
}

class _SettingsPage extends StatelessWidget {
  const _SettingsPage();

  @override
  Widget build(BuildContext context) => const _PlaceholderView('Settings');
}

class _PlaceholderView extends StatelessWidget {
  const _PlaceholderView(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Text('$title placeholder'),
      ),
    );
  }
}

/// Route path constants for primary navigation branches.
abstract final class _Paths {
  static const String capture = '/capture';
  static const String plan = '/plan';
  static const String execute = '/execute';
  static const String review = '/review';
  static const String insights = '/insights';
  static const String settings = '/settings';
}
