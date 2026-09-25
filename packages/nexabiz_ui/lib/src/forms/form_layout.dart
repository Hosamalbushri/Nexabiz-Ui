import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/tokens.dart';
import '../foundation/typography.dart';

/// Content-driven columns; owns neither validation, scrolling nor actions.
///
/// Place inside a bounded-width host. Unbounded height is supported, including
/// a caller-owned scroll view. Large text increases the minimum column width.
class UiFormLayout extends StatelessWidget {
  const UiFormLayout({super.key, required this.children, this.maxColumns = 2})
    : assert(maxColumns > 0);

  final List<Widget> children;
  final int maxColumns;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      if (!constraints.hasBoundedWidth) {
        throw FlutterError('UiFormLayout requires a bounded horizontal host.');
      }
      final size = UiTextRole.body.resolve(context).fontSize!;
      final scale = math.max(
        1.0,
        MediaQuery.textScalerOf(context).scale(size) / size,
      );
      final minimum = UiTokens.formColumnMinWidth * scale;
      final columns = math.max(
        1,
        math.min(
          maxColumns,
          ((constraints.maxWidth + UiTokens.contentGap) /
                  (minimum + UiTokens.contentGap))
              .floor(),
        ),
      );
      final width = math.max(
        0.0,
        (constraints.maxWidth - UiTokens.contentGap * (columns - 1)) / columns,
      );
      return Wrap(
        spacing: UiTokens.contentGap,
        runSpacing: UiTokens.contentGap,
        children: [
          for (final child in children) SizedBox(width: width, child: child),
        ],
      );
    },
  );
}
