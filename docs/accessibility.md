# Accessibility

The visible label is required. An optional caller-localized requiredIndicator
appears next to it and is included in the control's accessible name.
Description and active helper/error are included in its semantic hint.
Visible label/description duplicates are excluded from semantics.

Validation text has a live-region node and remains readable without relying only
on color. The control retains native EditableText semantics and keyboard behavior.
FocusNode is forwarded without replacing focus traversal.

Control minimum height is 48 logical pixels; Workbench button controls have a
48-by-48 minimum target. Complete fields grow with content and text scaling.
Geometry uses cross-axis stretch, Wrap and directional alignment. Language is
never used to infer direction: Flutter Directionality is authoritative.

Automated coverage includes accessible names, required text, live regions,
native text-field semantics, Tab traversal, controlled edits, LTR/RTL and
100/150/200% text scale. Device screen-reader behavior is future manual validation;
automated semantics checks do not replace that testing.
