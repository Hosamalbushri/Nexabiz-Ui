# Phase 01 / Step 03 — Select and MultiSelect interaction

## Inspected implementation and upstream contract

Inspected active `packages/nexabiz_ui/lib/src/fields/select_field.dart`, `multi_select_field.dart`, `field_shell.dart`, `test/selection_field_test.dart`, and the Step 02 state-contract tests. Inspected resolved `shadcn_flutter 0.0.53` `lib/src/components/form/select.dart` (`ControlledSelect`, `ControlledMultiSelect`, `Select`, `MultiSelect`, `SelectPopup`, `SelectGroup`, `SelectItemList`, `SelectItemButton`, `SelectData`), `lib/src/components/navigation/subfocus.dart`, and `lib/src/components/overlay/overlay.dart` (`closeOverlay`, `OverlayBarrier`, overlay manager). Compared the upstream select usage example in the shadcn-flutter skill (`components/form/select.md`). No dependency was installed or upgraded.

Upstream `Select` places `SelectData` around popup content (`select.dart:1270–1293`). `SelectItemButton` asks for a `SelectPopupHandle` and calls its `selectItem` (`select.dart:567–626`). Only `SelectPopup` supplies that handle through inherited `Data<SelectPopupHandle>` (`select.dart:1829–1938`); `SelectGroup` only lays out its children (`select.dart:643–667`), and `SelectItemList` is the popup's item delegate (`select.dart:2325–2350`). The upstream example composes `SelectPopup(items: SelectItemList(children: [SelectItemButton(...)]))`. `SelectPopup` also owns its keyboard actions, focus scope, modal surface, and scrollable items. Single-select defaults to auto-close; `ControlledMultiSelect` defaults to retaining the popup after selection.

## Pre-fix reproduction and root cause

Added real-interaction widget tests using `ShadcnApp`, its navigator/overlay, `Directionality`, visible triggers, pointer taps, and keyboard events. No option-selection test calls a component callback directly.

The first pre-fix run reported **8 passed, 6 failed**: both single-select pointer cases opened and displayed options, but tapping Beta emitted no callback; both multi-select cases initially failed to open because the test tapped a chip rather than the trigger (harness error); both keyboard cases could not close/select through the absent popup machinery. After correcting the multi-select trigger to the actual `Select<Iterable<String>>` control, a pre-fix targeted run opened the popup but still emitted no callback on tapping Beta (expected `[['Alpha', 'Beta']]`, actual `[]`). Disabled and read-only no-open cases passed before production changes.

The production defect was missing popup context: the fields supplied a bare `SelectGroup` as `popup` (formerly `select_field.dart:116`, `multi_select_field.dart:131`). Consequently `SelectItemButton` found no `SelectPopupHandle`; a pointer tap reached the button but could not update selection. This was not caused by application localization, the visible trigger, or a gesture interceptor. The corrected test harness distinguishes the chip tap mistake from that production defect.

## Targeted fix and regression coverage

Both fields now wrap their existing `SelectGroup` and item buttons in `SelectPopup<T>(items: SelectItemList(...))`: `select_field.dart:116–131` and `multi_select_field.dart:131–146`. This supplies the required inherited popup handle and upstream modal/keyboard behavior while retaining item rendering, selection state controllers, callback forwarding, current constructors/exports, and the Step 02 parent-value synchronization. No extra controller, dependency, or public API was added; the caller's multi-select list is still copied and unchanged.

`test/select_interaction_test.dart` adds **16** LTR/RTL tests: visible-trigger opening, real pointer selection, one callback, displayed selected value, single-select auto-close, multi-select add/remove and retained popup, initial-list immutability, disabled and read-only no-open behavior, Escape, outside tap, keyboard arrows/Enter, focus return, and parent updates. The keyboard tests request focus on the popup surface after opening; then actual key events traverse and activate items. They do not prove that every platform automatically transfers keyboard focus to the popup.

## Verification results

| Command | Actual result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test` (active package) | First verification found and formatted the new test (exit 1); after formatting, final rerun exit 0, 33 files, 0 changed |
| `flutter analyze --no-pub` (active package) | Exit 0; no issues (3.1 s on final run) |
| `flutter test --no-pub test/select_interaction_test.dart --reporter expanded` | Exit 0; 16 passed |
| `flutter test --no-pub test/field_state_contract_test.dart --reporter expanded` | Exit 0; 12 passed |
| `flutter test --no-pub test/date_range_interaction_test.dart --reporter expanded` | Exit 0; 8 passed |
| `flutter test --no-pub --reporter expanded` (active package) | Exit 0; 122 passed on final run |
| `flutter test --no-pub test/architecture/boundary_test.dart --reporter expanded` (workspace) | Exit 0; 14 passed |
| `flutter test --no-pub test/workbench_test.dart --reporter expanded` (workspace) | Exit 0; 3 passed |
| `git diff --check` | Exit 0; no whitespace errors |

No existing test was changed, weakened, or removed. The shadcn-flutter guidance specifically confirmed that `SelectPopup`/`SelectItemList` are required around item buttons; the fix follows that composition.

## Diff summary and remaining risks

Step 03 changes two production files (`select_field.dart`, `multi_select_field.dart`) and adds one test plus this report. The overall working-tree `git diff --stat` includes earlier uncommitted Step 01/02 edits in those same field files and other active-package files: 5 tracked files, 254 insertions, 96 deletions at final inspection; untracked test and audit files are not counted by that statistic. Earlier date-range, date, number, state-contract, and audit changes and existing archive artifacts were preserved.

Remaining risks: automatic popup focus acquisition was not established by this widget harness; the keyboard tests explicitly focus the popup before arrow/Enter input. Screen-reader announcement quality, hardware keyboard behavior across desktop/web, and large-item virtualization were not measured or manually certified here. The popup now uses the upstream static `SelectItemList` with a single `SelectGroup`; performance at very large option counts remains a separate concern. No Step 04 work was started.
