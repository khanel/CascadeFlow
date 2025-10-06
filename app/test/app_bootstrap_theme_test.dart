import 'package:cascade_flow_app/main.dart';
import 'package:cascade_flow_app/src/bootstrap/cascade_layout_scope.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CascadeFlowApp configures shared themes and adaptive layout scope',
    (WidgetTester tester) async {
      // Verifies root bootstrapping wires shared themes and responsive scope.

      // ARRANGE: mount the app shell under test.
      await tester.pumpWidget(const CascadeFlowApp());

      // ACT: no interactions required; we inspect initial configuration.

      // ASSERT: root MaterialApp is present
      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      final materialApp = tester.widget<MaterialApp>(materialAppFinder);

      expect(
        materialApp.darkTheme,
        isNotNull,
        reason: 'Root MaterialApp should expose a shared dark theme.',
      );

      expect(
        materialApp.themeMode,
        ThemeMode.system,
        reason: 'Theme mode should defer to the system preference.',
      );

      expect(
        materialApp.builder,
        isNotNull,
        reason: 'Root MaterialApp should wrap content with a layout scope.',
      );

      final layoutScopeFinder = find.byType(CascadeLayoutScope);

      expect(
        layoutScopeFinder,
        findsOneWidget,
        reason: 'Adaptive layout scope should be mounted in the tree.',
      );

      final layoutScope = tester.widget<CascadeLayoutScope>(layoutScopeFinder);
      expect(layoutScope.breakpoints, CascadeLayoutBreakpoints.standard);

      final scopeContext = tester.element(layoutScopeFinder);
      final resolvedScope = CascadeLayoutScope.of(scopeContext);
      expect(resolvedScope.size, CascadeLayoutSize.medium);
    },
  );
}
