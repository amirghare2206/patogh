import 'package:flutter_test/flutter_test.dart';
import 'package:patogh/app.dart';

void main() {
  testWidgets('Patogh home page loads', (WidgetTester tester) async {
    await tester.pumpWidget(const PatoghApp());
    expect(find.text('امروز کجا بریم؟'), findsOneWidget);
  });
}
