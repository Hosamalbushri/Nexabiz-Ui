import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../feedback/spinner.dart';
import '../foundation/tokens.dart';

/// Visual style variants for [UiButton].
enum UiButtonVariant {
  /// Prominent primary action with filled high-contrast surface.
  primary,

  /// Secondary action with visible border and transparent background (outline).
  secondary,

  /// Subtle borderless action with minimal visual footprint.
  ghost,

  /// Critical or destructive action with danger styling.
  destructive,

  /// Link-styled action resembling inline hypertext.
  link,
}

/// Sizing tiers for [UiButton].
enum UiButtonSize {
  /// Compact size for tight spaces or data rows.
  sm,

  /// Standard default size for administrative workflows.
  md,

  /// Prominent size for high-priority actions and large viewports.
  lg,
}

/// Unified interactive action button for administrative and back-office applications.
///
/// Encapsulates upstream button primitives into an enterprise design system contract,
/// providing consistent state handling, loading animations, accessibility semantics,
/// and keyboard activation without exposing upstream types.
class UiButton extends StatelessWidget {
  /// Creates a [UiButton] with customizable variant and size.
  const UiButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = UiButtonVariant.primary,
    this.size = UiButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.loadingSemanticLabel,
    this.enabled = true,
  });

  /// Creates a secondary outline [UiButton].
  const UiButton.outline({
    super.key,
    required this.label,
    this.onPressed,
    this.size = UiButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.loadingSemanticLabel,
    this.enabled = true,
  }) : variant = UiButtonVariant.secondary;

  /// Creates a subtle borderless ghost [UiButton].
  const UiButton.ghost({
    super.key,
    required this.label,
    this.onPressed,
    this.size = UiButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.loadingSemanticLabel,
    this.enabled = true,
  }) : variant = UiButtonVariant.ghost;

  /// Creates a danger/destructive [UiButton] for deleting or removing data.
  const UiButton.destructive({
    super.key,
    required this.label,
    this.onPressed,
    this.size = UiButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.isLoading = false,
    this.loadingSemanticLabel,
    this.enabled = true,
  }) : variant = UiButtonVariant.destructive;

  /// The text content displayed inside the button.
  final String label;

  /// Callback invoked when the button is tapped or triggered via keyboard (`Enter`, `Space`).
  ///
  /// If null, the button is disabled.
  final VoidCallback? onPressed;

  /// Visual presentation style variant.
  final UiButtonVariant variant;

  /// Size tier affecting dimensions, typography scaling, and internal padding.
  final UiButtonSize size;

  /// Optional widget displayed before the label (on the leading side).
  final Widget? leadingIcon;

  /// Optional widget displayed after the label (on the trailing side).
  final Widget? trailingIcon;

  /// Whether the button is in a busy/loading state.
  ///
  /// When true, renders [UiSpinner] without altering dimensions or shifting layout,
  /// and suppresses pointer and keyboard activation callbacks.
  final bool isLoading;

  /// Optional caller-localized accessible name while loading.
  ///
  /// When omitted, [label] remains the accessible name.
  final String? loadingSemanticLabel;

  /// Whether the button responds to interaction.
  final bool enabled;

  static double _spinnerSize(UiButtonSize size) {
    switch (size) {
      case UiButtonSize.sm:
        return 14.0;
      case UiButtonSize.md:
        return 16.0;
      case UiButtonSize.lg:
        return 18.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isInteractive = enabled && !isLoading && onPressed != null;
    const double gap = UiTokens.fieldGap;

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

    final Widget labelWidget = Text(label, textAlign: TextAlign.center);

    Widget buttonContent;
    if (leadingIcon != null || trailingIcon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            leadingIcon!,
            const SizedBox(width: gap),
          ],
          Flexible(child: labelWidget),
          if (trailingIcon != null) ...[
            const SizedBox(width: gap),
            trailingIcon!,
          ],
        ],
      );
    } else {
      buttonContent = labelWidget;
    }

    final Widget effectiveContent;
    if (isLoading) {
      effectiveContent = Stack(
        alignment: Alignment.center,
        children: [
          Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: buttonContent,
          ),
          ExcludeSemantics(child: UiSpinner(size: _spinnerSize(size))),
        ],
      );
    } else {
      effectiveContent = buttonContent;
    }

    final buttonStyle = shadcn.ButtonStyle(
      variance: variance,
      size: buttonSize,
    );

    final buttonWidget = shadcn.Button(
      style: buttonStyle,
      enabled: isInteractive,
      onPressed: isInteractive ? onPressed : null,
      child: effectiveContent,
    );

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: isLoading ? (loadingSemanticLabel ?? label) : label,
      excludeSemantics: true,
      child: buttonWidget,
    );
  }
}
