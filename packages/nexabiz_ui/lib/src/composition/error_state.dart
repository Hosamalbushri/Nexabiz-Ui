import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/tokens.dart';
import '../foundation/typography.dart';

/// Composition primitive for accessible error presentation states.
///
/// Standardizes error presentation with accessibility live-region semantics
/// and action slot without owning exception mapping or network logic.
class UiErrorState extends StatelessWidget {
  const UiErrorState({
    super.key,
    this.title,
    this.titleWidget,
    this.description,
    this.descriptionWidget,
    this.visual,
    this.action,
    this.padding = const EdgeInsetsDirectional.all(UiTokens.contentGap),
    this.maxContentWidth = 400,
  }) : assert(
         title == null || titleWidget == null,
         'Cannot specify both title and titleWidget',
       ),
       assert(
         description == null || descriptionWidget == null,
         'Cannot specify both description and descriptionWidget',
       );

  final String? title;
  final Widget? titleWidget;
  final String? description;
  final Widget? descriptionWidget;
  final Widget? visual;
  final Widget? action;
  final EdgeInsetsGeometry? padding;
  final double maxContentWidth;

  @override
  Widget build(BuildContext context) {
    final theme = shadcn.Theme.of(context);
    final destructiveColor = theme.colorScheme.destructive;

    final effectiveTitle =
        titleWidget ??
        (title != null
            ? Text(
                title!,
                textAlign: TextAlign.center,
                style: UiTextRole.heading
                    .resolve(context)
                    .copyWith(color: destructiveColor),
              )
            : null);

    final effectiveDescription =
        descriptionWidget ??
        (description != null
            ? Text(
                description!,
                textAlign: TextAlign.center,
                style: UiTextRole.supporting.resolve(context),
              )
            : null);

    Widget content = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (visual case final v?) ...[
          v,
          const SizedBox(height: UiTokens.contentGap / 1.5),
        ],
        ?effectiveTitle,
        if (effectiveTitle != null && effectiveDescription != null)
          const SizedBox(height: UiTokens.fieldGap),
        ?effectiveDescription,
        if (action case final a?) ...[
          const SizedBox(height: UiTokens.contentGap),
          a,
        ],
      ],
    );

    if (maxContentWidth > 0) {
      content = ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxContentWidth),
        child: content,
      );
    }

    if (padding != null) {
      content = Padding(padding: padding!, child: content);
    }

    return Semantics(
      container: true,
      liveRegion: true,
      child: Center(child: content),
    );
  }
}
