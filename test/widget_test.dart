import 'package:flutter_test/flutter_test.dart';
import 'package:minute_match/main.dart';

void main() {
  testWidgets('App loads home screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MinuteMatchApp());
    expect(find.text('MINUTE'), findsOneWidget);
    expect(find.text('MATCH'), findsOneWidget);
  });
}
