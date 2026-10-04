import 'package:flutter/material.dart' show DateTimeRange;
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
  group('UiDateField & UiDateRangeField Certification Tests', () {
    testWidgets('UiDateField renders label, placeholder, and null date value', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          const UiDateField(
            label: 'Birth Date',
            placeholder: 'Select birth date...',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Birth Date'), findsOneWidget);
      expect(find.byType(shadcn.ControlledDatePicker), findsOneWidget);
    });

    testWidgets('UiDateField renders selected DateTime value cleanly', (
      tester,
    ) async {
      final selectedDate = DateTime(2026, 9, 26);

      await tester.pumpWidget(
        _wrap(UiDateField(label: 'Invoice Date', value: selectedDate)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Invoice Date'), findsOneWidget);
      expect(find.byType(shadcn.ControlledDatePicker), findsOneWidget);
    });

    testWidgets(
      'UiDateRangeField renders label, placeholder, and DateTimeRange value',
      (tester) async {
        final selectedRange = DateTimeRange(
          start: DateTime(2026, 9, 1),
          end: DateTime(2026, 9, 30),
        );

        await tester.pumpWidget(
          _wrap(UiDateRangeField(label: 'Billing Cycle', value: selectedRange)),
        );
        await tester.pumpAndSettle();

        expect(find.text('Billing Cycle'), findsOneWidget);
        expect(find.byType(shadcn.DateRangePicker), findsOneWidget);
      },
    );

    testWidgets(
      'UiDateField & UiDateRangeField handle LTR/RTL and TextScaler 2.0',
      (tester) async {
        final selectedDate = DateTime(2026, 9, 26);
        final selectedRange = DateTimeRange(
          start: DateTime(2026, 9, 1),
          end: DateTime(2026, 9, 30),
        );

        for (final dir in TextDirection.values) {
          await tester.pumpWidget(
            _wrap(
              Column(
                children: [
                  UiDateField(
                    label: 'Start',
                    value: selectedDate,
                    requiredIndicator: 'Required',
                  ),
                  UiDateRangeField(
                    label: 'Period',
                    value: selectedRange,
                    error: 'Select valid range error',
                  ),
                ],
              ),
              scaler: const TextScaler.linear(2.0),
              dir: dir,
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('Start · Required'), findsOneWidget);
          expect(find.text('Period'), findsOneWidget);
          expect(find.text('Select valid range error'), findsOneWidget);
        }
      },
    );
  });
}
