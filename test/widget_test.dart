import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patogh/app.dart';

void main() {
  testWidgets('Patogh app boots', (tester) async {
    await tester.pumpWidget(const PatoghApp());
    await tester.pump();

    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
