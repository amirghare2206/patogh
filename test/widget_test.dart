import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patogh/app.dart';

void main() {
  testWidgets('Patogh reservation home renders', (tester) async {
    await tester.pumpWidget(const PatoghApp());
    await tester.pumpAndSettle();

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('رزرو پاتوق'), findsOneWidget);
  });
}