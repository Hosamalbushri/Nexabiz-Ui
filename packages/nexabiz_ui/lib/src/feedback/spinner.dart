import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Indeterminate loading spinner indicator.
///
/// Encapsulates upstream progress indicator primitives into a canonical
/// NexaBiz loading control without leaking upstream types.
class UiSpinner extends StatelessWidget {
  /// Creates a [UiSpinner] with optional size and color overrides.
  const UiSpinner({super.key, this.size, this.color, this.semanticLabel});

  /// The diameter of the spinner in logical pixels.
  ///
  /// If null, defaults to 16.0 or context-derived icon size.
  final double? size;

  /// The color of the spinner indicator arc.
  ///
  /// If null, derives color from the current [IconTheme.color] or theme primary color.
  final Color? color;

  /// Optional localized description supplied by the consuming application.
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final iconColor = IconTheme.of(context).color;
    final effectiveColor = color ?? iconColor ?? theme.colorScheme.primary;
    final effectiveSize = size ?? 16.0;

    final indicator = shadcn.CircularProgressIndicator(
      size: effectiveSize,
      color: effectiveColor,
    );
    if (semanticLabel == null) return indicator;
    return Semantics(
      label: semanticLabel,
      excludeSemantics: true,
      child: indicator,
    );
  }
}
