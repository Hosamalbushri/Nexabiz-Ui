import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic multi-selection dropdown field using canonical [UiFieldShell] presentation.
///
/// Composes `shadcn.ControlledMultiSelect<T>` with accessible field chrome, placeholder,
/// and content-driven [Wrap] rendering for selected items to support scalable layouts
/// across narrow widths (320/420/960px) and large text scales (up to 200%).
class UiMultiSelectField<T> extends StatefulWidget {
  const UiMultiSelectField({
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
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final List<T> items;
  final List<T>? value;
  final ValueChanged<List<T>>? onChanged;
  final String Function(T item)? itemLabelBuilder;
  final Widget Function(BuildContext context, T item)? itemBuilder;
  final String? requiredIndicator;
  final String? description;
  final String? helper;
  final String? error;
  final String? placeholder;
  final FocusNode? focusNode;
  final bool enabled;
  final bool readOnly;

  @override
  State<UiMultiSelectField<T>> createState() => _UiMultiSelectFieldState<T>();
}

class _UiMultiSelectFieldState<T> extends State<UiMultiSelectField<T>> {
  late final shadcn.MultiSelectController<T> _controller;
  List<T>? _lastValue;

  @override
  void initState() {
    super.initState();
    _lastValue = widget.value == null ? null : List<T>.of(widget.value!);
    _controller = shadcn.MultiSelectController<T>(_lastValue);
  }

  @override
  void didUpdateWidget(UiMultiSelectField<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.value;
    if (!_sameValues(_lastValue, next)) {
      _lastValue = next == null ? null : List<T>.of(next);
      _controller.value = _lastValue;
    }
  }

  bool _sameValues(List<T>? a, List<T>? b) {
    if (a == null || b == null) return a == null && b == null;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
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
      control: shadcn.ControlledMultiSelect<T>(
        controller: _controller,
        onChanged: widget.readOnly || widget.onChanged == null
            ? null
            : (selectedIterable) {
                widget.onChanged!(selectedIterable?.toList() ?? <T>[]);
              },
        enabled: widget.enabled && !widget.readOnly,
        focusNode: widget.focusNode,
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
        itemBuilder: (builderContext, selectedItem) {
          return shadcn.Chip(
            child: Text(
              _getItemLabel(selectedItem),
              style: UiTextRole.supporting.resolve(builderContext),
            ),
          );
        },
      ),
    );
  }
}
