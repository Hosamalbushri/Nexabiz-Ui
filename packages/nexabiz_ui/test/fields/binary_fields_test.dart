import 'dart:ui' as ui;

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
  double width = 360,
}) => shadcn.ShadcnApp(
  home: Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: shadcn.Scaffold(
        child: SingleChildScrollView(
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('checkbox pointer, keyboard, tri-state and parent value', (
    tester,
  ) async {
    bool? value = false;
    final changes = <bool?>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => UiCheckbox(
            value: value,
            semanticLabel: 'Choose item',
            tristate: true,
            onChanged: (next) {
              changes.add(next);
              setState(() => value = next);
            },
          ),
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(UiCheckbox)).label, 'Choose item');
    await tester.tap(find.byType(UiCheckbox));
    await tester.pump();
    expect(changes, [null]);
    expect(
      tester.getSemantics(find.byType(UiCheckbox)).flagsCollection.isChecked,
      ui.CheckedState.mixed,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(changes, [null, true]);
    expect(
      tester.getSemantics(find.byType(UiCheckbox)).flagsCollection.isChecked,
      ui.CheckedState.isTrue,
    );
    await tester.pumpWidget(
      host(
        UiCheckbox(
          value: false,
          semanticLabel: 'Choose item',
          onChanged: changes.add,
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(UiCheckbox)).flagsCollection.isChecked,
      ui.CheckedState.isFalse,
    );
    expect(changes, hasLength(2));
  });

  testWidgets('switch pointer and Enter produce one callback each', (
    tester,
  ) async {
    var value = false;
    var calls = 0;
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => UiSwitch(
            value: value,
            semanticLabel: 'Notifications',
            onChanged: (next) {
              calls++;
              setState(() => value = next);
            },
          ),
        ),
      ),
    );
    await tester.tap(find.byType(UiSwitch));
    await tester.pump();
    expect(value, true);
    expect(calls, 1);
    expect(
      tester.getSemantics(find.byType(UiSwitch)).flagsCollection.isToggled,
      ui.Tristate.isTrue,
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(value, false);
    expect(calls, 2);
  });

  testWidgets('radio pointer selection, parent update and option semantics', (
    tester,
  ) async {
    var value = 1;
    var calls = 0;
    const options = [
      UiRadioOption(value: 1, label: 'First'),
      UiRadioOption(value: 2, label: 'Second', description: 'Second hint'),
      UiRadioOption(value: 3, label: 'Unavailable', enabled: false),
    ];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => UiRadioGroup<int>(
            options: options,
            value: value,
            semanticLabel: 'Priority',
            onChanged: (next) {
              calls++;
              setState(() => value = next);
            },
          ),
        ),
      ),
    );
    expect(
      tester.getSemantics(find.byType(UiRadioGroup<int>)).label,
      contains('Priority'),
    );
    await tester.tap(find.text('Second'));
    await tester.pump();
    expect(value, 2);
    expect(calls, 1);
    await tester.tap(find.text('Unavailable'));
    await tester.pump();
    expect(calls, 1);
    await tester.pumpWidget(
      host(
        UiRadioGroup<int>(
          options: options,
          value: 1,
          onChanged: (_) => calls++,
        ),
      ),
    );
    expect(calls, 1);
    expect(find.text('First'), findsOneWidget);
  });

  testWidgets('slider pointer, arrow and parent value stay controlled', (
    tester,
  ) async {
    var value = 0.25;
    final changes = <double>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => UiSlider(
            value: value,
            min: 0,
            max: 1,
            divisions: 4,
            semanticLabel: 'Amount',
            semanticValue: 'One quarter',
            onChanged: (next) {
              changes.add(next);
              setState(() => value = next);
            },
          ),
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(UiSlider)).label, 'Amount');
    expect(tester.getSemantics(find.byType(UiSlider)).value, 'One quarter');
    final rect = tester.getRect(find.byType(UiSlider));
    await tester.tapAt(Offset(rect.left + rect.width * .75, rect.center.dy));
    await tester.pump();
    expect(value, closeTo(.75, .26));
    expect(changes, isNotEmpty);
    final before = changes.length;
    await tester.pumpWidget(
      host(
        UiSlider(value: .5, semanticLabel: 'Amount', onChanged: changes.add),
      ),
    );
    expect(changes, hasLength(before));
    expect(tester.getSemantics(find.byType(UiSlider)).label, 'Amount');
  });

  testWidgets('radio arrows traverse choices without duplicate callbacks', (
    tester,
  ) async {
    int? value;
    final changes = <int>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => UiRadioGroup<int>(
            options: const [
              UiRadioOption(value: 1, label: 'One'),
              UiRadioOption(value: 2, label: 'Two'),
            ],
            value: value,
            semanticLabel: 'Level',
            onChanged: (next) {
              changes.add(next);
              setState(() => value = next);
            },
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final before = changes.length;
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(value, 1);
    expect(changes.length, before + 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(value, 2);
    expect(changes.length, before + 2);
  });

  testWidgets(
    'radio RTL arrows skip disabled options and survive option removal',
    (tester) async {
      var value = 1;
      final changes = <int>[];
      final options = <UiRadioOption<int>>[
        const UiRadioOption(value: 1, label: 'أول'),
        const UiRadioOption(value: 2, label: 'معطل', enabled: false),
        const UiRadioOption(value: 3, label: 'ثالث'),
      ];
      Widget group() => host(
        StatefulBuilder(
          builder: (context, setState) => UiRadioGroup<int>(
            options: options,
            value: value,
            semanticLabel: 'خيارات',
            onChanged: (next) {
              changes.add(next);
              setState(() => value = next);
            },
          ),
        ),
        direction: TextDirection.rtl,
      );
      await tester.pumpWidget(group());
      expect(find.bySemanticsLabel('معطل'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
      await tester.pump();
      expect(value, 3);
      expect(changes, [3]);
      expect(options, hasLength(3));
      options.removeLast();
      value = 1;
      await tester.pumpWidget(group());
      await tester.pump();
      expect(find.text('ثالث'), findsNothing);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const SizedBox.shrink()));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('slider arrow keys change the caller-owned value', (
    tester,
  ) async {
    var value = .5;
    final changes = <double>[];
    await tester.pumpWidget(
      host(
        StatefulBuilder(
          builder: (context, setState) => UiSlider(
            value: value,
            divisions: 4,
            semanticLabel: 'Level',
            semanticValue: 'Half',
            onChanged: (next) {
              changes.add(next);
              setState(() => value = next);
            },
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pump();
    expect(value, closeTo(.75, .0001));
    expect(changes, hasLength(1));
  });

  testWidgets('slider rejects invalid range and divisions', (tester) async {
    await tester.pumpWidget(
      host(UiSlider(value: .5, min: 1, max: 0, onChanged: (_) {})),
    );
    expect(tester.takeException(), isArgumentError);
    await tester.pumpWidget(
      host(UiSlider(value: .5, divisions: 0, onChanged: (_) {})),
    );
    expect(tester.takeException(), isArgumentError);
    await tester.pumpWidget(host(UiSlider(value: 2, onChanged: (_) {})));
    expect(tester.takeException(), isArgumentError);
  });

  testWidgets('field semantics use their labels once', (tester) async {
    await tester.pumpWidget(
      host(
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            UiCheckboxField(label: 'Accept', value: false, onChanged: null),
            UiSwitchField(label: 'Updates', value: true, onChanged: null),
            UiRadioGroupField<int>(
              label: 'Priority',
              options: [UiRadioOption(value: 1, label: 'First')],
              value: 1,
              onChanged: null,
              requiredIndicator: true,
            ),
            UiSliderField(
              label: 'Volume',
              value: .5,
              onChanged: null,
              valueLabel: '50 percent',
              semanticValue: 'Half',
              requiredIndicator: true,
            ),
          ],
        ),
      ),
    );
    for (final name in ['Accept', 'Updates', 'Priority', 'Volume']) {
      expect(find.bySemanticsLabel(name), findsWidgets);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('all field states gate changes in LTR and RTL', (tester) async {
    for (final direction in TextDirection.values) {
      for (final enabled in [true, false]) {
        for (final readOnly in [true, false]) {
          var calls = 0;
          await tester.pumpWidget(
            host(
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  UiCheckboxField(
                    label: 'Check',
                    value: false,
                    onChanged: (_) => calls++,
                    enabled: enabled,
                    readOnly: readOnly,
                  ),
                  UiSwitchField(
                    label: 'Switch',
                    value: false,
                    onChanged: (_) => calls++,
                    enabled: enabled,
                    readOnly: readOnly,
                  ),
                  UiRadioGroupField<int>(
                    label: 'Radio',
                    options: const [UiRadioOption(value: 1, label: 'Option')],
                    value: null,
                    onChanged: (_) => calls++,
                    requiredIndicator: true,
                    enabled: enabled,
                    readOnly: readOnly,
                  ),
                  UiSliderField(
                    label: 'Slider',
                    value: .25,
                    onChanged: (_) => calls++,
                    semanticValue: 'Twenty five percent',
                    valueLabel: '25%',
                    requiredIndicator: true,
                    enabled: enabled,
                    readOnly: readOnly,
                  ),
                ],
              ),
              direction: direction,
            ),
          );
          await tester.tap(find.byType(UiCheckbox));
          await tester.tap(find.byType(UiSwitch));
          await tester.tap(find.text('Option'));
          await tester.tapAt(
            tester.getRect(find.byType(UiSlider)).centerRight -
                const Offset(12, 0),
          );
          await tester.pump();
          expect(calls, enabled && !readOnly ? greaterThan(0) : 0);
          expect(tester.takeException(), isNull);
        }
      }
    }
  });

  testWidgets('large text and narrow RTL/LTR host do not overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final direction in TextDirection.values) {
      await tester.pumpWidget(
        host(
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              UiCheckboxField(label: 'اختيار', value: null, onChanged: null),
              UiSwitchField(label: 'تفعيل', value: true, onChanged: null),
              UiRadioGroupField<int>(
                label: 'الأولوية',
                options: [UiRadioOption(value: 1, label: 'أولاً')],
                value: 1,
                onChanged: null,
              ),
              UiSliderField(
                label: 'الكمية',
                value: .5,
                onChanged: null,
                valueLabel: 'نصف',
                semanticValue: 'نصف',
              ),
            ],
          ),
          direction: direction,
          scale: 2,
          width: 280,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });
}
