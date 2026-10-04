# Phase 01 / Step 01 — Disabled Date Range Interaction

## Root cause

`UiDateRangeField` forwarded `enabled` only to `UiFieldShell` (`packages/nexabiz_ui/lib/src/fields/date_range_field.dart:39-46`). The shell uses it for semantics (`field_shell.dart:66-76`) but does not block interaction. The field forwarded `onChanged` whenever `readOnly` was false, even when `enabled` was false (original `date_range_field.dart:49`).

In the pinned `shadcn_flutter 0.0.53`, `DateRangePicker` has no `enabled` parameter and passes its `onChanged` to `ObjectFormField` (`lib/src/components/form/date_picker.dart:442-503, 505-516` in the resolved package). `ObjectFormFieldState.enabled` defaults to whether `onChanged` is non-null, and its `OutlineButton` uses that value plus `onPressed: enabled && onChanged != null ? prompt : null` (`lib/src/components/form/form_field.dart:199-202, 308-324`). The underlying button's `Clickable` gives its `FocusableActionDetector` the same enabled value (`lib/src/components/control/clickable.dart:782-852`). Consequently, the disabled/editable field remained pressable and focusable and could open the dialog.

## Regression tests and pre-fix result

Added `packages/nexabiz_ui/test/date_range_interaction_test.dart`. It covers all four `enabled`/`readOnly` combinations in both LTR and RTL (eight executions). Each case checks the displayed value, trigger and focus-target enabled state, and tap behavior. Editable cases open the dialog, simulate a calendar range change through the actual dialog callback, save, and assert exactly one value callback. Non-editable cases assert that a tap opens no dialog, leaves the value intact, and invokes no callback.

Command before the production change:

```text
flutter test --no-pub test/date_range_interaction_test.dart --reporter expanded
```

Actual result: **6 passed, 2 failed**. The two failures were `enabled=false, readOnly=false` in RTL and LTR. Both failed at the trigger assertion (`date_range_interaction_test.dart:58` at that pre-format revision): expected `OutlineButton.enabled == false`, actual `true`. The other six state/direction cases passed. Assertions were retained unchanged for the implementation run.

## Implementation

Changed one production line at `packages/nexabiz_ui/lib/src/fields/date_range_field.dart:49`:

```dart
onChanged: enabled && !readOnly ? onChanged : null,
```

The pinned picker uses a null callback to disable its own trigger, gestures and focus target. This closes the dialog entry point and prevents user value changes/callbacks. The existing display, styling, field semantics, range type and public constructor remain unchanged. No dependency or global state was added.

## Verification commands and actual results

The Flutter/Dart binaries were invoked from `/home/hosam/Downloads/flutter-sdk/flutter/bin`; `--no-pub` avoided dependency resolution.

| Command | Working directory | Result |
|---|---|---|
| `dart format --output=none --set-exit-if-changed lib test` | active package, first run | Reported 31 files, 1 needing format (new test); nonzero exit |
| `dart format test/date_range_interaction_test.dart` | active package | Formatted the new test file |
| `dart format --output=none --set-exit-if-changed lib test` | active package, final | 31 files, 0 changed; exit 0 |
| `flutter analyze --no-pub` | active package | No issues found; exit 0 |
| `flutter test --no-pub test/date_range_interaction_test.dart --reporter expanded` | active package | 8 passed; exit 0 |
| `flutter test --no-pub --reporter compact` | active package | 94 passed; exit 0 |
| `flutter analyze --no-pub` | workspace root | No issues found; exit 0 |
| `flutter test --no-pub test/architecture --reporter expanded` | workspace root | 14 passed; exit 0 |
| `flutter test --no-pub test/workbench_test.dart --reporter expanded` | workspace root | 3 passed; exit 0 |

The matrix confirms the disabled and read-only trigger/focus target is disabled in both directions; tapping opens no picker. The enabled/editable path opens normally and invokes its callback once after Save. Existing package and Workbench tests passed.

## Git diff summary

- Modified: `packages/nexabiz_ui/lib/src/fields/date_range_field.dart` (one-line conditional change).
- Added: `packages/nexabiz_ui/test/date_range_interaction_test.dart` (eight regression cases).
- Added: `docs/audits/phase_01_step_01_result.md` (this report).
- No existing tests, manifests, public exports, or unrelated production files changed.
- Pre-existing untracked `docs/audits/`, `docs/audits.tar.xz`, and `nexabiz_ui.tar.xz` were left untouched except for adding this report inside `docs/audits/`.

## Remaining risks

- The test simulates calendar selection by invoking `DatePickerDialog.onChanged` before tapping Save; it does not exercise individual calendar-day hit targets. The guard being fixed is the trigger boundary, which the test taps directly.
- The pinned upstream picker can still be prompted imperatively through internal `ObjectFormFieldState.prompt`; this change prevents normal user gesture/keyboard entry. No public programmatic prompt API is exposed by `UiDateRangeField`.
- The public `shadcn.DateTimeRange` type leak and other Phase 00 findings remain separate work.

Step 02 was not started.
