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

class _TrackingController extends TextEditingController {
  _TrackingController(String text) : super(text: text);

  bool get hasActiveListeners => hasListeners;
}

void main() {
  for (final direction in TextDirection.values) {
    testWidgets(
      'text replaces caller controller without stale callbacks $direction',
      (tester) async {
        final old = _TrackingController('old');
        final next = _TrackingController('next');
        final oldFocus = FocusNode();
        final nextFocus = FocusNode();
        final changes = <String>[];
        Future<void> show(
          TextEditingController controller,
          FocusNode focus,
        ) async {
          await tester.pumpWidget(
            _host(
              UiTextField(
                label: 'Name',
                controller: controller,
                focusNode: focus,
                onChanged: changes.add,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show(old, oldFocus);
        oldFocus.requestFocus();
        await tester.pump();
        expect(oldFocus.hasFocus, isTrue);
        await show(next, nextFocus);
        expect(find.text('next'), findsOneWidget);
        expect(changes, isEmpty);
        nextFocus.requestFocus();
        await tester.pump();
        expect(nextFocus.hasFocus, isTrue);
        expect(oldFocus.hasFocus, isFalse);
        old.text = 'obsolete';
        await tester.pump();
        expect(changes, isEmpty);
        expect(find.text('next'), findsOneWidget);
        await tester.enterText(find.byType(shadcn.TextField), 'edited');
        await tester.pump();
        expect(changes, ['edited']);
        await tester.enterText(find.byType(shadcn.TextField), 'again');
        await tester.pump();
        expect(changes, ['edited', 'again']);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        old.text = 'still caller owned';
        next.text = 'also caller owned';
        expect(changes, ['edited', 'again']);
        expect(old.hasActiveListeners, isFalse);
        expect(next.hasActiveListeners, isFalse);
        expect(tester.takeException(), isNull);
        old.dispose();
        next.dispose();
        oldFocus.dispose();
        nextFocus.dispose();
      },
    );

    testWidgets('number switches controller ownership safely $direction', (
      tester,
    ) async {
      final external = _TrackingController('41');
      final replacement = _TrackingController('42');
      final changes = <String>[];
      final numbers = <num?>[];
      Future<void> show(TextEditingController? controller, num? value) async {
        await tester.pumpWidget(
          _host(
            UiNumberField(
              label: 'Quantity',
              controller: controller,
              value: value,
              onChanged: changes.add,
              onNumberChanged: numbers.add,
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(null, 10);
      expect(find.text('10'), findsOneWidget);
      await show(external, 10);
      expect(find.text('41'), findsOneWidget);
      expect(changes, isEmpty);
      expect(numbers, isEmpty);
      await show(replacement, 10);
      expect(find.text('42'), findsOneWidget);
      expect(external.hasActiveListeners, isFalse);
      expect(changes, isEmpty);
      expect(numbers, isEmpty);
      await show(null, 12);
      expect(find.text('12'), findsOneWidget);
      external.text = '99';
      await tester.pump();
      expect(find.text('12'), findsOneWidget);
      expect(external.hasActiveListeners, isFalse);
      expect(changes, isEmpty);
      expect(numbers, isEmpty);
      await tester.enterText(find.byType(shadcn.TextField), '13');
      await tester.pump();
      expect(changes, ['13']);
      expect(numbers, [13]);
      await tester.pumpWidget(const SizedBox.shrink());
      external.text = 'still caller owned';
      expect(external.hasActiveListeners, isFalse);
      replacement.text = 'also caller owned';
      expect(replacement.hasActiveListeners, isFalse);
      expect(tester.takeException(), isNull);
      external.dispose();
      replacement.dispose();
    });

    testWidgets('autocomplete detaches obsolete controller $direction', (
      tester,
    ) async {
      final old = _TrackingController('Ap');
      final next = _TrackingController('Ba');
      final changes = <String>[];
      Future<void> show(TextEditingController controller) async {
        await tester.pumpWidget(
          _host(
            UiAutocompleteField(
              label: 'Fruit',
              controller: controller,
              suggestions: const ['Apple', 'Banana'],
              onChanged: changes.add,
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(old);
      await show(next);
      expect(find.text('Ba'), findsOneWidget);
      expect(changes, isEmpty);
      old.text = 'obsolete';
      await tester.pump();
      expect(changes, isEmpty);
      expect(find.text('Ba'), findsOneWidget);
      await tester.enterText(find.byType(shadcn.TextField), 'Ban');
      await tester.pump();
      expect(changes, ['Ban']);
      await tester.enterText(find.byType(shadcn.TextField), 'Bana');
      await tester.pump();
      expect(changes, ['Ban', 'Bana']);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      old.text = 'still caller owned';
      next.text = 'also caller owned';
      expect(changes, ['Ban', 'Bana']);
      expect(old.hasActiveListeners, isFalse);
      expect(next.hasActiveListeners, isFalse);
      expect(tester.takeException(), isNull);
      old.dispose();
      next.dispose();
    });

    testWidgets(
      'owned selection and date controllers survive reuse $direction',
      (tester) async {
        var singleCalls = 0;
        var multiCalls = 0;
        var dateCalls = 0;
        var rangeCalls = 0;
        Future<void> show(String record) async {
          await tester.pumpWidget(
            _host(
              Column(
                children: [
                  UiSelectField<String>(
                    label: 'Choice',
                    items: const ['A', 'B'],
                    value: record == 'A' ? 'A' : 'B',
                    onChanged: (_) => singleCalls++,
                  ),
                  UiMultiSelectField<String>(
                    label: 'Tags',
                    items: const ['A', 'B'],
                    value: [record],
                    onChanged: (_) => multiCalls++,
                  ),
                  UiDateField(
                    label: 'Date',
                    value: record == 'A'
                        ? DateTime(2026, 1, 1)
                        : DateTime(2026, 2, 2),
                    onChanged: (_) => dateCalls++,
                  ),
                  UiDateRangeField(
                    label: 'Range',
                    value: DateTimeRange(
                      start: DateTime(2026, 1, 1),
                      end: DateTime(2026, record == 'A' ? 1 : 2, 2),
                    ),
                    onChanged: (_) => rangeCalls++,
                  ),
                ],
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
        }

        await show('A');
        await show('B');
        expect(singleCalls, 0);
        expect(multiCalls, 0);
        expect(dateCalls, 0);
        expect(rangeCalls, 0);
        expect(find.text('B'), findsWidgets);
        await tester.pumpWidget(const SizedBox.shrink());
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('active autocomplete and select dispose cleanly $direction', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Ap');
      final focus = FocusNode();
      await tester.pumpWidget(
        _host(
          UiAutocompleteField(
            label: 'Fruit',
            controller: controller,
            focusNode: focus,
            suggestions: const ['Apple', 'Apricot'],
          ),
          direction,
        ),
      );
      await tester.pumpAndSettle();
      focus.requestFocus();
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      controller.text = 'After disposal';
      expect(tester.takeException(), isNull);
      controller.dispose();
      focus.dispose();

      await tester.pumpWidget(
        _host(
          UiSelectField<String>(
            label: 'Choice',
            items: const ['A', 'B'],
            value: 'A',
            onChanged: (_) {},
          ),
          direction,
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byType(shadcn.Select<String>));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });
  }
}
