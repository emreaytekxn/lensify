import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:kawaru/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('End-to-End Application UI Test', (WidgetTester tester) async {
    // 1. Launch the app
    app.main();
    
    // Wait for the splash screen animations and Isar initialization
    await tester.pump(const Duration(seconds: 4));

    // Wait if we are on Lock Screen (Test robot doesn't know your PIN!)
    // So the test will only succeed if you temporarily disable App Lock in Settings.

    // 2. Check if we are on Onboarding, Lock Screen, or Main Screen
    // For this test, let's assume we are either on Main Screen or we can find the 'Kawaru' text
    expect(find.textContaining('Kawaru'), findsWidgets);

    // If there is an app bar with tools, tap on Tools tab
    final toolsTab = find.byIcon(Icons.grid_view); // Adjust icon if needed based on bottom navigation
    if (toolsTab.evaluate().isNotEmpty) {
      await tester.tap(toolsTab);
      await tester.pump(const Duration(milliseconds: 500));

      // Check if some tools are visible
      expect(find.textContaining('Arka Plan Silici'), findsWidgets);
      expect(find.textContaining('PDF Birleştir'), findsWidgets);
      expect(find.textContaining('Ses Kaydı & Çeviri'), findsWidgets);
    }

    // 3. Go to Settings tab
    final settingsTab = find.byIcon(Icons.settings);
    if (settingsTab.evaluate().isNotEmpty) {
      await tester.tap(settingsTab);
      await tester.pump(const Duration(milliseconds: 500));

      // Check for signature
      expect(find.text('Powered by'), findsWidgets);
      expect(find.text('N. Emre Aytekin'), findsWidgets);
    }

    // 4. Go back to Home tab
    final homeTab = find.byIcon(Icons.folder);
    if (homeTab.evaluate().isNotEmpty) {
      await tester.tap(homeTab);
      await tester.pump(const Duration(milliseconds: 500));

      // Tap on the FAB to add a folder or document
      final fab = find.byType(FloatingActionButton);
      if (fab.evaluate().isNotEmpty) {
        await tester.tap(fab);
        await tester.pump(const Duration(milliseconds: 500));
        // Just checking if dialog opens
        expect(find.byType(AlertDialog), findsWidgets);
        
        // Tap Cancel
        final cancelBtn = find.text('İptal');
        if (cancelBtn.evaluate().isNotEmpty) {
          await tester.tap(cancelBtn);
          await tester.pump(const Duration(milliseconds: 500));
        }
      }
    }

    // End of basic navigation test
    // Note: Interacting with camera and file pickers in integration tests requires native UI automators.
    // So this test verifies that the app mounts, dependencies load, and all screens navigate without crashing.
  });
}
