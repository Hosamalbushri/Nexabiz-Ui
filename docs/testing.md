# Testing

Two canonical working directories are intentional. Architecture/Workbench tests
run from the workspace root; package behavior tests run from packages/nexabiz_ui.
Never run legacy tests as part of this phase.

## New package (working directory: packages/nexabiz_ui)

```sh
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
```

## Workbench (working directory: workspace root)

```sh
dart format --output=none --set-exit-if-changed lib test packages/nexabiz_ui/lib packages/nexabiz_ui/test
flutter analyze
flutter test
flutter test test/architecture/boundary_test.dart
```

Formatting the entire workspace recursively would include the immutable legacy
reference. The exact dot-format or scoped paths are used above.
Root analysis explicitly excludes `packages/nexabiz_ui_legacy`.

If Flutter/Dart are absent from PATH in this environment, use the binaries under
`/home/hosam/Downloads/flutter-sdk/flutter/bin`. Flutter 3.29.1 / Dart 3.7.0 were used.

## Test Suites (49 total passing tests)
- **Package Tests (`packages/nexabiz_ui/test/`)**:
  - `composition_test.dart`: 16 tests covering layout invariants, responsive constraints, typography, LTR/RTL directionality, text scaling (1.0–2.0), long content, and accessibility semantics for `UiContent`, `UiSection`, `UiActionGroup`, `UiEmptyState`, and `UiErrorState`.
  - `vertical_slice_test.dart`: 24 tests covering fields and form layout.
- **Workspace Tests (`test/`)**:
  - `architecture/boundary_test.dart`: 7 tests covering G1–G7 architecture boundary guards (updated G3 guard enforces 12 exact public exports).
  - `workbench_test.dart`: 2 tests exercising external Foundation Workbench behavior across themes, directions, scales, and local hosts.

## Boundary guards
- **G1**: package imports cannot introduce domain/application packages or escape package lib.
- **G2**: Workbench cannot import package internals/legacy.
- **G3**: exact show-exports protect the public contract (12 reviewed exports).
- **G4**: rejects state/router dependencies.
- **G5**: rejects responsive scaling dependencies.
- **G6**: enforces the minimal direct graph and approved shadcn pin.
- **G7**: rejects Material visual imports, FittedBox and global viewport queries.

Mutation proof and final validation results are recorded in `docs/phase_04_evidence.md`.
