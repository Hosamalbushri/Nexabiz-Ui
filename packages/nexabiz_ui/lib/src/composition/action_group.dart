import 'package:flutter/widgets.dart';

import '../foundation/tokens.dart';

/// Responsive arrangement of action controls based on content fit.
///
/// Wraps actions cleanly when local horizontal width is insufficient without
/// imposing arbitrary window breakpoints or wrapping child button widgets.
class UiActionGroup extends StatelessWidget {
  const UiActionGroup({
    super.key,
    required this.children,
    this.alignment = WrapAlignment.start,
    this.crossAxisAlignment = WrapCrossAlignment.center,
    this.spacing = UiTokens.fieldGap,
    this.runSpacing = UiTokens.fieldGap,
  });

  final List<Widget> children;
  final WrapAlignment alignment;
  final WrapCrossAlignment crossAxisAlignment;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();

    return Wrap(
      alignment: alignment,
      crossAxisAlignment: crossAxisAlignment,
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}
