import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic single-selection dropdown field using canonical [UiFieldShell] presentation.
///
/// Composes `shadcn.ControlledSelect<T>` with accessible field chrome, placeholder,
/// item text/widget rendering, and optional unselection support.
class UiSelectField<T> extends StatefulWidget {
  const UiSelectField({
    super.key,
    required this.label,
    required this.items,
    this.value,
    this.onChanged,
    this.itemLabelBuilder,
    this.itemBuilder,
    this.requiredIndicator,
    this.description,
    this.helper,
    this.error,
    this.placeholder,
    this.focusNode,
    this.canUnselect = false,
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final List<T> items;
  final T? value;
  final ValueChanged<T?>? onChanged;
  final String Function(T item)? itemLabelBuilder;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final String? requiredIndicator;
  final String? description;
  final String? helper;
  final String? error;
  final String? placeholder;
  final FocusNode? focusNode;
  final bool canUnselect;
  final bool enabled;
  final bool readOnly;

  @override
  State<UiSelectField<T>> createState() => _UiSelectFieldState<T>();
}

class _UiSelectFieldState<T> extends State<UiSelectField<T>> {
  late final shadcn.SelectController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = shadcn.SelectController<T>(widget.value);
  }

  @override
  void didUpdateWidget(UiSelectField<T> oldWidget) {
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

  String _getItemLabel(T item) {
    if (widget.itemLabelBuilder != null) {
      return widget.itemLabelBuilder!(item);
    }
    return item.toString();
  }

  Widget _buildItemContent(BuildContext context, T item) {
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(context, item);
    }
    return Text(_getItemLabel(item), style: UiTextRole.body.resolve(context));
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
      control: shadcn.ControlledSelect<T>(
        controller: _controller,
        onChanged: widget.readOnly ? null : widget.onChanged,
        enabled: widget.enabled && !widget.readOnly,
        focusNode: widget.focusNode,
        canUnselect: widget.canUnselect,
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
        popup: (_) => shadcn.SelectPopup<T>(
          items: shadcn.SelectItemBuilder(
            childCount: widget.items.length,
            builder: (itemContext, index) {
              final item = widget.items[index];
              return shadcn.SelectItemButton<T>(
                value: item,
                child: _buildItemContent(itemContext, item),
              );
            },
          ),
        ),
        itemBuilder: (builderContext, selectedValue) =>
            _buildItemContent(builderContext, selectedValue),
      ),
    );
  }
}
