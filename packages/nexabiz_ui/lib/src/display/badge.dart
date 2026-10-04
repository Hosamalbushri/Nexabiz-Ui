import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

enum UiBadgeVariant { primary, secondary, outline, destructive }

/// Non-interactive status text styled by the current theme.
class UiBadge extends StatelessWidget {
  const UiBadge({
    super.key,
    required this.label,
    this.variant = UiBadgeVariant.primary,
    this.leadingIcon,
  });

  final String label;
  final UiBadgeVariant variant;
  final Widget? leadingIcon;

  @override
  Widget build(BuildContext context) {
    final content = Text(label);
    final badge = switch (variant) {
      UiBadgeVariant.primary => shadcn.PrimaryBadge(
        leading: leadingIcon,
        child: content,
      ),
      UiBadgeVariant.secondary => shadcn.SecondaryBadge(
        leading: leadingIcon,
        child: content,
      ),
      UiBadgeVariant.outline => shadcn.OutlineBadge(
        leading: leadingIcon,
        child: content,
      ),
      UiBadgeVariant.destructive => shadcn.DestructiveBadge(
        leading: leadingIcon,
        child: content,
      ),
    };
    return Semantics(label: label, excludeSemantics: true, child: badge);
  }
}
