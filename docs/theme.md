# Theme

ShadcnApp and shadcn ThemeData are the only visual theme authority. The package
does not need a second theme class, Material ThemeData, or global theme notifier.
The Workbench owns light/dark selection using lightSlate/darkSlate.

The Workbench explicitly sets shadcn AdaptiveScaling to 1 so its text-scale
controls isolate Flutter user scaling from shadcn's default platform multiplier.
The inherited TextScaler remains effective at 100%, 150% and 200%.

The pubspec enables the Material icon font assets requested by shadcn and its
transitive dependencies. This bundles font assets only; it creates no Material
theme, imports or visual components in the new code.

Fields resolve foreground/supporting/destructive colors and typography from the
nearest shadcn Theme. Applications may supply their own shadcn color scheme and
typography. No application branding or financial colors are built into the package.

Typography uses shadcn's bundled Geist fonts. Font families required by another
application must be supplied through its shadcn theme and asset setup. No network
font loader or undeclared Cairo dependency exists.
