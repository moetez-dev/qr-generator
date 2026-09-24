import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:qr_generator/main.dart';
import 'package:qr_generator/providers/app_provider.dart';
import 'package:qr_generator/providers/history_provider.dart';

void main() {
  group('QR Generator App', () {
    testWidgets('App launches and shows Home screen with title',
        (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Verify app title is shown
      expect(find.text('QR Generator'), findsOneWidget);
    });

    testWidgets('Shows navigation bar with 3 destinations',
        (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Verify navigation destinations
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('History'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('Shows text input field', (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Verify input field exists
      expect(find.byType(TextFormField), findsOneWidget);
      expect(find.text('Enter URL or text'), findsOneWidget);
    });

    testWidgets('Shows generate button', (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      expect(find.text('Generate QR Code'), findsOneWidget);
    });

    testWidgets('Empty input shows validation error',
        (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Tap generate without entering text
      await tester.tap(find.text('Generate QR Code'));
      await tester.pumpAndSettle();

      // Verify validation error
      expect(find.text('Please enter some text or a URL'), findsOneWidget);
    });

    testWidgets('Can navigate to History tab', (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Tap History navigation
      await tester.tap(find.text('History'));
      await tester.pumpAndSettle();

      // Verify empty state message
      expect(find.text('No history yet'), findsOneWidget);
    });

    testWidgets('Can navigate to Settings tab', (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Tap Settings navigation
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Verify settings content
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('About'), findsOneWidget);
      expect(find.text('Version 1.0.0'), findsOneWidget);
      expect(find.text('Privacy'), findsOneWidget);
    });

    testWidgets('Can enter text and generate QR',
        (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Enter text
      await tester.enterText(
          find.byType(TextFormField), 'https://example.com');
      await tester.pumpAndSettle();

      // Tap generate
      await tester.tap(find.text('Generate QR Code'));
      await tester.pumpAndSettle();

      // Verify action buttons appear (QR was generated)
      expect(find.text('Save'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);
      expect(find.text('Copy'), findsOneWidget);
      expect(find.text('Clear'), findsOneWidget);
    });

    testWidgets('Clear button resets the QR', (WidgetTester tester) async {
      await tester.pumpWidget(const QrGeneratorApp());
      await tester.pumpAndSettle();

      // Enter text and generate
      await tester.enterText(
          find.byType(TextFormField), 'https://example.com');
      await tester.tap(find.text('Generate QR Code'));
      await tester.pumpAndSettle();

      // Tap clear
      await tester.tap(find.text('Clear'));
      await tester.pumpAndSettle();

      // Verify QR is gone (action buttons should be gone)
      expect(find.text('Save'), findsNothing);
      expect(find.text('Share'), findsNothing);
    });
  });
}
