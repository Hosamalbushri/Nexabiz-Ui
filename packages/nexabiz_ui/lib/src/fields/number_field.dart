import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic numeric input field with canonical [UiFieldShell] presentation.
///
/// Handles UI-generic numeric formatting, numeric keyboards, and intermediate
/// editing states (such as "-", ".", or "-."). Does not impose currency,
/// accounting rounding, or domain precision.
///
/// The caller owns [controller] (if provided) and numeric state callbacks.
class UiNumberField extends StatelessWidget {
  const UiNumberField({
    super.key,
    required this.label,
    this.controller,
    this.value,
    this.requiredIndicator,
    this.description,
    this.helper,
    this.error,
    this.placeholder,
    this.focusNode,
    this.onNumberChanged,
    this.onChanged,
    this.onSubmitted,
    this.allowDecimals = true,
    this.allowNegative = true,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction = TextInputAction.next,
  }) : assert(
         controller != null || onNumberChanged != null || onChanged != null,
         'Either controller or an onChanged callback must be provided',
       );

  final String label;
  final TextEditingController? controller;
  final num? value;
  final String? requiredIndicator;
  final String? description;
  final String? helper;
  final String? error;
  final String? placeholder;
  final FocusNode? focusNode;
  final ValueChanged<num?>? onNumberChanged;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool allowDecimals;
  final bool allowNegative;
  final bool enabled;
  final bool readOnly;
  final TextInputAction textInputAction;

  static num? parseNumeric(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty ||
        trimmed == '-' ||
        trimmed == '.' ||
        trimmed == '-.') {
      return null;
    }
    return num.tryParse(trimmed);
  }

  @override
  Widget build(BuildContext context) {
    final pattern = allowDecimals
        ? (allowNegative ? r'^-?\d*\.?\d*' : r'^\d*\.?\d*')
        : (allowNegative ? r'^-?\d*' : r'^\d*');

    return UiFieldShell(
      label: label,
      requiredIndicator: requiredIndicator,
      description: description,
      helper: helper,
      error: error,
      enabled: enabled,
      readOnly: readOnly,
      control: shadcn.TextField(
        controller: controller,
        initialValue: controller == null && value != null
            ? value.toString()
            : null,
        focusNode: focusNode,
        enabled: enabled,
        readOnly: readOnly,
        keyboardType: TextInputType.numberWithOptions(
          decimal: allowDecimals,
          signed: allowNegative,
        ),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(pattern))],
        textInputAction: textInputAction,
        style: UiTextRole.body.resolve(context),
        placeholder: placeholder == null ? null : Text(placeholder!),
        onChanged: (text) {
          onChanged?.call(text);
          if (onNumberChanged != null) {
            onNumberChanged!(parseNumeric(text));
          }
        },
        onSubmitted: onSubmitted,
        features: const [],
      ),
    );
  }
}
