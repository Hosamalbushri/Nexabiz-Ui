import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _buildTestHost(Widget child, {double width = 800}) {
  return shadcn.ShadcnApp(
    home: shadcn.Scaffold(
      child: Center(
        child: SizedBox(
          width: width,
          child: SingleChildScrollView(child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('UiFormLayout & UiFormSpan Composition Tests', () {
    testWidgets(
      'UiFormLayout respects maxColumns and handles UiFormSpan requests',
      (tester) async {
        final c1 = TextEditingController();
        final c2 = TextEditingController();
        final c3 = TextEditingController();

        await tester.pumpWidget(
          _buildTestHost(
            width: 800,
            UiFormLayout(
              maxColumns: 2,
              children: [
                UiTextField(label: 'First Name', controller: c1),
                UiTextField(label: 'Last Name', controller: c2),
                UiFormSpan.full(
                  child: UiTextField(label: 'Full Address', controller: c3),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('First Name'), findsOneWidget);
        expect(find.text('Last Name'), findsOneWidget);
        expect(find.text('Full Address'), findsOneWidget);

        final addressFinder = find.byWidgetPredicate(
          (w) => w is UiTextField && w.label == 'Full Address',
        );
        final addressSize = tester.getSize(addressFinder);
        expect(addressSize.width, equals(800.0));

        c1.dispose();
        c2.dispose();
        c3.dispose();
      },
    );

    testWidgets(
      'UiFormLayout collapses to 1 column at 320px width without overflow',
      (tester) async {
        final c1 = TextEditingController();
        final c2 = TextEditingController();
        final c3 = TextEditingController();

        await tester.pumpWidget(
          _buildTestHost(
            width: 320,
            UiFormLayout(
              maxColumns: 2,
              children: [
                UiTextField(label: 'Field 1', controller: c1),
                UiFormSpan.wide(
                  child: UiTextField(label: 'Field 2', controller: c2),
                ),
                UiFormSpan.full(
                  child: UiTextField(label: 'Field 3', controller: c3),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        final f1 = tester.getSize(
          find.byWidgetPredicate(
            (w) => w is UiTextField && w.label == 'Field 1',
          ),
        );
        final f2 = tester.getSize(
          find.byWidgetPredicate(
            (w) => w is UiTextField && w.label == 'Field 2',
          ),
        );
        expect(f1.width, equals(320.0));
        expect(f2.width, equals(320.0));

        c1.dispose();
        c2.dispose();
        c3.dispose();
      },
    );

    testWidgets(
      'Direct shadcn controls compose seamlessly inside UiFormLayout',
      (tester) async {
        bool checkboxValue = false;
        bool switchValue = true;

        await tester.pumpWidget(
          _buildTestHost(
            width: 600,
            StatefulBuilder(
              builder: (context, setState) {
                return UiFormLayout(
                  children: [
                    shadcn.Checkbox(
                      state: checkboxValue
                          ? shadcn.CheckboxState.checked
                          : shadcn.CheckboxState.unchecked,
                      onChanged: (st) => setState(
                        () =>
                            checkboxValue = st == shadcn.CheckboxState.checked,
                      ),
                      trailing: const Text('Agree to Terms'),
                    ),
                    shadcn.Switch(
                      value: switchValue,
                      onChanged: (v) => setState(() => switchValue = v),
                      trailing: const Text('Enable Notifications'),
                    ),
                  ],
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Agree to Terms'), findsOneWidget);
        expect(find.text('Enable Notifications'), findsOneWidget);

        await tester.tap(find.text('Agree to Terms'));
        await tester.pumpAndSettle();
        expect(checkboxValue, isTrue);
      },
    );

    testWidgets(
      'Arbitrary caller custom field widget composes inside UiFormLayout',
      (tester) async {
        await tester.pumpWidget(
          _buildTestHost(
            width: 600,
            UiFormLayout(
              children: const [
                UiFieldShell(
                  label: 'Custom Rating',
                  control: SizedBox(height: 40, child: Text('★ ★ ★ ★ ☆')),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Custom Rating'), findsOneWidget);
        expect(find.text('★ ★ ★ ★ ☆'), findsOneWidget);
      },
    );

    testWidgets(
      'Keyboard Tab focus traversal order is deterministic row-major',
      (tester) async {
        final fn1 = FocusNode();
        final fn2 = FocusNode();
        final fn3 = FocusNode();
        final c1 = TextEditingController();
        final c2 = TextEditingController();
        final c3 = TextEditingController();

        await tester.pumpWidget(
          _buildTestHost(
            width: 600,
            UiFormLayout(
              children: [
                UiTextField(label: 'Field 1', controller: c1, focusNode: fn1),
                UiTextField(label: 'Field 2', controller: c2, focusNode: fn2),
                UiTextField(label: 'Field 3', controller: c3, focusNode: fn3),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        fn1.requestFocus();
        await tester.pumpAndSettle();
        expect(fn1.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(fn2.hasFocus, isTrue);

        await tester.sendKeyEvent(LogicalKeyboardKey.tab);
        await tester.pumpAndSettle();
        expect(fn3.hasFocus, isTrue);

        fn1.dispose();
        fn2.dispose();
        fn3.dispose();
        c1.dispose();
        c2.dispose();
        c3.dispose();
      },
    );

    testWidgets(
      'Large form (25+ fields) renders cleanly with minimal LayoutBuilder overhead',
      (tester) async {
        final controllers = List.generate(25, (_) => TextEditingController());
        final fields = List<Widget>.generate(
          25,
          (i) => UiTextField(label: 'Field $i', controller: controllers[i]),
        );

        await tester.pumpWidget(
          _buildTestHost(
            width: 960,
            UiContent(
              child: Column(
                children: [
                  UiSection(
                    title: 'Large Form Section',
                    description: '25 fields in responsive form layout',
                    child: UiFormLayout(maxColumns: 3, children: fields),
                  ),
                  const SizedBox(height: 24),
                  shadcn.PrimaryButton(
                    onPressed: () {},
                    child: const Text('Submit'),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Large Form Section'), findsOneWidget);
        expect(find.text('Field 0'), findsOneWidget);
        expect(find.text('Field 24'), findsOneWidget);
        expect(find.text('Submit'), findsOneWidget);

        for (final c in controllers) {
          c.dispose();
        }
      },
    );
  });
}
