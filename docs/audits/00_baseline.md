# Phase 00 — Actual Baseline

Audit date: 2026-10-04 (Asia/Aden)  
Repository: `Hosamalbushri/Nexabiz-Ui`  
Audited revision: `fec85f2d019b40f98bc868b11bbd9563c1c30e57` (`main`, equal to `origin/main`)

## Scope and repository state

The active reusable package is `packages/nexabiz_ui` (`nexabiz_ui` 0.1.0). The root project is an external development Workbench that consumes it. `packages/nexabiz_ui_legacy` is a separate historical package: root `analysis_options.yaml` excludes it and neither the active package nor Workbench imports it. Legacy files were inventoried but were not treated as current behavior or executed.

Initial working tree:

```text
## main...origin/main
?? nexabiz_ui.tar.xz
```

The untracked archive predates this audit and was not opened or modified. No tracked change existed at audit start.

## Toolchain

| Tool | Actual version |
|---|---|
| Flutter | 3.44.4 stable, framework `ad70ec4617` |
| Dart | 3.12.2 stable, linux_x64 |
| DevTools | 2.57.0 |
| Active package constraint | Dart `^3.12.2`; Flutter `>=3.44.0` |

`flutter` and `dart` were not on `PATH`; commands used `/home/hosam/Downloads/flutter-sdk/flutter/bin`. This is an environment-path issue only, not a repository defect.

## Dependency baseline

Direct production dependencies in `packages/nexabiz_ui/pubspec.yaml` are exactly Flutter SDK and `shadcn_flutter: 0.0.53`. Dev dependencies are Flutter Test SDK and `flutter_lints ^6.0.0`. The root Workbench directly declares Flutter, the path package, and `shadcn_flutter: 0.0.53`.

The active lock resolves: `shadcn_flutter 0.0.53`, `flutter_lints 6.0.0`, `intl 0.20.2`, `skeletonizer 2.1.3`, `country_flags 4.1.2`, `cross_file 0.3.5+5`, `data_widget 0.0.3`, `gap 3.0.1`, `animation_kit 0.0.2`, `http 1.6.0`, and their recorded transitive dependencies. `dart pub deps --style=compact --no-dev` confirmed the package has no additional direct production dependency.

Current upstream is `shadcn_flutter 0.0.55`, but it requires Dart 3.13/Flutter 3.47 and includes breaking dependency/API changes. This was checked from the [official pub.dev versions](https://pub.dev/packages/shadcn_flutter/versions) and [official changelog](https://pub.dev/packages/shadcn_flutter/changelog); no dependency was installed or upgraded.

## Active architecture

```text
Workbench application (lib/main.dart)
  -> nexabiz_ui public barrel
     -> foundation / composition / fields / forms / interaction
        -> shadcn_flutter 0.0.53
           -> Flutter
```

The package owns generic presentation/composition only. The Workbench owns application state, scrolling, locale-like demo toggles, page composition, and root setup. The active package contains 19 exported declarations representing 21 symbols (two exports expose two symbols each), 19 implementation files, and no application-specific domain model.

## Current public symbols

`UiTokens`, `UiTextRole`, `UiLayoutTier`, `UiResponsive`, `UiContent`, `UiSection`, `UiActionGroup`, `UiEmptyState`, `UiErrorState`, `UiFieldShell`, `UiTextField`, `UiNumberField`, `UiSelectField`, `UiMultiSelectField`, `UiAutocompleteField`, `UiDateField`, `UiDateRangeField`, `UiFormLayout`, `UiFormSpan`, `UiFormSpanType`, and `showUiConfirmationDialog`.

One non-exported declaration, empty `class UiButton {}`, exists at `packages/nexabiz_ui/lib/src/foundation/tokens.dart:19`.

## Existing component inventory

| Area | Active components |
|---|---|
| Foundation | Tokens, semantic typography resolver, local-constraint responsive tiers |
| Composition | Content container, section, action group, empty state, error state |
| Fields | Field shell, text, number, select, multi-select, local string autocomplete, date, date range |
| Forms | Responsive form layout and span decorator |
| Interaction | Confirmation-dialog function |
| Workbench-only | Direct shadcn app/scaffold/buttons, checkbox, switch, radio, toast and drawer demonstrations |

## Architecture guards

`test/architecture/boundary_test.dart` contains G1–G14 (14 executed tests): package import boundary, Workbench entrypoint boundary, exact barrel exports, banned state/router dependencies, banned responsive packages, exact direct dependency set/pin, Material/FittedBox/viewport-width ban, limited page-wrapper name ban, intrinsic-layout ban, form-state ban, form-scroll ban, `Expanded` ban, global focus/context singleton ban, and generic page-symbol ban.

Important limits: the guards do **not** prohibit direct `shadcn_flutter` imports in consumer code, inspect public signature types for shadcn leakage, test state synchronization, or enforce behavior/performance/accessibility contracts. See `05_test_coverage.md`.

## Test suites and observed baseline

| Suite | Files | Executions | Result |
|---|---:|---:|---|
| Active package unit/widget | 10 | 86 | PASS |
| Workspace architecture | 1 | 14 | PASS |
| Workbench widget | 1 | 3 | PASS |

The package suite covers composition, fields, layout, overlay/dialog behavior, page-composition recipes, focus traversal, a width/direction/text-scale matrix, and basic semantics. It does not contain an integration/profile benchmark suite.

## Commands executed and exact outcomes

```text
dart format --output=none --set-exit-if-changed lib test packages/nexabiz_ui/lib packages/nexabiz_ui/test
  Formatted 33 files (0 changed); exit 0.

flutter analyze --no-pub                         # workspace root
  No issues found (2.0s); exit 0.

flutter analyze --no-pub                         # packages/nexabiz_ui
  No issues found (1.5s); exit 0.

flutter test --no-pub --reporter expanded        # packages/nexabiz_ui
  86 tests passed; exit 0.

flutter test --no-pub test/architecture --reporter expanded
  14 tests passed; exit 0.

flutter test --no-pub test/workbench_test.dart --reporter expanded
  3 tests passed; exit 0.

dart pub deps --style=compact --no-dev            # root and package
  Dependency graphs printed successfully; exit 0.
```

No environmental test failure occurred. No performance measurement was made; ordinary widget-test success is not performance certification.

