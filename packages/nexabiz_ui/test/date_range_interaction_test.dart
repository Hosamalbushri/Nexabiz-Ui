import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _host(Widget child, TextDirection direction) => shadcn.ShadcnApp(
  home: Directionality(
    textDirection: direction,
    child: shadcn.Scaffold(child: Center(child: child)),
  ),
);

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('range selects calendar days by pointer $direction', (
      tester,
    ) async {
      final initial = DateTimeRange(
        start: DateTime(2026, 10, 1),
        end: DateTime(2026, 10, 2),
      );
      final received = <DateTimeRange?>[];
      await tester.pumpWidget(
        _host(
          UiDateRangeField(
            label: 'Period',
            value: initial,
            onChanged: received.add,
          ),
          direction,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(shadcn.OutlineButton));
      await tester.pumpAndSettle();
      expect(find.byType(shadcn.DatePickerDialog), findsOneWidget);
      await tester.tap(find.widgetWithText(shadcn.CalendarItem, '10').first);
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(shadcn.CalendarItem, '11').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(received, hasLength(1));
      // Upstream extends the existing range when tapping dates after its end.
      expect(received.single!.start, DateTime(2026, 10, 1));
      expect(received.single!.end, DateTime(2026, 10, 11));
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'range adapter preserves endpoints and parent updates $direction',
      (tester) async {
        final initial = DateTimeRange(
          start: DateTime.utc(2026, 9, 1, 12, 30, 15),
          end: DateTime.utc(2026, 9, 30, 18, 45, 20),
        );
        final equalEndpoints = DateTimeRange(
          start: DateTime(2026, 10, 5, 8, 9),
          end: DateTime(2026, 10, 5, 8, 9),
        );
        var calls = 0;
        Future<void> show(DateTimeRange? value) async {
          await tester.pumpWidget(
            _host(
              UiDateRangeField(
                label: 'Period',
                value: value,
                onChanged: (_) => calls++,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        shadcn.DateTimeRange? pickerValue() => tester
            .widget<shadcn.DateRangePicker>(find.byType(shadcn.DateRangePicker))
            .value;

        await show(initial);
        expect(pickerValue(), shadcn.DateTimeRange(initial.start, initial.end));
        expect(pickerValue()!.start.isUtc, isTrue);
        expect(pickerValue()!.start.hour, 12);
        expect(pickerValue()!.end.minute, 45);
        await show(DateTimeRange(start: initial.start, end: initial.end));
        expect(calls, 0);
        await show(equalEndpoints);
        expect(
          pickerValue(),
          shadcn.DateTimeRange(equalEndpoints.start, equalEndpoints.end),
        );
        expect(calls, 0);
        await show(null);
        expect(pickerValue(), isNull);
        expect(calls, 0);
        expect(tester.takeException(), isNull);
      },
    );
    testWidgets('range adapter converts picker clearing once $direction', (
      tester,
    ) async {
      final initial = DateTimeRange(
        start: DateTime(2026, 9, 1),
        end: DateTime(2026, 9, 30),
      );
      final received = <DateTimeRange?>[];
      await tester.pumpWidget(
        _host(
          UiDateRangeField(
            label: 'Period',
            value: initial,
            onChanged: received.add,
          ),
          direction,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(shadcn.OutlineButton));
      await tester.pumpAndSettle();
      final dialog = find.byType(shadcn.DatePickerDialog);
      expect(dialog, findsOneWidget);
      tester.widget<shadcn.DatePickerDialog>(dialog).onChanged!(null);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      expect(received, [null]);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'range adapter converts actual picker selection once $direction',
      (tester) async {
        final selected = DateTimeRange(
          start: DateTime.utc(2026, 10, 1, 10, 11),
          end: DateTime.utc(2026, 10, 31, 20, 21),
        );
        final received = <DateTimeRange?>[];
        await tester.pumpWidget(
          _host(
            UiDateRangeField(label: 'Period', onChanged: received.add),
            direction,
          ),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.byType(shadcn.OutlineButton));
        await tester.pumpAndSettle();
        final dialog = find.byType(shadcn.DatePickerDialog);
        expect(dialog, findsOneWidget);
        tester.widget<shadcn.DatePickerDialog>(dialog).onChanged!(
          shadcn.CalendarValue.range(selected.start, selected.end),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(received, [selected]);
        expect(received.single!.start.isUtc, isTrue);
        expect(received.single!.start.hour, 10);
        expect(received.single!.end.minute, 21);
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final direction in TextDirection.values) {
    for (final enabled in [true, false]) {
      for (final readOnly in [false, true]) {
        testWidgets(
          'date range enabled=$enabled readOnly=$readOnly direction=$direction',
          (tester) async {
            final initial = DateTimeRange(
              start: DateTime(2026, 9, 1),
              end: DateTime(2026, 9, 30),
            );
            final changed = DateTimeRange(
              start: DateTime(2026, 10, 1),
              end: DateTime(2026, 10, 31),
            );
            var callbackCount = 0;
            DateTimeRange? lastCallbackValue;

            await tester.pumpWidget(
              _host(
                UiDateRangeField(
                  label: 'Period',
                  value: initial,
                  enabled: enabled,
                  readOnly: readOnly,
                  onChanged: (value) {
                    callbackCount++;
                    lastCallbackValue = value;
                  },
                ),
                direction,
              ),
            );
            await tester.pumpAndSettle();

            final picker = find.byType(shadcn.DateRangePicker);
            expect(picker, findsOneWidget);
            expect(
              tester.widget<shadcn.DateRangePicker>(picker).value,
              shadcn.DateTimeRange(initial.start, initial.end),
            );

            final trigger = find.descendant(
              of: picker,
              matching: find.byType(shadcn.OutlineButton),
            );
            expect(trigger, findsOneWidget);
            final canEdit = enabled && !readOnly;
            expect(
              tester.widget<shadcn.OutlineButton>(trigger).enabled,
              canEdit,
            );
            final focusTarget = find.descendant(
              of: trigger,
              matching: find.byType(FocusableActionDetector),
            );
            expect(focusTarget, findsOneWidget);
            expect(
              tester.widget<FocusableActionDetector>(focusTarget).enabled,
              canEdit,
            );

            await tester.tap(trigger, warnIfMissed: false);
            await tester.pumpAndSettle();

            if (canEdit) {
              final dialog = find.byType(shadcn.DatePickerDialog);
              expect(dialog, findsOneWidget);
              tester.widget<shadcn.DatePickerDialog>(dialog).onChanged!(
                shadcn.CalendarValue.range(changed.start, changed.end),
              );
              await tester.pumpAndSettle();
              expect(callbackCount, 0);

              await tester.tap(find.text('Save'));
              await tester.pumpAndSettle();
              expect(dialog, findsNothing);
              expect(callbackCount, 1);
              expect(lastCallbackValue, changed);
            } else {
              expect(find.byType(shadcn.DatePickerDialog), findsNothing);
              expect(callbackCount, 0);
              expect(
                tester.widget<shadcn.DateRangePicker>(picker).value,
                shadcn.DateTimeRange(initial.start, initial.end),
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }
  }
}
