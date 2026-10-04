import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../composition/section.dart';
import '../foundation/tokens.dart';

/// A themed surface with optional section metadata and footer content.
class UiCard extends StatelessWidget {
  const UiCard({
    super.key,
    required this.child,
    this.title,
    this.description,
    this.header,
    this.footer,
    this.actions,
    this.padding,
    this.filled = false,
  });

  final Widget child;
  final String? title;
  final String? description;
  final Widget? header;
  final Widget? footer;
  final Widget? actions;
  final EdgeInsetsGeometry? padding;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final content = UiSection(
      title: title,
      description: description,
      trailing: actions,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (header != null) ...[
            header!,
            const SizedBox(height: UiTokens.fieldGap),
          ],
          child,
          if (footer != null) ...[
            const SizedBox(height: UiTokens.contentGap),
            footer!,
          ],
        ],
      ),
    );
    return shadcn.Card(padding: padding, filled: filled, child: content);
  }
}
