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
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter test test/architecture/boundary_test.dart
```

Formatting the entire workspace recursively would include the immutable legacy
reference. The exact dot-format command is scoped to the new package above.
Root analysis explicitly excludes packages/nexabiz_ui_legacy.

If Flutter/Dart are absent from PATH in this environment, use the binaries under
/home/hosam/Downloads/flutter-sdk/flutter/bin. Flutter 3.44.4 / Dart 3.12.2 were used.

Git diff checks are conditional on an existing repository. Do not initialize Git
for validation. Current status: NOT AVAILABLE — repository is not initialized with Git.

The field matrix checks 280/420/960 local widths, 100/150/200% text, LTR/RTL, column
positions, paragraph metrics, full validation height and minimum control targets.
Separate tests exercise the 1920 → 420 invariant, semantics, keyboard traversal,
caller-controlled state and custom shadcn typography.

## Boundary guards

G1 imports cannot introduce domain/application packages or escape package lib.
G2 Workbench cannot import package internals/legacy.
G3 exact show-exports protect the small public contract.
G4 rejects state/router dependencies.
G5 rejects responsive scaling dependencies.
G6 enforces the minimal direct graph and approved shadcn pin.
G7 rejects Material visual imports, FittedBox and global viewport queries.

These source guards cover representative architectural failures, not every Dart
syntax or every business concept. They supplement implementation review.
Mutation proof and final validation results are recorded in phase_01_evidence.md.
