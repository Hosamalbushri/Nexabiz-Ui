import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'field_shell.dart';

/// A controlled boolean switch.
class UiSwitch extends StatelessWidget {
  const UiSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.semanticLabel,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onChanged != null;
    return Semantics(
      label: semanticLabel,
      toggled: value,
      enabled: interactive,
      onTap: interactive ? () => onChanged!(!value) : null,
      excludeSemantics: true,
      child: shadcn.Switch(
        value: value,
        enabled: interactive,
        onChanged: interactive ? onChanged : null,
      ),
    );
  }
}

/// A labeled switch with caller-owned state and field metadata.
class UiSwitchField extends StatelessWidget {
  const UiSwitchField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.description,
    this.helper,
    this.error,
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final bool value;
  final ValueChanged<bool>? onChanged;
  final String? description;
  final String? helper;
  final String? error;
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
    control: UiSwitch(
      value: value,
      onChanged: enabled && !readOnly ? onChanged : null,
      enabled: enabled && !readOnly,
    ),
  );
}
