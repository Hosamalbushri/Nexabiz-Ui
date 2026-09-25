# Phase 01 evidence

Phase 01 is complete. Phase 02 has not started.

## Inspection and preservation

Before implementation, the root was the independent stock Flutter counter app.
Inspected imports, manifests, tooling and IDE paths did not reference the legacy
package. The existing packages/nexabiz_ui directory was moved intact to
packages/nexabiz_ui_legacy before creating the clean package at its canonical path.
No legacy implementation, tests, manifests or generated caches were edited.
Its internal package name remains unchanged; it is reference material, not a
dependency or a member of the active test harness.

The legacy tree contained 529 files. A sorted recursive SHA-256 digest covering
relative entry paths, file bytes and link targets was identical before the move,
after the move and after implementation:

```text
be3854dd20eb588ed8da04fdde11bb640e51e74183483fc5e39d76f9f6c5174e
```

## Before and after

Before, the clean package did not exist; these are new-scope counts, not a claim
that fewer declarations than legacy implies better design.

| Measure | Before | After |
| --- | ---: | ---: |
| New package production Dart files | 0 | 7 |
| New package test Dart files | 0 | 1 |
| New package direct public exports | 0 | 6 |
| New package exported symbols | 0 | 7 |
| New package production direct dependencies | 0 | 2 |
| New package Material visual imports | 0 | 0 |
| New package shadcn imports | 0 | 3 |
| Architecture guard tests | 0 | 7 |
| New package behavior tests | 0 | 24 |
| Workbench behavior tests | 0 | 2 |
| New package domain dependencies | 0 | 0 |
| New package application dependencies | 0 | 0 |
| Workbench direct src consumer imports | 0 | 0 |

The original counter smoke test was replaced. There are 33 current tests across
the two canonical execution locations (24 package + 7 guards + 2 Workbench).
The Workbench has one production Dart file, one public foundation import and one
shadcn import. Dependencies are Flutter and shadcn_flutter pinned to 0.0.53.
Upstream transitive dependencies are not claimed to be absent. The manifest's
uses-material-design flag supplies icon font assets, not a Material visual theme.

## Mutation proof

Each mutation was introduced into actual source or manifest files, tested with
the relevant targeted test, then restored. Each violating run exited 1 for the
intended assertion; each restored run exited 0. Dependency mutations used
--no-pub so invalid dependency changes did not alter the resolved graph.

| Guard | Representative temporary violation | Violating run | Restored run |
| --- | --- | --- | --- |
| G1 | Import package:inventory/domain.dart | FAIL as expected | PASS |
| G1 | Import the root application main.dart | FAIL as expected | PASS |
| G2 | Workbench imports package:nexabiz_ui/src/... | FAIL as expected | PASS |
| G3 | Add an internal probe export to the barrel | FAIL as expected | PASS |
| G4 | Add flutter_riverpod production dependency | FAIL as expected | PASS |
| G5 | Add flutter_screenutil production dependency | FAIL as expected | PASS |
| G6 | Add http production dependency | FAIL as expected | PASS |
| G7 | Add flutter/material.dart production import | FAIL as expected | PASS |
| Local width invariant | Replace local width with MediaQuery window width | FAIL: expected 420, actual 1920 | PASS |

No mutation files or manifest/source mutations remain.

## Final validation

Flutter 3.44.4 and Dart 3.12.2 were used from
/home/hosam/Downloads/flutter-sdk/flutter/bin because they were not on PATH.

| Working directory | Command | Result |
| --- | --- | --- |
| packages/nexabiz_ui | dart format --output=none --set-exit-if-changed . | PASS, 8 files, 0 changed |
| packages/nexabiz_ui | flutter analyze | PASS, no issues |
| packages/nexabiz_ui | flutter test | PASS, 24 tests |
| workspace root | dart format --output=none --set-exit-if-changed lib test | PASS, 3 files, 0 changed |
| workspace root | flutter analyze | PASS, no issues |
| workspace root | flutter test | PASS, 9 tests |
| workspace root | flutter test test/architecture/boundary_test.dart | PASS, 7 tests |

The root formatting scope deliberately excludes immutable legacy sources.
Root analysis also excludes legacy. Legacy tests were not repaired or rerun.

Git diff check: NOT AVAILABLE — repository is not initialized with Git.
Git was not initialized.

## Evidence scope and limitations

Behavioral tests cover local widths 280/420/960, both directions, scales
1.0/1.5/2.0, natural paragraph/field growth, minimum input height, theme-derived
typography, focus traversal, editing/submission callbacks and error semantics.
Workbench tests additionally cover a 320-pixel viewport at 200% text and the
interactive theme/direction/content/width/scale/validation controls.

Source-based architecture guards are representative checks, not a complete Dart
parser or proof against every future architectural violation. Manual device,
screen-reader, browser and visual-golden verification were not performed.
Responsive composition requires bounded local horizontal constraints; it fails
explicitly on unbounded hosts. Caller-controlled validation is the sole strategy;
the package does not validate, own controllers, scrolling or action state.

Future work includes additional input kinds, richer form policy and any expanded
component catalog. None is implemented or authorized by this phase.
