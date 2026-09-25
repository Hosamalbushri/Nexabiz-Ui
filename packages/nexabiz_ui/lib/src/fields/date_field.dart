import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic date selection field using canonical [UiFieldShell] presentation.
///
/// Composes `shadcn.ControlledDatePicker` with accessible field chrome and placeholder,
/// using standard Dart [DateTime] values. Does not impose business/timezone rules.
class UiDateField extends StatelessWidget {
  const UiDateField({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.requiredIndicator,
    this.description,
    this.helper,
    this.error,
    this.placeholder,
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final String? requiredIndicator;
  final String? description;
  final String? helper;
  final String? error;
  final String? placeholder;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    return UiFieldShell(
      label: label,
      requiredIndicator: requiredIndicator,
      description: description,
      helper: helper,
      error: error,
      enabled: enabled,
      readOnly: readOnly,
      control: shadcn.ControlledDatePicker(
        initialValue: value,
        onChanged: readOnly ? null : onChanged,
        enabled: enabled && !readOnly,
        placeholder: placeholder == null
            ? null
            : Text(
                placeholder!,
                style: UiTextRole.body
                    .resolve(context)
                    .copyWith(
                      color: shadcn.Theme.of(
                        context,
                      ).colorScheme.mutedForeground,
                    ),
              ),
      ),
    );
  }
}
