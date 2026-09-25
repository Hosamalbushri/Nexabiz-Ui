import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'form_span.dart';

/// Content-driven multi-column layout for form fields and controls.
///
/// Features local-constraint responsiveness, dynamic column reduction under
/// large text scale, top-aligned child geometry, and support for [UiFormSpan]
/// field span requests (`normal`, `wide`, `full`).
///
/// Owns neither validation rules, scrolling, navigation, nor form state.
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
      final singleColumnWidth = math.max(
        0.0,
        (constraints.maxWidth - UiTokens.contentGap * (columns - 1)) / columns,
      );

      return Wrap(
        spacing: UiTokens.contentGap,
        runSpacing: UiTokens.contentGap,
        crossAxisAlignment: WrapCrossAlignment.start,
        children: [
          for (final child in children) ...[
            _buildChild(
              child,
              columns: columns,
              singleColumnWidth: singleColumnWidth,
              maxWidth: constraints.maxWidth,
            ),
          ],
        ],
      );
    },
  );

  Widget _buildChild(
    Widget child, {
    required int columns,
    required double singleColumnWidth,
    required double maxWidth,
  }) {
    UiFormSpanType span = UiFormSpanType.normal;
    if (child is UiFormSpan) {
      span = child.span;
    }

    if (columns == 1 || span == UiFormSpanType.normal) {
      return SizedBox(width: singleColumnWidth, child: child);
    }

    if (span == UiFormSpanType.full) {
      return SizedBox(width: maxWidth, child: child);
    }

    // span == UiFormSpanType.wide
    if (columns == 2) {
      return SizedBox(width: maxWidth, child: child);
    }

    final wideWidth = math.min(
      maxWidth,
      singleColumnWidth * 2 + UiTokens.contentGap,
    );
    return SizedBox(width: wideWidth, child: child);
  }
}
