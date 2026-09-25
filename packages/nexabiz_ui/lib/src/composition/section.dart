import 'package:flutter/widgets.dart';

import '../foundation/tokens.dart';
import '../foundation/typography.dart';

/// Composition primitive for content sections with title, description, and actions.
///
/// Standardizes structural hierarchy and semantic headers without forcing card
/// appearance, fixed backgrounds, scrolling or domain-specific section rules.
class UiSection extends StatelessWidget {
  const UiSection({
    super.key,
    required this.child,
    this.title,
    this.titleWidget,
    this.description,
    this.descriptionWidget,
    this.trailing,
    this.gap = UiTokens.fieldGap,
  }) : assert(
         title == null || titleWidget == null,
         'Cannot specify both title and titleWidget',
       ),
       assert(
         description == null || descriptionWidget == null,
         'Cannot specify both description and descriptionWidget',
       );

  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final String? description;
  final Widget? descriptionWidget;
  final Widget? trailing;
  final double gap;

  @override
  Widget build(BuildContext context) {
    final effectiveTitle =
        titleWidget ??
        (title != null
            ? Semantics(
                header: true,
                child: Text(title!, style: UiTextRole.heading.resolve(context)),
              )
            : null);

    final effectiveDescription =
        descriptionWidget ??
        (description != null
            ? Text(description!, style: UiTextRole.supporting.resolve(context))
            : null);

    final hasHeader =
        effectiveTitle != null ||
        effectiveDescription != null ||
        trailing != null;

    if (!hasHeader) {
      return child;
    }

    final headerItems = <Widget>[
      ?effectiveTitle,
      if (effectiveTitle != null && effectiveDescription != null)
        SizedBox(height: gap / 2),
      ?effectiveDescription,
    ];

    Widget header;
    if (trailing == null) {
      header = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: headerItems,
      );
    } else {
      header = Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: gap,
        runSpacing: gap / 2,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: headerItems,
            ),
          ),
          trailing!,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        header,
        SizedBox(height: gap * 1.5),
        child,
      ],
    );
  }
}
