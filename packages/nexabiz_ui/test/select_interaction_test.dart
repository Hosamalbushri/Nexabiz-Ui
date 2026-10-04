import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _host(Widget child, TextDirection direction) => shadcn.ShadcnApp(
  home: Directionality(
    textDirection: direction,
    child: shadcn.Scaffold(
      child: Center(child: SizedBox(width: 320, child: child)),
    ),
  ),
);

Finder _option(String value) => find.byWidgetPredicate(
  (widget) =>
      widget is shadcn.SelectItemButton<String> && widget.value == value,
);

Future<void> _open(WidgetTester tester, Finder trigger) async {
  await tester.tap(trigger);
  await tester.pumpAndSettle();
  expect(_option('Beta'), findsOneWidget);
}

void main() {
  for (final direction in TextDirection.values) {
    testWidgets('single select pointer, close, parent update $direction', (
      tester,
    ) async {
      final calls = <String?>[];
      Future<void> show(String? value) async {
        await tester.pumpWidget(
          _host(
            UiSelectField<String>(
              label: 'Choice',
              items: const ['Alpha', 'Beta', 'Gamma'],
              value: value,
              onChanged: calls.add,
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();
      }

      await show('Alpha');
      await _open(tester, find.text('Alpha'));
      await tester.tap(_option('Beta'));
      await tester.pumpAndSettle();
      expect(calls, ['Beta']);
      expect(find.byType(shadcn.SelectPopup<String>), findsNothing);
      expect(find.text('Beta'), findsOneWidget);
      await show('Beta');
      expect(find.text('Beta'), findsOneWidget);
      await show('Gamma');
      expect(find.text('Gamma'), findsOneWidget);
      expect(calls, ['Beta']);
      expect(tester.takeException(), isNull);
    });

    testWidgets('multi-select pointer toggle and outside close $direction', (
      tester,
    ) async {
      final initial = <String>['Alpha'];
      final calls = <List<String>>[];
      Future<void> show(List<String> value) async {
        await tester.pumpWidget(
          _host(
            UiMultiSelectField<String>(
              label: 'Tags',
              items: const ['Alpha', 'Beta', 'Gamma'],
              value: value,
              onChanged: calls.add,
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();
      }

      await show(initial);
      await _open(tester, find.byType(shadcn.Select<Iterable<String>>));
      await tester.tap(_option('Beta'));
      await tester.pumpAndSettle();
      expect(calls, [
        ['Alpha', 'Beta'],
      ]);
      expect(initial, ['Alpha']);
      expect(identical(calls.single, initial), isFalse);
      expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);
      expect(find.text('Alpha'), findsWidgets);
      await tester.tap(_option('Alpha'));
      await tester.pumpAndSettle();
      expect(calls, [
        ['Alpha', 'Beta'],
        ['Beta'],
      ]);
      expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(shadcn.SelectPopup<String>), findsNothing);
      await show(const ['Gamma']);
      expect(find.text('Gamma'), findsOneWidget);
      expect(calls.length, 2);
      expect(tester.takeException(), isNull);
    });

    for (final readOnly in [false, true]) {
      testWidgets(
        'single select ${readOnly ? 'read-only' : 'disabled'} does not open $direction',
        (tester) async {
          var calls = 0;
          await tester.pumpWidget(
            _host(
              UiSelectField<String>(
                label: 'Choice',
                items: const ['Alpha', 'Beta'],
                value: 'Alpha',
                enabled: readOnly,
                readOnly: readOnly,
                onChanged: (_) => calls++,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Alpha'));
          await tester.pumpAndSettle();
          expect(_option('Beta'), findsNothing);
          expect(calls, 0);
          expect(tester.takeException(), isNull);
        },
      );

      testWidgets(
        'multi-select ${readOnly ? 'read-only' : 'disabled'} does not open $direction',
        (tester) async {
          var calls = 0;
          await tester.pumpWidget(
            _host(
              UiMultiSelectField<String>(
                label: 'Tags',
                items: const ['Alpha', 'Beta'],
                value: const ['Alpha'],
                enabled: readOnly,
                readOnly: readOnly,
                onChanged: (_) => calls++,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();
          await tester.tap(find.text('Alpha'));
          await tester.pumpAndSettle();
          expect(_option('Beta'), findsNothing);
          expect(calls, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }

    testWidgets('single-select keyboard, Escape, and focus $direction', (
      tester,
    ) async {
      final focus = FocusNode();
      addTearDown(focus.dispose);
      final calls = <String?>[];
      await tester.pumpWidget(
        _host(
          UiSelectField<String>(
            label: 'Choice',
            items: const ['Alpha', 'Beta', 'Gamma'],
            value: 'Alpha',
            focusNode: focus,
            onChanged: calls.add,
          ),
          direction,
        ),
      );
      await tester.pumpAndSettle();
      await _open(tester, find.text('Alpha'));
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(_option('Beta'), findsNothing);
      expect(calls, isEmpty);
      expect(focus.hasFocus, isTrue);
      await _open(tester, find.text('Alpha'));
      final popupFocus = Focus.of(
        tester.element(
          find.descendant(
            of: find.byType(shadcn.SelectPopup<String>),
            matching: find.byType(shadcn.ModalContainer),
          ),
        ),
      );
      popupFocus.requestFocus();
      await tester.pumpAndSettle();
      expect(popupFocus.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      final optionFocus =
          tester.state(
                find.descendant(
                  of: _option('Alpha'),
                  matching: find.byType(shadcn.SubFocus),
                ),
              )
              as shadcn.SubFocusState;
      expect(optionFocus.isFocused, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      final betaFocus =
          tester.state(
                find.descendant(
                  of: _option('Beta'),
                  matching: find.byType(shadcn.SubFocus),
                ),
              )
              as shadcn.SubFocusState;
      expect(betaFocus.isFocused, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls.length, 1);
      expect(calls.single, 'Beta');
      expect(find.byType(shadcn.SelectPopup<String>), findsNothing);
      expect(focus.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    });

    testWidgets('multi-select keyboard activation retains popup $direction', (
      tester,
    ) async {
      final calls = <List<String>>[];
      await tester.pumpWidget(
        _host(
          UiMultiSelectField<String>(
            label: 'Tags',
            items: const ['Alpha', 'Beta'],
            value: const ['Alpha'],
            onChanged: calls.add,
          ),
          direction,
        ),
      );
      await tester.pumpAndSettle();
      await _open(tester, find.byType(shadcn.Select<Iterable<String>>));
      final popupFocus = Focus.of(
        tester.element(
          find.descendant(
            of: find.byType(shadcn.SelectPopup<String>),
            matching: find.byType(shadcn.ModalContainer),
          ),
        ),
      );
      popupFocus.requestFocus();
      await tester.pumpAndSettle();
      expect(popupFocus.hasPrimaryFocus, isTrue);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pumpAndSettle();
      expect(calls, [
        ['Alpha', 'Beta'],
      ]);
      expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pumpAndSettle();
      expect(find.byType(shadcn.SelectPopup<String>), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }
}
