import 'package:flutter/widgets.dart';

/// Structural tiers evaluated against the immediate parent's available width.
enum UiLayoutTier {
  compact,
  medium,
  expanded,
  wide;

  static UiLayoutTier forWidth(double width) {
    assert(width >= 0 && width.isFinite);
    if (width < 600) return compact;
    if (width < 1000) return medium;
    if (width < 1440) return expanded;
    return wide;
  }
}

/// Reports local horizontal constraints. Requires a bounded horizontal host.
/// An unbounded host is an explicit composition error, with no viewport fallback.
class UiResponsive extends StatelessWidget {
  const UiResponsive({super.key, required this.builder});

  final Widget Function(BuildContext context, double width, UiLayoutTier tier)
  builder;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (!constraints.hasBoundedWidth) {
        throw FlutterError('UiResponsive requires a bounded horizontal host.');
      }
      return builder(
        context,
        constraints.maxWidth,
        UiLayoutTier.forWidth(constraints.maxWidth),
      );
    },
  );
}
