import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Semantic roles resolved from the active shadcn theme without scaling overrides.
enum UiTextRole {
  heading,
  body,
  label,
  supporting;

  TextStyle resolve(BuildContext context) {
    final type = shadcn.Theme.of(context).typography;
    return type.sans.merge(switch (this) {
      heading => type.h3,
      body => type.p,
      label => type.small.merge(type.semiBold),
      supporting => type.small,
    });
  }
}
