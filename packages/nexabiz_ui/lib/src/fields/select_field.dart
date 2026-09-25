import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/typography.dart';
import 'field_shell.dart';

/// A generic single-selection dropdown field using canonical [UiFieldShell] presentation.
///
/// Composes `shadcn.ControlledSelect<T>` with accessible field chrome, placeholder,
/// item text/widget rendering, and optional unselection support.
class UiSelectField<T> extends StatelessWidget {
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

  String _getItemLabel(T item) {
    if (itemLabelBuilder != null) {
      return itemLabelBuilder!(item);
    }
    return item.toString();
  }

  Widget _buildItemContent(BuildContext context, T item) {
    if (itemBuilder != null) {
      return itemBuilder!(context, item);
    }
    return Text(_getItemLabel(item), style: UiTextRole.body.resolve(context));
  }

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
      control: shadcn.ControlledSelect<T>(
        initialValue: value,
        onChanged: readOnly ? null : onChanged,
        enabled: enabled && !readOnly,
        focusNode: focusNode,
        canUnselect: canUnselect,
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
        popup: (popupContext) => shadcn.SelectGroup(
          children: items
              .map(
                (item) => shadcn.SelectItemButton<T>(
                  value: item,
                  child: _buildItemContent(popupContext, item),
                ),
              )
              .toList(),
        ),
        itemBuilder: (builderContext, selectedValue) =>
            _buildItemContent(builderContext, selectedValue),
      ),
    );
  }
}
