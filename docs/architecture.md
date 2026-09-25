# Phase 01 architecture

The root application is the Foundation Workbench. It consumes the new package
through its public entrypoint and uses shadcn directly for application setup and
standard controls.

```text
lib/main.dart                       external Workbench consumer
packages/nexabiz_ui/lib/
  nexabiz_ui.dart                   reviewed public contracts
  src/foundation/                   tokens, typography, local responsiveness
  src/fields/                       field shell and one text input
  src/forms/                        content-driven column composition
packages/nexabiz_ui_legacy/         immutable reference, excluded from analysis
test/architecture/                 workspace boundary guards
packages/nexabiz_ui/test/           package behavior tests
```

Dependencies flow from forms/fields to foundation and from these layers to Flutter
and shadcn_flutter 0.0.53. No new code imports legacy code. There is no theme
controller, root-app wrapper, application state provider, router or domain model.

The original package had no root application consumers, pubspec path dependency
or IDE/Workbench references before relocation. It was renamed as one directory
on the same filesystem. All 529 files, including generated files, were preserved.
The aggregate SHA-256 of sorted relative paths and file contents before and after:
`be3854dd20eb588ed8da04fdde11bb640e51e74183483fc5e39d76f9f6c5174e`.
Its internal package name remains unchanged. Its old generated package mappings
and path-sensitive tests are reference artifacts, not active workspace tooling.
Do not run dependency resolution, formatters or tests inside the legacy directory.

Future work: additional field families, selection, pages, navigation, overlays,
tables and trees require separate phase approval.
