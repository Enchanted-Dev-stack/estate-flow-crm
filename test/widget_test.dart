import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';

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
    await tester.scrollUntilVisible(
      find.text('Photos'),
      500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Manage'), findsNothing);
    await tester.scrollUntilVisible(
      find.text('Basic Details'),
      -500,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
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

  testWidgets('map nav opens immersive location detail route', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EstateFlowApp());

    final bottomNav = tester.getRect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_BottomNavBar',
      ),
    );
    await tester.tapAt(Offset(bottomNav.left + 213, bottomNav.center.dy));
    await tester.pumpAndSettle();

    expect(find.byType(FlutterMap), findsOneWidget);
    expect(find.text('Location detail'), findsOneWidget);
    expect(find.text('1 Hospital'), findsNothing);
    expect(find.text('2 Gas stations'), findsNothing);
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == '_BottomNavBar',
      ),
      findsNothing,
    );
  });

  testWidgets('popping map route restores shell navigation', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const EstateFlowApp());

    final bottomNavFinder = find.byWidgetPredicate(
      (widget) => widget.runtimeType.toString() == '_BottomNavBar',
    );
    final bottomNav = tester.getRect(bottomNavFinder);

    await tester.tapAt(Offset(bottomNav.left + 213, bottomNav.center.dy));
    await tester.pumpAndSettle();
    expect(find.byType(FlutterMap), findsOneWidget);
    expect(bottomNavFinder, findsNothing);

    Navigator.of(tester.element(find.byType(MapScreen))).pop();
    await tester.pumpAndSettle();

    expect(find.text('EstateFlow'), findsOneWidget);
    expect(bottomNavFinder, findsOneWidget);
  });
}
