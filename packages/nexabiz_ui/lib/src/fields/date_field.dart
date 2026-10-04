import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic date selection field using canonical [UiFieldShell] presentation.
///
/// Composes `shadcn.ControlledDatePicker` with accessible field chrome and placeholder,
/// using standard Dart [DateTime] values. Does not impose business/timezone rules.
class UiDateField extends StatefulWidget {
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
  State<UiDateField> createState() => _UiDateFieldState();
}

class _UiDateFieldState extends State<UiDateField> {
  late final shadcn.DatePickerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = shadcn.DatePickerController(widget.value);
  }

  @override
  void didUpdateWidget(UiDateField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _controller.value = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return UiFieldShell(
      label: widget.label,
      requiredIndicator: widget.requiredIndicator,
      description: widget.description,
      helper: widget.helper,
      error: widget.error,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      control: shadcn.ControlledDatePicker(
        controller: _controller,
        onChanged: widget.readOnly ? null : widget.onChanged,
        enabled: widget.enabled && !widget.readOnly,
        placeholder: widget.placeholder == null
            ? null
            : Text(
                widget.placeholder!,
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
