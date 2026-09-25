import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A single-line or multi-line shadcn input with the shared accessible field contract.
///
/// The caller owns and disposes [controller] and any supplied [focusNode].
/// Validation is controlled: the caller calculates [error] on change or submit.
/// There is no second form engine or implicit required-value validator.
class UiTextField extends StatelessWidget {
  const UiTextField({
    super.key,
    required this.label,
    required this.controller,
    this.requiredIndicator,
    this.description,
    this.helper,
    this.error,
    this.placeholder,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.obscureText = false,
    this.minLines,
    this.maxLines = 1,
    this.keyboardType,
    this.inputFormatters,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final TextEditingController controller;
  final String? requiredIndicator;
  final String? description;
  final String? helper;
  final String? error;
  final String? placeholder;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final bool obscureText;
  final int? minLines;
  final int? maxLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputAction textInputAction;

  @override
  Widget build(BuildContext context) => UiFieldShell(
    label: label,
    requiredIndicator: requiredIndicator,
    description: description,
    helper: helper,
    error: error,
    enabled: enabled,
    readOnly: readOnly,
    control: shadcn.TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      enabled: enabled,
      readOnly: readOnly,
      obscureText: obscureText,
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textInputAction: textInputAction,
      style: UiTextRole.body.resolve(context),
      placeholder: placeholder == null ? null : Text(placeholder!),
      features: const [],
    ),
  );
}
