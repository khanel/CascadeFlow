import 'package:cascade_flow_app/main.dart';
import 'package:cascade_flow_infrastructure/cascade_flow_infrastructure.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'CascadeBootstrap exposes infrastructure providers via ProviderScope',
    (WidgetTester tester) async {
      // ARRANGE: pump the bootstrap widget without additional wrappers.
      await tester.pumpWidget(const CascadeBootstrap());

      // ASSERT: ProviderScope is mounted and surfaces shared
      // infrastructure providers.
      final materialAppFinder = find.byType(MaterialApp);
      expect(materialAppFinder, findsOneWidget);

      final BuildContext materialAppContext = tester.element(materialAppFinder);

      final container = ProviderScope.containerOf(materialAppContext);
      expect(container.read(loggerProvider), isA<PrintLogger>());
      expect(container.read(hiveInitializerProvider), isNotNull);
    },
  );
}
