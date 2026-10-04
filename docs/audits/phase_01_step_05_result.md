# Phase 01 / Step 05 — Public date-range API migration

Status: **implemented after explicit approval**. The pre-migration inventory and compatibility decision are in [the API audit](phase_01_step_05_api_audit.md).

## API and migration

`UiDateRangeField.value` is now Flutter `DateTimeRange?`, and `onChanged` is `ValueChanged<DateTimeRange?>?` (`packages/nexabiz_ui/lib/src/fields/date_range_field.dart:27–29`). Existing consumers must import `package:flutter/material.dart` (a `show DateTimeRange` import suffices), replace `shadcn.DateTimeRange(start, end)` with `DateTimeRange(start: start, end: end)`, and update explicit callback annotations. This is source-breaking for upstream-typed consumers; no deprecated bridge was added. The Workbench and three affected package tests were migrated. No other public constructor/export was changed.

Flutter's constructor asserts ordered endpoints in debug mode; the adapter does not reorder, normalize, or truncate them. The component remains caller-controlled: rebuilding with a new or null value updates the picker without invoking `onChanged`. Upstream picker/calendar display remains date-oriented, although both adapter directions pass the exact `DateTime` endpoints, including time and UTC/local characteristics. Upstream `shadcn_flutter: 0.0.53` remains the internal control dependency.

## Implementation and evidence

- `date_range_field.dart:1,48–57`: show-only Flutter type import; nullable conversion into `shadcn.DateTimeRange` for the picker and back into Flutter `DateTimeRange` for callbacks. The existing `enabled && !readOnly` callback gate and Step 01 interaction boundary remain intact.
- `packages/nexabiz_ui/test/date_range_interaction_test.dart`: RTL/LTR tests cover initial UTC timestamps, equal endpoints, parent updates, null reset, calendar-cell pointer selection, picker selection and clearing, callback count, and four enabled/read-only combinations. The dialog's actual trigger and Save path are exercised. `date_range_public_api_test.dart` compiles using only Flutter and the package barrel, with no shadcn import.
- `test/architecture/boundary_test.dart:170–240`: G7 permits only the exact show-only `DateTimeRange` Material import in this field. New G15 scans barrel-exported declarations for shadcn-qualified types while permitting internal control composition. This is a source-level guard, not a full Dart semantic API analyzer.
- `docs/fields.md`, `docs/phase_05_evidence.md`, and `docs/phase_05_certification.md` now identify Flutter as the range type; `lib/main.dart` uses the migrated type.

## Verification (actual commands)

| Command | Result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test packages/nexabiz_ui/lib packages/nexabiz_ui/test` | Exit 0 after formatting the newly added test; 38 files checked, 0 changed. Initial check exited 1 for that test and was corrected by formatting only. |
| `flutter analyze --no-pub` in active package | Exit 0; no issues. |
| `flutter analyze --no-pub` in workspace | Exit 0; no issues. |
| `flutter test --no-pub test/date_range_interaction_test.dart --reporter expanded` in package | Exit 0; final run 16 tests passed. An initial calendar-pointer test expected replacement rather than upstream's range extension and failed in RTL/LTR; its expectation was corrected to the observed upstream behavior without a production change. |
| `flutter test --no-pub test/date_range_interaction_test.dart test/date_range_public_api_test.dart --reporter expanded` in package | Exit 0; 13 tests passed before the two clearing tests were added. |
| `flutter test --no-pub --reporter compact` in package | Exit 0; final run 133 tests passed, including pointer interaction, API isolation, and clearing. An earlier expanded run before the two pointer tests passed 131 tests. |
| `flutter test --no-pub test/architecture --reporter expanded` in workspace | Exit 0; 15 tests passed. Initial G15 attempt failed on a legitimate internal `shadcn.TextField` expression; the guard was narrowed, then rerun successfully. |
| `flutter test --no-pub test/workbench_test.dart --reporter expanded` in workspace | Exit 0; 3 tests passed. |

## Diff and remaining risks

Step 05 changed the date-range field, Workbench range value, three affected package test files, public API test, architecture guard, and three documentation files; this report replaces the approval-gated draft. No dependency or unrelated production component was changed in Step 05. The working tree already contained uncommitted Steps 01–04 changes and untracked artifacts before approval, so repository `git diff --stat` is cumulative: 11 tracked files, 331 insertions and 114 deletions at final inspection, plus untracked files. It must not be attributed solely to Step 05.

Remaining risks: existing external users must migrate their source; date-only picker UI cannot edit time components through its calendar even though conversion preserves supplied timestamps; Flutter rejects reversed ranges in debug mode; and G15's lexical scan may miss exotic public syntax, so the compile-level consumer test is retained. No Step 06 work was started.
