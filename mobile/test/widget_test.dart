// Serviqo Foundation widget tests.
// Tests splash screen responsiveness across different viewports.
import 'package:flutter/material.dart';
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

    // Pump initial frame to render splash screen
    await tester.pump();

    // Splash screen should appear (has 'SERVIQO' text)
    expect(find.text('SERVIQO'), findsOneWidget);
    expect(find.text('Verified Local Service Marketplace'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Advance time past the splash delay to complete timer
    await tester.pump(const Duration(milliseconds: 1500));
  });

  testWidgets('ServiqoApp can be pumped without exceptions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: ServiqoApp()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1500));

    // No exceptions thrown = test passes
    expect(tester.takeException(), isNull);
  });

  testWidgets('Splash screen does not overflow in small viewport (mobile emulation / landscape / keyboard)', (WidgetTester tester) async {
    // Emulate small viewport (e.g. 360x120 small window / keyboard open)
    tester.view.physicalSize = const Size(360, 120);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(child: ServiqoApp()),
    );
    await tester.pump();

    // Verify text renders and no RenderFlex overflow occurs
    expect(find.text('SERVIQO'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 1500));
  });

  testWidgets('Splash screen renders properly on desktop widescreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1920, 1080);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(child: ServiqoApp()),
    );
    await tester.pump();

    expect(find.text('SERVIQO'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pump(const Duration(milliseconds: 1500));
  });
}
