import 'package:flutter_test/flutter_test.dart';

import 'package:estateflow_crm/main.dart';

void main() {
  testWidgets('CRM shell renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const EstateFlowApp());

    expect(find.text('EstateFlow'), findsOneWidget);
    expect(find.text('Pipeline value across 46 active opportunities'), findsOneWidget);
  });
}
