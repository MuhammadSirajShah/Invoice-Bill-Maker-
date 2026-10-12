
import 'package:flutter_test/flutter_test.dart';
import 'package:invoice_bill_maker/main.dart';

void main() {
  testWidgets('Invoice Bill Maker app launches', (
      WidgetTester tester,
      ) async {
    await tester.pumpWidget(
      const InvoiceBillMakerApp(),
    );

    expect(
      find.text('Invoice & Bill Maker'),
      findsOneWidget,
    );
  });
}
