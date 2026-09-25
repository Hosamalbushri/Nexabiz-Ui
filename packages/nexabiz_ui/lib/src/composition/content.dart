import 'package:flutter/widgets.dart';

import '../foundation/tokens.dart';

/// Generic bounded content container respecting parent local constraints.
///
/// Applies directional padding and an optional maximum readable width while
/// remaining independent of page structure, navigation, scrolling or scaffold.
class UiContent extends StatelessWidget {
  const UiContent({
    super.key,
    required this.child,
    this.maxWidth = UiTokens.formMaxWidth,
    this.padding = const EdgeInsetsDirectional.all(UiTokens.contentGap),
    this.alignment = AlignmentDirectional.topCenter,
  });

  final Widget child;
  final double? maxWidth;
  final EdgeInsetsGeometry? padding;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    Widget content = child;
    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }
    if (maxWidth != null && maxWidth! > 0) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth!),
        child: content,
      );
    }
    return Align(alignment: alignment, child: content);
  }
}
