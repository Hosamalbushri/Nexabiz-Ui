import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _host(
  Widget child,
  TextDirection direction, {
  double textScale = 1.0,
  double width = 400,
}) => shadcn.ShadcnApp(
  home: Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(textScale)),
      child: shadcn.Scaffold(
        child: Center(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

class _TestController extends TextEditingController {
  _TestController([String? text]) : super(text: text);
  bool get hasActiveListeners => hasListeners;
}

void main() {
  for (final direction in TextDirection.values) {
    group('Phase 01 Stress & Integration — $direction', () {
      // -----------------------------------------------------------------------
      // 1. Rapid repeated controller replacement
      // -----------------------------------------------------------------------
      testWidgets('1. Rapid repeated controller replacement ($direction)', (
        tester,
      ) async {
        final controllers = List<_TestController>.generate(
          20,
          (i) => _TestController('val_$i'),
        );
        final textCalls = <String>[];
        final autoCalls = <String>[];

        for (var i = 0; i < controllers.length; i++) {
          final c = controllers[i];
          await tester.pumpWidget(
            _host(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UiTextField(
                    label: 'Text',
                    controller: c,
                    onChanged: textCalls.add,
                  ),
                  UiAutocompleteField(
                    label: 'Auto',
                    controller: c,
                    suggestions: const ['val_0', 'val_1'],
                    onChanged: autoCalls.add,
                  ),
                ],
              ),
              direction,
            ),
          );
          await tester.pump();
          expect(find.text('val_$i'), findsNWidgets(2));
          if (i > 0) {
            expect(
              controllers[i - 1].hasActiveListeners,
              isFalse,
              reason: 'Previous controller $i-1 must detach listeners',
            );
          }
        }

        // No spurious onChanged callbacks from swaps
        expect(textCalls, isEmpty);
        expect(autoCalls, isEmpty);

        // Teardown
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpAndSettle();
        for (final c in controllers) {
          expect(c.hasActiveListeners, isFalse);
          c.dispose();
        }
        expect(tester.takeException(), isNull);
      });

      // -----------------------------------------------------------------------
      // 2. Controller replacement during active text composition (simulated IME)
      // Note: This tests simulated TextEditingValue composing regions in widget
      // test harness; physical device IME platform channels are verified separately.
      // -----------------------------------------------------------------------
      testWidgets(
        '2. Controller replacement during active text composition ($direction)',
        (tester) async {
          final c1 = _TestController();
          c1.value = const TextEditingValue(
            text: 'café',
            selection: TextSelection.collapsed(offset: 4),
            composing: TextRange(start: 0, end: 4),
          );

          final textCalls = <String>[];
          await tester.pumpWidget(
            _host(
              UiTextField(
                label: 'Simulated IME',
                controller: c1,
                onChanged: textCalls.add,
              ),
              direction,
            ),
          );
          await tester.pump();
          expect(find.text('café'), findsOneWidget);
          expect(c1.value.composing, const TextRange(start: 0, end: 4));

          // Swap to c2 during active composition
          final c2 = _TestController();
          c2.value = const TextEditingValue(
            text: 'naïve',
            selection: TextSelection.collapsed(offset: 5),
            composing: TextRange(start: 0, end: 5),
          );

          await tester.pumpWidget(
            _host(
              UiTextField(
                label: 'Simulated IME',
                controller: c2,
                onChanged: textCalls.add,
              ),
              direction,
            ),
          );
          await tester.pump();
          expect(find.text('naïve'), findsOneWidget);
          expect(c2.value.composing, const TextRange(start: 0, end: 5));
          expect(c1.hasActiveListeners, isFalse);
          expect(textCalls, isEmpty);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          expect(c2.hasActiveListeners, isFalse);
          c1.dispose();
          c2.dispose();
          expect(tester.takeException(), isNull);
        },
      );

      // -----------------------------------------------------------------------
      // 3. Repeated mounting and unmounting across all fields
      // -----------------------------------------------------------------------
      testWidgets(
        '3. Repeated mounting and unmounting of all 7 fields ($direction)',
        (tester) async {
          final textCtrl = _TestController('initial');
          final numCtrl = _TestController('42');
          final autoCtrl = _TestController('auto');

          for (var cycle = 0; cycle < 6; cycle++) {
            await tester.pumpWidget(
              _host(
                SingleChildScrollView(
                  child: Column(
                    children: [
                      UiTextField(label: 'T', controller: textCtrl),
                      UiNumberField(label: 'N', controller: numCtrl),
                      UiAutocompleteField(
                        label: 'A',
                        controller: autoCtrl,
                        suggestions: const ['auto', 'other'],
                      ),
                      UiSelectField<String>(
                        label: 'S',
                        items: const ['S1', 'S2'],
                        value: 'S1',
                      ),
                      UiMultiSelectField<String>(
                        label: 'M',
                        items: const ['M1', 'M2'],
                        value: const ['M1'],
                      ),
                      UiDateField(label: 'D', value: DateTime.utc(2026, 1, 1)),
                      UiDateRangeField(
                        label: 'DR',
                        value: DateTimeRange(
                          start: DateTime.utc(2026, 1, 1),
                          end: DateTime.utc(2026, 1, 15),
                        ),
                      ),
                    ],
                  ),
                ),
                direction,
              ),
            );
            await tester.pump();

            // Unmount
            await tester.pumpWidget(const SizedBox.shrink());
            await tester.pump();
          }

          expect(textCtrl.hasActiveListeners, isFalse);
          expect(numCtrl.hasActiveListeners, isFalse);
          expect(autoCtrl.hasActiveListeners, isFalse);
          textCtrl.dispose();
          numCtrl.dispose();
          autoCtrl.dispose();
          expect(tester.takeException(), isNull);
        },
      );

      // -----------------------------------------------------------------------
      // 4. Switching between records with active overlays
      // -----------------------------------------------------------------------
      testWidgets(
        '4. Switching between records with active overlays ($direction)',
        (tester) async {
          final recACalls = <List<String>>[];
          final recBCalls = <List<String>>[];

          // Render Record A
          await tester.pumpWidget(
            _host(
              UiMultiSelectField<String>(
                key: const ValueKey('record-a'),
                label: 'Tags',
                items: const ['Alpha', 'Beta'],
                value: const ['Alpha'],
                onChanged: recACalls.add,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();

          // Open popup for Record A
          await tester.tap(find.byType(shadcn.Select<Iterable<String>>));
          await tester.pumpAndSettle();
          expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);
          expect(find.text('Beta'), findsWidgets);

          // Switch to Record B with its own key and data
          await tester.pumpWidget(
            _host(
              UiMultiSelectField<String>(
                key: const ValueKey('record-b'),
                label: 'Tags',
                items: const ['Gamma', 'Delta'],
                value: const ['Gamma'],
                onChanged: recBCalls.add,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();

          // Popup should be closed cleanly
          expect(find.byType(shadcn.SelectPopup<String>), findsNothing);
          expect(find.text('Gamma'), findsOneWidget);
          expect(recACalls, isEmpty);
          expect(recBCalls, isEmpty);
          expect(tester.takeException(), isNull);
        },
      );

      // -----------------------------------------------------------------------
      // 5. External and internal number-controller transitions
      // -----------------------------------------------------------------------
      testWidgets(
        '5. External and internal number-controller transitions ($direction)',
        (tester) async {
          final extA = _TestController('100');
          final extB = _TestController('200');
          final numCalls = <num?>[];

          // 1. Internal controller mode
          await tester.pumpWidget(
            _host(
              UiNumberField(
                label: 'Num',
                value: 50,
                onNumberChanged: numCalls.add,
              ),
              direction,
            ),
          );
          await tester.pump();
          expect(find.text('50'), findsOneWidget);
          expect(extA.hasActiveListeners, isFalse);

          // 2. Switch to external controller A
          await tester.pumpWidget(
            _host(
              UiNumberField(
                label: 'Num',
                controller: extA,
                value: 100,
                onNumberChanged: numCalls.add,
              ),
              direction,
            ),
          );
          await tester.pump();
          expect(find.text('100'), findsOneWidget);
          expect(extA.hasActiveListeners, isTrue);

          // 3. Switch to external controller B
          await tester.pumpWidget(
            _host(
              UiNumberField(
                label: 'Num',
                controller: extB,
                value: 200,
                onNumberChanged: numCalls.add,
              ),
              direction,
            ),
          );
          await tester.pump();
          expect(find.text('200'), findsOneWidget);
          expect(extA.hasActiveListeners, isFalse);
          expect(extB.hasActiveListeners, isTrue);

          // 4. Switch back to internal controller mode
          await tester.pumpWidget(
            _host(
              UiNumberField(
                label: 'Num',
                value: 300,
                onNumberChanged: numCalls.add,
              ),
              direction,
            ),
          );
          await tester.pump();
          expect(find.text('300'), findsOneWidget);
          expect(extA.hasActiveListeners, isFalse);
          expect(extB.hasActiveListeners, isFalse);

          // Transitions should not emit spurious onNumberChanged callbacks
          expect(numCalls, isEmpty);

          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpAndSettle();
          extA.dispose();
          extB.dispose();
          expect(tester.takeException(), isNull);
        },
      );

      // -----------------------------------------------------------------------
      // 6. Rapid opening and closing of selection popups
      // -----------------------------------------------------------------------
      testWidgets(
        '6. Rapid opening and closing of selection popups ($direction)',
        (tester) async {
          final calls = <String?>[];
          await tester.pumpWidget(
            _host(
              UiSelectField<String>(
                label: 'Choice',
                items: const ['A', 'B', 'C'],
                value: 'A',
                onChanged: calls.add,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();

          for (var i = 0; i < 8; i++) {
            // Open popup
            await tester.tap(find.text('A'));
            await tester.pumpAndSettle();
            expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);

            // Close popup via tap outside
            await tester.tapAt(const Offset(10, 10));
            await tester.pumpAndSettle();
            expect(find.byType(shadcn.SelectPopup<String>), findsNothing);
          }

          expect(calls, isEmpty);

          // Finally select 'B' on the next opening
          await tester.tap(find.text('A'));
          await tester.pumpAndSettle();
          final option = find.byWidgetPredicate(
            (w) => w is shadcn.SelectItemButton<String> && w.value == 'B',
          );
          await tester.tap(option);
          await tester.pumpAndSettle();
          expect(calls, ['B']);
          expect(tester.takeException(), isNull);
        },
      );

      // -----------------------------------------------------------------------
      // 7. Keyboard focus and Escape behavior
      // -----------------------------------------------------------------------
      testWidgets('7. Keyboard focus and Escape behavior ($direction)', (
        tester,
      ) async {
        final focus = FocusNode();
        final calls = <String?>[];

        await tester.pumpWidget(
          _host(
            UiSelectField<String>(
              label: 'Choice',
              items: const ['A', 'B', 'C'],
              value: 'A',
              focusNode: focus,
              onChanged: calls.add,
            ),
            direction,
          ),
        );
        await tester.pumpAndSettle();

        // 1. Open popup and verify Escape dismisses popup and restores focus
        await tester.tap(find.text('A'));
        await tester.pumpAndSettle();
        expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);

        final modalFinder = find.descendant(
          of: find.byType(shadcn.SelectPopup<String>),
          matching: find.byType(shadcn.ModalContainer),
        );
        final popupFocus = Focus.of(tester.element(modalFinder));
        popupFocus.requestFocus();
        await tester.pumpAndSettle();
        expect(popupFocus.hasPrimaryFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();
        expect(find.byType(shadcn.SelectPopup<String>), findsNothing);
        expect(calls, isEmpty);

        // 2. Re-open and select via keyboard
        await tester.tap(find.text('A'));
        await tester.pumpAndSettle();
        final popupFocus2 = Focus.of(tester.element(modalFinder));
        popupFocus2.requestFocus();
        await tester.pumpAndSettle();

        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
        await tester.pumpAndSettle();
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pumpAndSettle();

        expect(calls, ['B']);
        expect(focus.hasFocus, isTrue);

        await tester.pumpWidget(const SizedBox.shrink());
        focus.dispose();
        expect(tester.takeException(), isNull);
      });

      // -----------------------------------------------------------------------
      // 8. RTL and LTR with increased text scaling
      // -----------------------------------------------------------------------
      testWidgets('8. Form scaling at 1.5x and 2.0x ($direction)', (
        tester,
      ) async {
        final textCtrl = _TestController('Sample text');
        final numCtrl = _TestController('12345.67');
        final autoCtrl = _TestController('Auto');

        for (final scale in [1.5, 2.0]) {
          for (final width in [320.0, 420.0, 960.0]) {
            await tester.pumpWidget(
              _host(
                SingleChildScrollView(
                  child: UiFormLayout(
                    maxColumns: 2,
                    children: [
                      UiFormSpan(
                        span: UiFormSpanType.full,
                        child: UiTextField(
                          label: 'Text Field',
                          controller: textCtrl,
                          helper: 'Helper description',
                        ),
                      ),
                      UiFormSpan(
                        span: UiFormSpanType.normal,
                        child: UiNumberField(
                          label: 'Number Field',
                          controller: numCtrl,
                        ),
                      ),
                      UiFormSpan(
                        span: UiFormSpanType.normal,
                        child: UiAutocompleteField(
                          label: 'Autocomplete Field',
                          controller: autoCtrl,
                          suggestions: const ['Auto 1', 'Auto 2'],
                        ),
                      ),
                      UiFormSpan(
                        span: UiFormSpanType.normal,
                        child: UiSelectField<String>(
                          label: 'Select Field',
                          items: const ['Item 1', 'Item 2'],
                          value: 'Item 1',
                        ),
                      ),
                      UiFormSpan(
                        span: UiFormSpanType.normal,
                        child: UiMultiSelectField<String>(
                          label: 'MultiSelect Field',
                          items: const ['Item 1', 'Item 2', 'Item 3'],
                          value: const ['Item 1', 'Item 2'],
                        ),
                      ),
                      UiFormSpan(
                        span: UiFormSpanType.normal,
                        child: UiDateField(
                          label: 'Date Field',
                          value: DateTime.utc(2026, 6, 15),
                        ),
                      ),
                      UiFormSpan(
                        span: UiFormSpanType.normal,
                        child: UiDateRangeField(
                          label: 'Date Range Field',
                          value: DateTimeRange(
                            start: DateTime.utc(2026, 6, 1),
                            end: DateTime.utc(2026, 6, 30),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                direction,
                textScale: scale,
                width: width,
              ),
            );
            await tester.pump();
            expect(tester.takeException(), isNull);
          }
        }

        await tester.pumpWidget(const SizedBox.shrink());
        textCtrl.dispose();
        numCtrl.dispose();
        autoCtrl.dispose();
      });

      // -----------------------------------------------------------------------
      // 9. Duplicate callbacks and stale displayed values
      // -----------------------------------------------------------------------
      testWidgets(
        '9. Callback de-duplication and parent value sync ($direction)',
        (tester) async {
          final textCtrl = _TestController('hello');
          final numCtrl = _TestController('10');
          final textCalls = <String>[];
          final numCalls = <String>[];
          final selectCalls = <String?>[];
          final multiCalls = <List<String>>[];

          Widget buildTree({
            required String text,
            required String? selectVal,
            required List<String> multiVal,
          }) => _host(
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                UiTextField(
                  label: 'Text',
                  controller: textCtrl,
                  onChanged: textCalls.add,
                ),
                UiNumberField(
                  label: 'Num',
                  controller: numCtrl,
                  onChanged: numCalls.add,
                ),
                UiSelectField<String>(
                  label: 'Sel',
                  items: const ['X', 'Y', 'Z'],
                  value: selectVal,
                  onChanged: selectCalls.add,
                ),
                UiMultiSelectField<String>(
                  label: 'Multi',
                  items: const ['X', 'Y', 'Z'],
                  value: multiVal,
                  onChanged: multiCalls.add,
                ),
              ],
            ),
            direction,
          );

          await tester.pumpWidget(
            buildTree(text: 'hello', selectVal: 'X', multiVal: const ['X']),
          );
          await tester.pumpAndSettle();
          expect(textCalls, isEmpty);
          expect(numCalls, isEmpty);
          expect(selectCalls, isEmpty);
          expect(multiCalls, isEmpty);

          // Rebuild parent with identical state -> 0 callbacks
          await tester.pumpWidget(
            buildTree(text: 'hello', selectVal: 'X', multiVal: const ['X']),
          );
          await tester.pumpAndSettle();
          expect(textCalls, isEmpty);
          expect(numCalls, isEmpty);
          expect(selectCalls, isEmpty);
          expect(multiCalls, isEmpty);

          // Rebuild parent with updated state -> 0 callbacks, display updates
          await tester.pumpWidget(
            buildTree(
              text: 'hello',
              selectVal: 'Y',
              multiVal: const ['X', 'Y'],
            ),
          );
          await tester.pumpAndSettle();
          expect(textCalls, isEmpty);
          expect(numCalls, isEmpty);
          expect(selectCalls, isEmpty);
          expect(multiCalls, isEmpty);
          expect(find.text('Y'), findsWidgets);

          // Entering user text -> exactly 1 callback
          await tester.enterText(find.byType(UiTextField), 'hello world');
          await tester.pump();
          expect(textCalls, ['hello world']);

          await tester.pumpWidget(const SizedBox.shrink());
          textCtrl.dispose();
          numCtrl.dispose();
          expect(tester.takeException(), isNull);
        },
      );

      // -----------------------------------------------------------------------
      // 10. Caller-owned controller and collection integrity
      // -----------------------------------------------------------------------
      testWidgets(
        '10. Caller-owned controller and collection integrity ($direction)',
        (tester) async {
          final originalItems = List<String>.unmodifiable([
            'Alpha',
            'Beta',
            'Gamma',
          ]);
          final originalSelection = List<String>.unmodifiable(['Alpha']);
          final multiCalls = <List<String>>[];

          await tester.pumpWidget(
            _host(
              UiMultiSelectField<String>(
                label: 'Multi',
                items: originalItems,
                value: originalSelection,
                onChanged: multiCalls.add,
              ),
              direction,
            ),
          );
          await tester.pumpAndSettle();

          // Open popup and select Beta
          await tester.tap(find.byType(shadcn.Select<Iterable<String>>));
          await tester.pumpAndSettle();
          final betaButton = find.byWidgetPredicate(
            (w) => w is shadcn.SelectItemButton<String> && w.value == 'Beta',
          );
          await tester.tap(betaButton);
          await tester.pumpAndSettle();

          // Emitted selection should have both items
          expect(multiCalls.length, 1);
          expect(multiCalls.first, containsAll(['Alpha', 'Beta']));

          // Original unmodifiable collections were NOT mutated
          expect(originalItems, ['Alpha', 'Beta', 'Gamma']);
          expect(originalSelection, ['Alpha']);

          // Test caller controller disposal lifecycle
          final callerCtrl = _TestController('caller_owned');
          await tester.pumpWidget(
            _host(
              UiTextField(label: 'Owned', controller: callerCtrl),
              direction,
            ),
          );
          await tester.pump();

          // Unmount field: caller controller must NOT be disposed by package
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();

          expect(callerCtrl.hasActiveListeners, isFalse);
          // Calling text setter works because controller was not disposed
          callerCtrl.text = 'still_valid';
          expect(callerCtrl.text, 'still_valid');
          callerCtrl.dispose();

          expect(tester.takeException(), isNull);
        },
      );
    });
  }
}
