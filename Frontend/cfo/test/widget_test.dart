import 'package:flutter_test/flutter_test.dart';
import 'package:cfo/app.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const CfoApp());
    expect(find.text('The Scalable CFO'), findsOneWidget);
  });
}
