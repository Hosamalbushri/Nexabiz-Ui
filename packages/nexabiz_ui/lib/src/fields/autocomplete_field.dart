import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic local autocomplete field using canonical [UiFieldShell] presentation.
///
/// Wraps `shadcn.TextField` inside `shadcn.AutoComplete` to present filtered local
/// string suggestions based on user input, while preserving caller ownership of
/// controllers and validation errors.
class UiAutocompleteField extends StatefulWidget {
  const UiAutocompleteField({
    super.key,
    required this.label,
    required this.controller,
    required this.suggestions,
    this.requiredIndicator,
    this.description,
    this.helper,
    this.error,
    this.placeholder,
    this.focusNode,
    this.onChanged,
    this.onSelected,
    this.onSubmitted,
    this.enabled = true,
    this.readOnly = false,
    this.textInputAction = TextInputAction.next,
  });

  final String label;
  final TextEditingController controller;
  final List<String> suggestions;
  final String? requiredIndicator;
  final String? description;
  final String? helper;
  final String? error;
  final String? placeholder;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSelected;
  final ValueChanged<String>? onSubmitted;
  final bool enabled;
  final bool readOnly;
  final TextInputAction textInputAction;

  @override
  State<UiAutocompleteField> createState() => _UiAutocompleteFieldState();
}

class _UiAutocompleteFieldState extends State<UiAutocompleteField> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(UiAutocompleteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  List<String> _getFilteredSuggestions(String query) {
    if (query.trim().isEmpty) {
      return widget.suggestions;
    }
    final lowercaseQuery = query.toLowerCase();
    return widget.suggestions
        .where(
          (suggestion) => suggestion.toLowerCase().contains(lowercaseQuery),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _getFilteredSuggestions(widget.controller.text);

    return UiFieldShell(
      label: widget.label,
      requiredIndicator: widget.requiredIndicator,
      description: widget.description,
      helper: widget.helper,
      error: widget.error,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      control: shadcn.AutoComplete(
        suggestions: filtered,
        completer: (suggestion) {
          widget.onSelected?.call(suggestion);
          return suggestion;
        },
        child: shadcn.TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          enabled: widget.enabled,
          readOnly: widget.readOnly,
          textInputAction: widget.textInputAction,
          style: UiTextRole.body.resolve(context),
          placeholder: widget.placeholder == null
              ? null
              : Text(widget.placeholder!),
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          features: const [],
        ),
      ),
    );
  }
}
