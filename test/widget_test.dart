import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:estateflow_crm/main.dart';

void main() {
  testWidgets('CRM shell renders dashboard', (WidgetTester tester) async {
    await tester.pumpWidget(const EstateFlowApp());

    expect(find.text('EstateFlow'), findsOneWidget);
    expect(
      find.text('Pipeline value across 46 active opportunities'),
      findsOneWidget,
    );
  });

  testWidgets('quick create saves property into local list', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EstateFlowApp());

    final bottomNav = tester.getRect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_BottomNavBar',
      ),
    );
    await tester.tapAt(Offset(bottomNav.left + 153, bottomNav.center.dy));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('quick-create-button')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Add Property'));
    await tester.pumpAndSettle();

    expect(find.text('Basic Details'), findsOneWidget);
    expect(find.text('Save Property'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .controller
          .text,
      isEmpty,
    );

    await tester.tap(find.text('Rent'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(EditableText).first, 'Palm Test Villa');
    await tester.tap(find.text('Save Property'));
    await tester.pumpAndSettle();

    expect(find.text('Properties'), findsOneWidget);
    expect(find.text('Palm Test Villa'), findsOneWidget);
    expect(find.text('Rental'), findsWidgets);
  });
}
