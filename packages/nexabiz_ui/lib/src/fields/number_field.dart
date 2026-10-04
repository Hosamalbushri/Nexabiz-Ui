import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';
import 'text_controller_bridge.dart';

/// A generic numeric input field with canonical [UiFieldShell] presentation.
///
/// Handles UI-generic numeric formatting, numeric keyboards, and intermediate
/// editing states (such as "-", ".", or "-."). Does not impose currency,
/// accounting rounding, or domain precision.
///
/// The caller owns [controller] (if provided) and numeric state callbacks.
class UiNumberField extends StatefulWidget {
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
  State<UiNumberField> createState() => _UiNumberFieldState();
}

class _UiNumberFieldState extends State<UiNumberField> {
  TextEditingController? _localController;
  FieldTextControllerBridge? _externalBridge;
  bool _syncingValue = false;
  String? _lastNotifiedText;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _localController = TextEditingController(text: widget.value?.toString());
    } else {
      _externalBridge = FieldTextControllerBridge(widget.controller!);
    }
    _lastNotifiedText = widget.controller?.text ?? _localController?.text;
  }

  @override
  void didUpdateWidget(UiNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      // A bridge sync can notify the upstream field immediately. Mark the
      // incoming value as parent-owned before replacing its source.
      _lastNotifiedText =
          widget.controller?.text ?? widget.value?.toString() ?? '';
      if (widget.controller == null) {
        _externalBridge?.dispose();
        _externalBridge = null;
        _localController = TextEditingController(
          text: widget.value?.toString(),
        );
      } else {
        _localController?.dispose();
        _localController = null;
        if (_externalBridge == null) {
          _externalBridge = FieldTextControllerBridge(widget.controller!);
        } else {
          _externalBridge!.replaceSource(widget.controller!);
        }
      }
    } else if (widget.controller == null && oldWidget.value != widget.value) {
      final next = widget.value?.toString() ?? '';
      if (_localController!.text != next) {
        _syncingValue = true;
        _localController!.value = TextEditingValue(
          text: next,
          selection: TextSelection.collapsed(offset: next.length),
        );
        _syncingValue = false;
      }
      _lastNotifiedText = next;
    }
  }

  @override
  void dispose() {
    _externalBridge?.dispose();
    _localController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pattern = widget.allowDecimals
        ? (widget.allowNegative ? r'^-?\d*\.?\d*' : r'^\d*\.?\d*')
        : (widget.allowNegative ? r'^-?\d*' : r'^\d*');

    return UiFieldShell(
      label: widget.label,
      requiredIndicator: widget.requiredIndicator,
      description: widget.description,
      helper: widget.helper,
      error: widget.error,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      control: shadcn.TextField(
        controller: _externalBridge?.proxy ?? _localController,
        focusNode: widget.focusNode,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        keyboardType: TextInputType.numberWithOptions(
          decimal: widget.allowDecimals,
          signed: widget.allowNegative,
        ),
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(pattern))],
        textInputAction: widget.textInputAction,
        style: UiTextRole.body.resolve(context),
        placeholder: widget.placeholder == null
            ? null
            : Text(widget.placeholder!),
        onChanged: (text) {
          if (_syncingValue || text == _lastNotifiedText) return;
          _lastNotifiedText = text;
          widget.onChanged?.call(text);
          if (widget.onNumberChanged != null) {
            widget.onNumberChanged!(UiNumberField.parseNumeric(text));
          }
        },
        onSubmitted: widget.onSubmitted,
        features: const [],
      ),
    );
  }
}
