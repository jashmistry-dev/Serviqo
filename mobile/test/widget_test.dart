// Serviqo — Foundation widget tests.
// Full feature tests will be added as features are built in later steps.
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:serviqo/main.dart';

void main() {
  testWidgets('ServiqoApp starts and renders splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ServiqoApp()),
    );

    // Verify the app widget tree is built
    expect(find.byType(ServiqoApp), findsOneWidget);

    // Pump a few frames to let the router initialize
    await tester.pump();

    // Splash screen should appear (has 'SERVIQO' text)
    expect(find.text('SERVIQO'), findsOneWidget);
  });

  testWidgets('ServiqoApp can be pumped without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ServiqoApp()),
    );
    await tester.pump(const Duration(seconds: 1));

    // No exceptions thrown = test passes
    expect(tester.takeException(), isNull);
  });
}
