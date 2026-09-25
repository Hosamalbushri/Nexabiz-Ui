# shadcn boundary

shadcn_flutter 0.0.53 owns visual theme, colors, typography primitives, input
borders, focus visuals, selection/editing behavior and standard buttons.

UiTextField adds one reusable contract: native shadcn input plus UiFieldShell's
accessible name, supporting text, validation presentation and minimum target.
It leaves shadcn decoration and focus treatment intact. It does not replace
the input border, copy input behavior or add Material controls.

UiFieldShell arranges text around a supplied control. UiFormLayout only arranges
fields. Neither paints an alternate input or surface.

The Workbench uses ShadcnApp, Scaffold and OutlineButton directly. There are no
rename wrappers for Card, Switch, Checkbox, Radio, Tooltip, Breadcrumb, Tabs,
Carousel, Divider or Surface. There are zero Material imports in new production
code. Flutter widgets/services provide layout, semantics, focus and controllers.
