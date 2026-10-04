import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  test('choice controls compile through Flutter and public NexaBiz only', () {
    final controls = <Widget>[
      UiCheckbox(value: false, onChanged: (_) {}, semanticLabel: 'Check'),
      UiCheckboxField(label: 'Check', value: false, onChanged: (_) {}),
      UiSwitch(value: false, onChanged: (_) {}, semanticLabel: 'Switch'),
      UiSwitchField(label: 'Switch', value: false, onChanged: (_) {}),
      UiRadioGroup<int>(
        options: const [UiRadioOption(value: 1, label: 'One')],
        value: 1,
        onChanged: (_) {},
        semanticLabel: 'Group',
      ),
      UiRadioGroupField<int>(
        label: 'Group',
        options: const [UiRadioOption(value: 1, label: 'One')],
        value: 1,
        onChanged: (_) {},
        requiredIndicator: true,
      ),
      UiSlider(
        value: .5,
        onChanged: (_) {},
        semanticLabel: 'Slider',
        semanticValue: 'Half',
      ),
      UiSliderField(
        label: 'Slider',
        value: .5,
        onChanged: (_) {},
        semanticValue: 'Half',
        valueLabel: '50%',
        requiredIndicator: true,
      ),
    ];
    expect(controls, hasLength(8));
  });
}
