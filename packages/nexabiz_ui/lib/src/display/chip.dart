import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Compact, optionally interactive tag with an independently operable delete action.
class UiChip extends StatelessWidget {
  const UiChip({
    super.key,
    required this.label,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onDeleted,
    this.enabled = true,
    this.deleteSemanticLabel,
  }) : assert(
         onDeleted == null ||
             (deleteSemanticLabel != null && deleteSemanticLabel != ''),
         'deleteSemanticLabel is required when onDeleted is supplied',
       );

  final Widget label;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final bool enabled;
  final String? deleteSemanticLabel;

  @override
  Widget build(BuildContext context) {
    if (onDeleted != null &&
        (deleteSemanticLabel == null || deleteSemanticLabel!.trim().isEmpty)) {
      throw ArgumentError.value(
        deleteSemanticLabel,
        'deleteSemanticLabel',
        'Must be non-empty when onDeleted is supplied',
      );
    }
    Widget? deleteControl;
    if (onDeleted != null) {
      deleteControl = Semantics(
        button: true,
        enabled: enabled,
        label: deleteSemanticLabel,
        excludeSemantics: true,
        child: shadcn.ChipButton(
          onPressed: enabled ? onDeleted : null,
          child: const Icon(
            IconData(0xe5cd, fontFamily: 'MaterialIcons'),
            size: 16,
          ),
        ),
      );
    }
    Widget body = shadcn.Chip(
      leading: leading,
      trailing: trailing,
      onPressed: enabled ? onPressed : null,
      child: label,
    );
    if (!enabled || onPressed == null) {
      body = ExcludeFocus(child: IgnorePointer(child: body));
    }
    if (deleteControl == null) return body;
    return Row(mainAxisSize: MainAxisSize.min, children: [body, deleteControl]);
  }
}
