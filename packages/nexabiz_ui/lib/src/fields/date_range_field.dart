import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic date range selection field using canonical [UiFieldShell] presentation.
///
/// Composes `shadcn.DateRangePicker` with accessible field chrome and placeholder,
/// using Flutter [DateTimeRange] values.
class UiDateRangeField extends StatelessWidget {
  const UiDateRangeField({
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
  final DateTimeRange? value;
  final ValueChanged<DateTimeRange?>? onChanged;
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
      control: shadcn.DateRangePicker(
        value: value == null
            ? null
            : shadcn.DateTimeRange(value!.start, value!.end),
        onChanged: enabled && !readOnly && onChanged != null
            ? (range) => onChanged!(
                range == null
                    ? null
                    : DateTimeRange(start: range.start, end: range.end),
              )
            : null,
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
