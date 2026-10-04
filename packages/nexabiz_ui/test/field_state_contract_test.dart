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
    testWidgets(
      'select syncs parent changes, reset, and record reuse $direction',
      (tester) async {
        var calls = 0;
        String? last;
        Future<void> show(
          String label,
          String? value, {
          bool enabled = true,
          bool readOnly = false,
        }) async {
          await tester.pumpWidget(
            _host(
              UiSelectField<String>(
                label: label,
                items: const ['Alpha', 'Beta', 'Gamma'],
                value: value,
                enabled: enabled,
                readOnly: readOnly,
                onChanged: (next) {
                  calls++;
                  last = next;
                },
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show('Record A', 'Alpha');
        expect(find.text('Alpha'), findsOneWidget);
        tester
            .widget<shadcn.ControlledSelect<String>>(
              find.byType(shadcn.ControlledSelect<String>),
            )
            .onChanged!('Beta');
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(last, 'Beta');
        await show('Record A', 'Beta');
        expect(find.text('Beta'), findsOneWidget);
        await show('Record A', null);
        expect(find.text('Alpha'), findsNothing);
        expect(find.text('Beta'), findsNothing);
        await show('Record B', 'Gamma', enabled: false);
        expect(find.text('Gamma'), findsOneWidget);
        expect(
          tester
              .widget<shadcn.Select<String>>(find.byType(shadcn.Select<String>))
              .enabled,
          isFalse,
        );
        await show('Record B', 'Alpha', readOnly: true);
        expect(find.text('Alpha'), findsOneWidget);
        expect(
          tester
              .widget<shadcn.Select<String>>(find.byType(shadcn.Select<String>))
              .enabled,
          isFalse,
        );
        expect(calls, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'multi-select syncs parent changes without mutating lists $direction',
      (tester) async {
        var calls = 0;
        List<String>? last;
        final initial = <String>['Alpha'];
        Future<void> show(
          String label,
          List<String>? value, {
          bool enabled = true,
          bool readOnly = false,
        }) async {
          await tester.pumpWidget(
            _host(
              UiMultiSelectField<String>(
                label: label,
                items: const ['Alpha', 'Beta', 'Gamma'],
                value: value,
                enabled: enabled,
                readOnly: readOnly,
                onChanged: (next) {
                  calls++;
                  last = next;
                },
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show('Record A', initial);
        expect(find.text('Alpha'), findsOneWidget);
        tester
            .widget<shadcn.ControlledMultiSelect<String>>(
              find.byType(shadcn.ControlledMultiSelect<String>),
            )
            .onChanged!(<String>['Alpha', 'Beta']);
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(last, ['Alpha', 'Beta']);
        expect(identical(last, initial), isFalse);
        expect(initial, ['Alpha']);
        await show('Record A', last);
        expect(find.text('Beta'), findsOneWidget);
        await show('Record A', const []);
        expect(find.text('Alpha'), findsNothing);
        expect(find.text('Beta'), findsNothing);
        await show('Record B', const ['Gamma'], enabled: false);
        expect(find.text('Gamma'), findsOneWidget);
        expect(
          tester
              .widget<shadcn.Select<Iterable<String>>>(
                find.byType(shadcn.Select<Iterable<String>>),
              )
              .enabled,
          isFalse,
        );
        await show('Record B', const ['Alpha'], readOnly: true);
        expect(find.text('Alpha'), findsOneWidget);
        expect(
          tester
              .widget<shadcn.Select<Iterable<String>>>(
                find.byType(shadcn.Select<Iterable<String>>),
              )
              .enabled,
          isFalse,
        );
        expect(calls, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'date syncs parent changes, reset, and record reuse $direction',
      (tester) async {
        final first = DateTime(2026, 9, 1);
        final second = DateTime(2026, 10, 2);
        final third = DateTime(2026, 11, 3);
        var calls = 0;
        DateTime? last;
        Future<void> show(
          String label,
          DateTime? value, {
          bool enabled = true,
          bool readOnly = false,
        }) async {
          await tester.pumpWidget(
            _host(
              UiDateField(
                label: label,
                value: value,
                enabled: enabled,
                readOnly: readOnly,
                onChanged: (next) {
                  calls++;
                  last = next;
                },
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show('Record A', first);
        expect(
          tester
              .widget<shadcn.DatePicker>(find.byType(shadcn.DatePicker))
              .value,
          first,
        );
        await tester.tap(find.byType(shadcn.DatePicker));
        await tester.pumpAndSettle();
        final dialog = find.byType(shadcn.DatePickerDialog);
        expect(dialog, findsOneWidget);
        tester.widget<shadcn.DatePickerDialog>(dialog).onChanged!(
          shadcn.CalendarValue.single(second),
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text('Save'));
        await tester.pumpAndSettle();
        expect(calls, 1);
        expect(last, second);
        await show('Record A', second);
        expect(
          tester
              .widget<shadcn.DatePicker>(find.byType(shadcn.DatePicker))
              .value,
          second,
        );
        await show('Record A', null);
        expect(
          tester
              .widget<shadcn.DatePicker>(find.byType(shadcn.DatePicker))
              .value,
          isNull,
        );
        await show('Record B', third, enabled: false);
        expect(
          tester
              .widget<shadcn.DatePicker>(find.byType(shadcn.DatePicker))
              .value,
          third,
        );
        expect(
          tester
              .widget<shadcn.ControlledDatePicker>(
                find.byType(shadcn.ControlledDatePicker),
              )
              .enabled,
          isFalse,
        );
        await show('Record B', first, readOnly: true);
        expect(
          tester
              .widget<shadcn.DatePicker>(find.byType(shadcn.DatePicker))
              .value,
          first,
        );
        expect(
          tester
              .widget<shadcn.ControlledDatePicker>(
                find.byType(shadcn.ControlledDatePicker),
              )
              .enabled,
          isFalse,
        );
        expect(calls, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'date range already syncs parent changes and reset $direction',
      (tester) async {
        final first = DateTimeRange(
          start: DateTime(2026, 9, 1),
          end: DateTime(2026, 9, 30),
        );
        final second = DateTimeRange(
          start: DateTime(2026, 10, 1),
          end: DateTime(2026, 10, 31),
        );
        var calls = 0;
        Future<void> show(
          String label,
          DateTimeRange? value, {
          bool enabled = true,
          bool readOnly = false,
        }) async {
          await tester.pumpWidget(
            _host(
              UiDateRangeField(
                label: label,
                value: value,
                enabled: enabled,
                readOnly: readOnly,
                onChanged: (_) => calls++,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show('Record A', first);
        expect(
          tester
              .widget<shadcn.DateRangePicker>(
                find.byType(shadcn.DateRangePicker),
              )
              .value,
          shadcn.DateTimeRange(first.start, first.end),
        );
        await show('Record A', second);
        expect(
          tester
              .widget<shadcn.DateRangePicker>(
                find.byType(shadcn.DateRangePicker),
              )
              .value,
          shadcn.DateTimeRange(second.start, second.end),
        );
        await show('Record A', null);
        expect(
          tester
              .widget<shadcn.DateRangePicker>(
                find.byType(shadcn.DateRangePicker),
              )
              .value,
          isNull,
        );
        await show('Record B', first, enabled: false);
        expect(
          tester
              .widget<shadcn.DateRangePicker>(
                find.byType(shadcn.DateRangePicker),
              )
              .value,
          shadcn.DateTimeRange(first.start, first.end),
        );
        await show('Record B', second, readOnly: true);
        expect(
          tester
              .widget<shadcn.DateRangePicker>(
                find.byType(shadcn.DateRangePicker),
              )
              .value,
          shadcn.DateTimeRange(second.start, second.end),
        );
        expect(calls, 0);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'number value-only syncs parent changes without callbacks $direction',
      (tester) async {
        var rawCalls = 0;
        var numberCalls = 0;
        num? lastNumber;
        Future<void> show(
          String label,
          num? value, {
          bool enabled = true,
          bool readOnly = false,
        }) async {
          await tester.pumpWidget(
            _host(
              UiNumberField(
                label: label,
                value: value,
                enabled: enabled,
                readOnly: readOnly,
                onChanged: (_) => rawCalls++,
                onNumberChanged: (next) {
                  numberCalls++;
                  lastNumber = next;
                },
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        String text() => tester
            .widget<EditableText>(find.byType(EditableText))
            .controller
            .text;

        await show('Record A', 12);
        expect(text(), '12');
        await tester.enterText(find.byType(EditableText), '13');
        await tester.pumpAndSettle();
        expect(text(), '13');
        expect(rawCalls, 1);
        expect(numberCalls, 1);
        expect(lastNumber, 13);
        await show('Record A', 13);
        expect(text(), '13');
        await show('Record A', null);
        expect(text(), '');
        await show('Record B', 56, enabled: false);
        expect(text(), '56');
        expect(
          tester
              .widget<shadcn.TextField>(find.byType(shadcn.TextField))
              .enabled,
          isFalse,
        );
        await show('Record B', 78, readOnly: true);
        expect(text(), '78');
        expect(
          tester
              .widget<shadcn.TextField>(find.byType(shadcn.TextField))
              .readOnly,
          isTrue,
        );
        expect(rawCalls, 1);
        expect(numberCalls, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('number caller controller owns text over value $direction', (
      tester,
    ) async {
      final controller = TextEditingController(text: '4');
      addTearDown(controller.dispose);
      var calls = 0;
      Future<void> show(num? value) async {
        await tester.pumpWidget(
          _host(
            UiNumberField(
              label: 'Count',
              controller: controller,
              value: value,
              onChanged: (_) => calls++,
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(99);
      expect(controller.text, '4');
      await show(100);
      expect(controller.text, '4');
      controller.text = '7';
      await tester.pump();
      expect(
        tester.widget<EditableText>(find.byType(EditableText)).controller.text,
        '7',
      );
      // shadcn 0.0.53 reports caller-owned controller edits through onChanged.
      expect(calls, 1);
      expect(tester.takeException(), isNull);
    });
  }
}
