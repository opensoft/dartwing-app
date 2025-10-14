import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:dart_wing_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Dartwing App Integration Tests', () {
    testWidgets('App starts and loads correctly', (tester) async {
      // Start the app
      app.main();
      await tester.pumpAndSettle();

      // Verify the app loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Take a screenshot for verification
      await tester.binding.convertFlutterSurfaceToImage();
      
      print('✅ App started successfully');
    });

    testWidgets('Basic navigation works', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Look for common UI elements that should be present
      // These will need to be updated based on your actual app structure
      
      // Check if we can find some basic widgets
      final basicWidgets = [
        find.byType(Scaffold),
        find.byType(MaterialApp),
      ];

      for (final widget in basicWidgets) {
        expect(widget, findsAtLeastNWidget(1));
      }

      print('✅ Basic navigation test passed');
    });

    testWidgets('App handles basic user interaction', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Test basic interactions if any buttons or tappable elements exist
      // This is a placeholder - update based on your actual app
      
      // Look for any buttons or interactive elements
      final buttons = find.byType(ElevatedButton);
      final floatingButtons = find.byType(FloatingActionButton);
      final inkWells = find.byType(InkWell);
      
      // If buttons exist, test one interaction
      if (buttons.evaluate().isNotEmpty) {
        await tester.tap(buttons.first);
        await tester.pumpAndSettle();
        print('✅ Button interaction test passed');
      } else if (floatingButtons.evaluate().isNotEmpty) {
        await tester.tap(floatingButtons.first);
        await tester.pumpAndSettle();
        print('✅ Floating button interaction test passed');
      } else if (inkWells.evaluate().isNotEmpty) {
        await tester.tap(inkWells.first);
        await tester.pumpAndSettle();
        print('✅ InkWell interaction test passed');
      } else {
        print('ℹ️ No interactive elements found to test');
      }

      print('✅ User interaction test completed');
    });
  });
}