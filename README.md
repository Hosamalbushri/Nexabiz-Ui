# Foundation Workbench — Phase 01

A small external consumer of the clean `packages/nexabiz_ui` package.
Run `flutter pub get` and `flutter run -d chrome` from this directory.

The screen offers light/dark theme, LTR/RTL, normal/long content, text scaling
at 100/150/200%, narrow/wide local hosts, and Validate/Reset actions.

See [architecture](docs/architecture.md), [form contracts](docs/forms.md) and
[canonical test commands](docs/testing.md).

The original package is preserved intact at `packages/nexabiz_ui_legacy`.
It is read-only reference material and is excluded from the active analysis.
The Workbench and new package never import it.

Phase 02 has not started.
