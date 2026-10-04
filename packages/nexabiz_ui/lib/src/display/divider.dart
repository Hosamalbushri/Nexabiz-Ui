import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

enum UiDividerOrientation { horizontal, vertical }

/// A decorative rule, optionally announced with caller-supplied text.
class UiDivider extends StatelessWidget {
  const UiDivider({
    super.key,
    this.orientation = UiDividerOrientation.horizontal,
    this.margin,
    this.thickness,
    this.semanticLabel,
  });

  final UiDividerOrientation orientation;
  final EdgeInsetsGeometry? margin;
  final double? thickness;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    Widget rule = switch (orientation) {
      UiDividerOrientation.horizontal => shadcn.Divider(thickness: thickness),
      UiDividerOrientation.vertical => shadcn.VerticalDivider(
        thickness: thickness,
      ),
    };
    if (margin != null) rule = Padding(padding: margin!, child: rule);
    if (semanticLabel == null) return ExcludeSemantics(child: rule);
    return Semantics(label: semanticLabel, excludeSemantics: true, child: rule);
  }
}
