import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:perfume_shopping_app/screens/splash/splash_screen.dart';

void main() {
  testWidgets('App renders SplashScreen UI cleanly', (WidgetTester tester) async {
    // Ignore network image errors in widget test environment
    final originalOnError = FlutterError.onError;
    FlutterError.onError = (FlutterErrorDetails details) {
      if (details.exception.toString().contains('NetworkImageLoadException') ||
          details.exception.toString().contains('HTTP request failed')) {
        return;
      }
      originalOnError?.call(details);
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('PARFUMERIE'), findsOneWidget);

    // Pump timer for transition
    await tester.pump(const Duration(seconds: 3));

    FlutterError.onError = originalOnError;
  });
}
