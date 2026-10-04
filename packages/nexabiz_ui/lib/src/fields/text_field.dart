import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';
import 'text_controller_bridge.dart';

/// A single-line or multi-line shadcn input with the shared accessible field contract.
///
/// The caller owns and disposes [controller] and any supplied [focusNode].
/// Validation is controlled: the caller calculates [error] on change or submit.
/// There is no second form engine or implicit required-value validator.
class UiTextField extends StatefulWidget {
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
  State<UiTextField> createState() => _UiTextFieldState();
}

class _UiTextFieldState extends State<UiTextField> {
  late final FieldTextControllerBridge _bridge;
  late String _lastNotifiedText;

  @override
  void initState() {
    super.initState();
    _bridge = FieldTextControllerBridge(widget.controller);
    _lastNotifiedText = widget.controller.text;
  }

  @override
  void didUpdateWidget(UiTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _lastNotifiedText = widget.controller.text;
      _bridge.replaceSource(widget.controller);
    }
  }

  @override
  void dispose() {
    _bridge.dispose();
    super.dispose();
  }

  void _onChanged(String text) {
    if (_lastNotifiedText == text) return;
    _lastNotifiedText = text;
    widget.onChanged?.call(text);
  }

  @override
  Widget build(BuildContext context) => UiFieldShell(
    label: widget.label,
    requiredIndicator: widget.requiredIndicator,
    description: widget.description,
    helper: widget.helper,
    error: widget.error,
    enabled: widget.enabled,
    readOnly: widget.readOnly,
    control: shadcn.TextField(
      controller: _bridge.proxy,
      focusNode: widget.focusNode,
      onChanged: _onChanged,
      onSubmitted: widget.onSubmitted,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      obscureText: widget.obscureText,
      minLines: widget.minLines,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      textInputAction: widget.textInputAction,
      style: UiTextRole.body.resolve(context),
      placeholder: widget.placeholder == null
          ? null
          : Text(widget.placeholder!),
      features: const [],
    ),
  );
}
