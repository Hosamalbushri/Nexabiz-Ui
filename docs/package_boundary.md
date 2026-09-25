# Package boundary

Production imports are restricted to Flutter, Dart SDK libraries, shadcn_flutter
and relative paths inside the new package library. The Workbench imports only
`package:nexabiz_ui/nexabiz_ui.dart` from this package.

The production pubspec has exactly two direct dependencies: Flutter SDK and
shadcn_flutter pinned to 0.0.53. Dev dependencies are flutter_test and flutter_lints.
The Workbench separately declares shadcn_flutter because it directly uses its
application root, themes and buttons.

The seven public contracts are UiTokens, UiTextRole, UiLayoutTier, UiResponsive,
UiFieldShell, UiTextField and UiFormLayout. Six explicit `show` exports prevent
accidental export of declarations later added to implementation files.

No domain types, application imports, legacy imports, persistence, networking,
router or application state dependencies are permitted. Shadcn's existing
transitive dependencies (including http, intl and skeletonizer) remain in the
resolved graph; the new package does not directly depend on or use them.

Caller-owned strings include labels, required indicators, descriptions, helper
text, errors and placeholders. No package localization delegate or package-owned
user-facing message exists. Diagnostic FlutterError messages are for developers.
