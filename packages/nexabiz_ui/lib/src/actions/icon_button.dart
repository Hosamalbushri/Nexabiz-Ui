import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import 'button.dart';

/// Accessible icon-only button trigger for administrative actions and toolbars.
///
/// Requires an explicit [semanticLabel] to guarantee screen reader accessibility.
/// Optionally displays an overlay [tooltip] on hover or long-press.
class UiIconButton extends StatelessWidget {
  /// Creates an accessible icon button.
  const UiIconButton({
    super.key,
    required this.icon,
    required this.semanticLabel,
    this.onPressed,
    this.tooltip,
    this.variant = UiButtonVariant.ghost,
    this.size = UiButtonSize.md,
    this.enabled = true,
  });

  /// The icon widget displayed inside the button.
  final Widget icon;

  /// Required semantic label for accessibility screen readers.
  final String semanticLabel;

  /// Callback invoked when the button is tapped or triggered via keyboard (`Enter`, `Space`).
  ///
  /// If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Optional tooltip message shown on hover or long-press.
  final String? tooltip;

  /// Visual presentation style variant (defaults to [UiButtonVariant.ghost]).
  final UiButtonVariant variant;

  /// Sizing tier affecting padding and dimensions.
  final UiButtonSize size;

  /// Whether the button responds to interaction.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = enabled && onPressed != null;

    final variance = switch (variant) {
      UiButtonVariant.primary => shadcn.ButtonVariance.primary,
      UiButtonVariant.secondary => shadcn.ButtonVariance.outline,
      UiButtonVariant.ghost => shadcn.ButtonVariance.ghost,
      UiButtonVariant.destructive => shadcn.ButtonVariance.destructive,
      UiButtonVariant.link => shadcn.ButtonVariance.link,
    };

    final buttonSize = switch (size) {
      UiButtonSize.sm => shadcn.ButtonSize.small,
      UiButtonSize.md => shadcn.ButtonSize.normal,
      UiButtonSize.lg => const shadcn.ButtonSize(1.2),
    };

    Widget buttonWidget = shadcn.IconButton(
      icon: icon,
      variance: variance,
      size: buttonSize,
      enabled: isInteractive,
      onPressed: isInteractive ? onPressed : null,
    );

    if (tooltip != null && tooltip!.isNotEmpty) {
      buttonWidget = shadcn.Tooltip(
        tooltip: (context) => shadcn.TooltipContainer(child: Text(tooltip!)),
        child: buttonWidget,
      );
    }

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: semanticLabel,
      tooltip: tooltip,
      excludeSemantics: true,
      child: buttonWidget,
    );
  }
}
