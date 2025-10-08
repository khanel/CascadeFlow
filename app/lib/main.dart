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
  /// Creates a bootstrap wrapper supplying global provider overrides.
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
      branches: _navigationBranches
          .map(
            (_NavigationBranchDefinition branch) => StatefulShellBranch(
              routes: <RouteBase>[branch.route],
            ),
          )
          .toList(),
    ),
  ],
);

/// Root widget that wires theming and routing.
class CascadeFlowApp extends StatelessWidget {
  /// Creates the CascadeFlow root application widget.
  const CascadeFlowApp({super.key});

  /// Resolves layout data for the current `MediaQuery` context.
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
        final content = child ?? const SizedBox.shrink();

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
        destinations: _navigationBranches
            .map((branch) => branch.destination)
            .toList(growable: false),
      ),
    );
  }
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
  static const String detailSegment = 'details';
}

const List<_NavigationBranchDefinition> _navigationBranches =
    <_NavigationBranchDefinition>[
  _NavigationBranchDefinition(
    path: _Paths.capture,
    label: 'Capture',
    icon: Icons.inbox_outlined,
    selectedIcon: Icons.inbox,
  ),
  _NavigationBranchDefinition(
    path: _Paths.plan,
    label: 'Plan',
    icon: Icons.event_note_outlined,
    selectedIcon: Icons.event_note,
  ),
  _NavigationBranchDefinition(
    path: _Paths.execute,
    label: 'Execute',
    icon: Icons.play_circle_outline,
    selectedIcon: Icons.play_circle,
  ),
  _NavigationBranchDefinition(
    path: _Paths.review,
    label: 'Review',
    icon: Icons.rate_review_outlined,
    selectedIcon: Icons.rate_review,
  ),
  _NavigationBranchDefinition(
    path: _Paths.insights,
    label: 'Insights',
    icon: Icons.insights_outlined,
    selectedIcon: Icons.insights,
  ),
  _NavigationBranchDefinition(
    path: _Paths.settings,
    label: 'Settings',
    icon: Icons.settings_outlined,
    selectedIcon: Icons.settings,
  ),
];

class _NavigationBranchDefinition {
  const _NavigationBranchDefinition({
    required this.path,
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });

  final String path;
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  String get _detailTitle => '$label details';

  GoRoute get route => GoRoute(
        path: path,
        builder: (BuildContext context, GoRouterState state) =>
            _PlaceholderView(label),
        routes: <RouteBase>[
          GoRoute(
            path: _Paths.detailSegment,
            builder: (BuildContext context, GoRouterState state) =>
                _PlaceholderView(_detailTitle),
          ),
        ],
      );

  NavigationDestination get destination => NavigationDestination(
        icon: Icon(icon),
        selectedIcon: Icon(selectedIcon),
        label: label,
      );

}
