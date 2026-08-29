import 'package:flutter_test/flutter_test.dart';
import 'package:vinvoice_pro/app.dart';

void main() {
  testWidgets('VInvoice Pro app starts', (WidgetTester tester) async {
    await tester.pumpWidget(const VInvoiceApp());

    expect(find.text('VInvoice Pro'), findsOneWidget);
  });
}
