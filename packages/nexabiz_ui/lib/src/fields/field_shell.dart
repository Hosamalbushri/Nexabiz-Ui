import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/tokens.dart';
import '../foundation/typography.dart';

/// Content-driven label, control and validation presentation.
///
/// [requiredIndicator] is caller-localized text (for example, "Required").
/// This shell does not paint control borders or manage input state.
class UiFieldShell extends StatelessWidget {
  const UiFieldShell({
    super.key,
    required this.label,
    required this.control,
    this.requiredIndicator,
    this.description,
    this.helper,
    this.error,
    this.enabled = true,
    this.readOnly = false,
  }) : assert(label != ''),
       assert(requiredIndicator == null || requiredIndicator != '');

  final String label;
  final Widget control;
  final String? requiredIndicator;
  final String? description;
  final String? helper;
  final String? error;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) {
    final scheme = shadcn.Theme.of(context).colorScheme;
    final hasError = error != null && error!.isNotEmpty;
    final accessibleLabel = [label, ?requiredIndicator].join(', ');
    final hint = [
      if (description?.isNotEmpty ?? false) description!,
      if (hasError) error! else if (helper?.isNotEmpty ?? false) helper!,
    ].join('\n');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ExcludeSemantics(
          child: Text(
            [label, ?requiredIndicator].join(' · '),
            style: UiTextRole.label.resolve(context),
          ),
        ),
        if (description?.isNotEmpty ?? false) ...[
          const SizedBox(height: UiTokens.fieldGap),
          ExcludeSemantics(
            child: Text(
              description!,
              style: UiTextRole.supporting
                  .resolve(context)
                  .copyWith(color: scheme.mutedForeground),
            ),
          ),
        ],
        const SizedBox(height: UiTokens.fieldGap),
        Semantics(
          label: accessibleLabel,
          hint: hint,
          enabled: enabled,
          readOnly: readOnly,
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              minHeight: UiTokens.controlMinHeight,
            ),
            child: control,
          ),
        ),
        if (hasError || (helper?.isNotEmpty ?? false)) ...[
          const SizedBox(height: UiTokens.fieldGap),
          Semantics(
            liveRegion: hasError,
            child: Text(
              hasError ? error! : helper!,
              style: UiTextRole.supporting
                  .resolve(context)
                  .copyWith(
                    color: hasError
                        ? scheme.destructive
                        : scheme.mutedForeground,
                  ),
            ),
          ),
        ],
      ],
    );
  }
}
