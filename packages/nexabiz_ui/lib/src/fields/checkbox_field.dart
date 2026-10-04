import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'field_shell.dart';

/// A controlled checkbox with a Flutter-only nullable value.
class UiCheckbox extends StatelessWidget {
  const UiCheckbox({
    super.key,
    required this.value,
    required this.onChanged,
    this.tristate = false,
    this.enabled = true,
    this.semanticLabel,
  });

  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final bool tristate;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onChanged != null;
    final state = switch (value) {
      true => shadcn.CheckboxState.checked,
      false => shadcn.CheckboxState.unchecked,
      null => shadcn.CheckboxState.indeterminate,
    };
    void change(shadcn.CheckboxState next) {
      if (!interactive) return;
      onChanged!(switch (next) {
        shadcn.CheckboxState.checked => true,
        shadcn.CheckboxState.unchecked => false,
        shadcn.CheckboxState.indeterminate => null,
      });
    }

    void toggle() {
      if (!interactive) return;
      change(
        tristate
            ? switch (state) {
                shadcn.CheckboxState.checked => shadcn.CheckboxState.unchecked,
                shadcn.CheckboxState.unchecked =>
                  shadcn.CheckboxState.indeterminate,
                shadcn.CheckboxState.indeterminate =>
                  shadcn.CheckboxState.checked,
              }
            : state == shadcn.CheckboxState.checked
            ? shadcn.CheckboxState.unchecked
            : shadcn.CheckboxState.checked,
      );
    }

    return Semantics(
      label: semanticLabel,
      checked: value,
      mixed: value == null,
      enabled: interactive,
      onTap: interactive ? toggle : null,
      excludeSemantics: true,
      child: shadcn.Checkbox(
        state: state,
        tristate: tristate,
        enabled: interactive,
        onChanged: interactive ? change : null,
      ),
    );
  }
}

/// A labeled checkbox with caller-owned state and field metadata.
class UiCheckboxField extends StatelessWidget {
  const UiCheckboxField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.helper,
    this.error,
    this.tristate = false,
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final bool? value;
  final ValueChanged<bool?>? onChanged;
  final String? description;
  final String? helper;
  final String? error;
  final bool tristate;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => UiFieldShell(
    label: label,
    description: description,
    helper: helper,
    error: error,
    enabled: enabled,
    readOnly: readOnly,
    control: UiCheckbox(
      value: value,
      onChanged: enabled && !readOnly ? onChanged : null,
      enabled: enabled && !readOnly,
      tristate: tristate,
    ),
  );
}
