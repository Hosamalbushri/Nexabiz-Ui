import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _wrap(
  Widget child, {
  TextScaler scaler = TextScaler.noScaling,
  TextDirection dir = TextDirection.ltr,
}) {
  return shadcn.ShadcnApp(
    home: Directionality(
      textDirection: dir,
      child: MediaQuery(
        data: MediaQueryData(textScaler: scaler),
        child: shadcn.Scaffold(
          child: Padding(padding: const EdgeInsets.all(16.0), child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('UiNumberField Certification Tests', () {
    testWidgets('renders label, placeholder, and initial string value', (
      tester,
    ) async {
      final controller = TextEditingController(text: '42');
      addTearDown(controller.dispose);
      num? emittedNumber;

      await tester.pumpWidget(
        _wrap(
          UiNumberField(
            label: 'Age',
            controller: controller,
            placeholder: 'Enter age',
            onNumberChanged: (numVal) => emittedNumber = numVal,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Age'), findsOneWidget);
      expect(find.text('42'), findsOneWidget);
      expect(emittedNumber, isNull);
    });

    testWidgets(
      'preserves intermediate editing states (- , . , -.) without resetting to 0',
      (tester) async {
        final controller = TextEditingController();
        addTearDown(controller.dispose);
        num? emittedNumber = 999;

        await tester.pumpWidget(
          _wrap(
            UiNumberField(
              label: 'Amount',
              controller: controller,
              onNumberChanged: (val) => emittedNumber = val,
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Type '-'
        await tester.enterText(find.byType(EditableText), '-');
        await tester.pumpAndSettle();
        expect(controller.text, '-');
        expect(emittedNumber, isNull);

        // Type '-.'
        await tester.enterText(find.byType(EditableText), '-.');
        await tester.pumpAndSettle();
        expect(controller.text, '-.');
        expect(emittedNumber, isNull);

        // Type '-.5'
        await tester.enterText(find.byType(EditableText), '-.5');
        await tester.pumpAndSettle();
        expect(controller.text, '-.5');
        expect(emittedNumber, -0.5);
      },
    );

    testWidgets('disallows negative numbers when allowNegative is false', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          UiNumberField(
            label: 'Quantity',
            controller: controller,
            allowNegative: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), '-5');
      await tester.pumpAndSettle();

      expect(controller.text, '');
    });

    testWidgets('disallows decimal values when allowDecimals is false', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          UiNumberField(
            label: 'Count',
            controller: controller,
            allowDecimals: false,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), '12.34');
      await tester.pumpAndSettle();

      expect(controller.text, '12');
    });

    testWidgets('handles TextScaler 2.0 and LTR/RTL directionality', (
      tester,
    ) async {
      final controller = TextEditingController(text: '1234.56');
      addTearDown(controller.dispose);

      for (final dir in TextDirection.values) {
        await tester.pumpWidget(
          _wrap(
            UiNumberField(
              label: 'Price',
              controller: controller,
              requiredIndicator: 'Required',
            ),
            scaler: const TextScaler.linear(2.0),
            dir: dir,
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Price · Required'), findsOneWidget);
        expect(find.text('1234.56'), findsOneWidget);
      }
    });
  });
}
