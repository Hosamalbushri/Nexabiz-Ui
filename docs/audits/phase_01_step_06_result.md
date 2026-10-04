# Phase 01 / Step 06 — Controller lifecycle and field stability

Status: **targeted fix complete**. Scope is the active `packages/nexabiz_ui` package; no public constructor, export, dependency, or date-range value contract changed.

## Ownership contract

| Field | Controller owner and replacement | Listener/disposal behavior | Focus and parent updates |
| --- | --- | --- | --- |
| `UiTextField` | Caller must supply and dispose `TextEditingController`; replacement is supported. Package now owns a private proxy per field. | Bridge detaches from the old caller controller on replacement and from the current one on dispose; caller controllers are never disposed. Proxy is disposed by the package. | Optional `FocusNode` remains caller-owned and may be replaced; upstream detaches its old focus listener. New controller text/selection is copied to the proxy without a replacement callback. |
| `UiNumberField` | Caller may supply a text controller, or the field creates an internal one. External→external, external→internal and internal→external transitions are supported. | External controllers use the same private bridge. Internal controller and proxy are package-owned and disposed; caller controllers are untouched. | Optional focus node is caller-owned. When internal, `value` changes synchronize text without callbacks; when external, controller text owns display over `value`. |
| `UiAutocompleteField` | Caller supplies/disposes text controller; replacement is supported. Package owns a private proxy. | Package detaches its filtering listener and bridge listener from old/current caller controllers; proxy is disposed. Upstream autocomplete post-frame suggestion work checks `mounted`. | Optional focus node remains caller-owned. Controller text drives filtering; replacement does not notify `onChanged`. |
| `UiSelectField<T>` | No public controller. Package creates/disposes shadcn `SelectController<T>`. | Controller is retained across rebuilds and disposed with the field. | Optional focus node is caller-owned; parent `value` updates synchronize via `didUpdateWidget` without callback. |
| `UiMultiSelectField<T>` | No public controller. Package creates/disposes shadcn `MultiSelectController<T>` from a copy. | Caller lists are not mutated; package controller is disposed. | Optional focus node is caller-owned; changed parent lists synchronize via `didUpdateWidget` without callback. |
| `UiDateField` | No public controller. Package creates/disposes shadcn `DatePickerController`. | Controller is retained across rebuilds and disposed. | No public focus-node parameter; parent date updates synchronize without callback. |
| `UiDateRangeField` | No public controller; Flutter `DateTimeRange?` is caller-owned and adapted to the upstream picker each build. | Upstream `ObjectFormField` owns its transient picker state; no package controller/listener to detach. | No public focus-node parameter; parent value or null reset flows through the picker without callback. |

Changing a `FocusNode` while a field is focused does not promise automatic focus transfer; the caller may request focus on the new node. The test verifies the new node can receive focus and the old node no longer holds it. Text and autocomplete do not support an internal-controller mode; their controllers are required. There is no asynchronous package search operation or timer to cancel.

## Confirmed defects and pre-fix reproduction

Pinned upstream `shadcn_flutter 0.0.53` TextField subscribes to an external controller in `lib/src/components/form/text_field.dart:2146–2161`. Its `didUpdateWidget` forces `_handleControllerChanged` when a controller is replaced (`:2183–2200`), which invokes `onChanged` with the incoming controller's existing text. Its `dispose` (`:2286–2293`) does not remove the listener from `widget.controller`. The upstream autocomplete separately guards its post-frame suggestion update with `mounted` (`lib/src/components/form/autocomplete.dart:322–333,438–452`). Select and date use `ValueNotifier`-based controllers.

Before production edits, `flutter test --no-pub test/field_lifecycle_test.dart --reporter expanded` exited **1**: 4 failures (text and autocomplete controller replacement in RTL and LTR), each receiving `['next']` or `['Ba']` instead of no callback; 4 other tests passed. Expanded teardown checks then showed callbacks from a caller controller after unmount in both fields. A first callback-only fix prevented replacement notifications but exposed duplicate user-edit callbacks (`['edited','edited']` / `['Ban','Ban']`). An added number external→external transition exposed one parent-driven `['42']` callback in a full-suite run; ordering was corrected before final verification. These were production lifecycle issues, not harness/theme failures. Number internal/external transitions, select/multi-select/date reuse, and active-overlay teardown did not reproduce further defects.

## Implementation

- `lib/src/fields/text_controller_bridge.dart`: private-to-the-package bridge mirrors the full `TextEditingValue` (text, selection and composing region) between caller controller and a package-owned proxy. It detaches listeners on replacement/disposal and disposes only the proxy. This isolation is required because upstream does not detach its external-controller listener.
- `text_field.dart`: became stateful without changing its public constructor. It owns/disposes the bridge, synchronizes controller replacement, and de-duplicates same-text `onChanged` notifications.
- `autocomplete_field.dart`: retains its existing filtering listener lifecycle, adds the bridge, and de-duplicates upstream text notifications. No timer or new async work was added.
- `number_field.dart`: uses the bridge only when an external controller is supplied; internal controller behavior is retained. Incoming parent text is marked before bridge synchronization to prevent an unintended callback.
- `test/field_lifecycle_test.dart`: 10 RTL/LTR widget tests cover external controller replacement, internal/external switches, obsolete and disposed listener absence, callback counts, focus replacement, record reuse, parent updates, and teardown during open autocomplete/select interactions. Existing assertions were not weakened.

The shadcn-flutter skill directed inspection of the pinned input, autocomplete, select and date-picker contracts; its examples confirmed that caller controllers and focus nodes are valid inputs, while the resolved package source and regression tests established the actual defect.

## Final verification

| Command | Actual result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test packages/nexabiz_ui/lib packages/nexabiz_ui/test` from workspace | Exit 0; 40 files checked, 0 changed. |
| `flutter analyze --no-pub` from package | Exit 0; no issues. An earlier run caught 8 protected-member warnings in new tests; the test controller subclass resolved them. |
| `flutter analyze --no-pub` from workspace | Exit 0; no issues. |
| `flutter test --no-pub test/field_lifecycle_test.dart --reporter expanded` from package | Exit 0; 10/10 passed. |
| `flutter test --no-pub --reporter expanded` from package | Exit 0; 143/143 passed. An earlier full run found the number external→external callback and exited 1; final rerun passed. |
| `flutter test --no-pub test/architecture --reporter expanded` from workspace | Exit 0; 15/15 passed. |
| `flutter test --no-pub test/workbench_test.dart --reporter expanded` from workspace | Exit 0; 3/3 passed. |

## Compatibility, diff and remaining risks

No public API change or new dependency. The underlying shadcn TextField now sees a package-owned proxy, so code outside the supported public API that introspects its exact controller identity would observe a difference. The caller's controller remains the authoritative editable value, including selection/composing state, and is never disposed by the package.

Step 06's files are `text_field.dart`, `number_field.dart`, `autocomplete_field.dart`, new `text_controller_bridge.dart`, new `field_lifecycle_test.dart`, and this report. The final `git diff --stat` is cumulative with pre-existing Steps 01–05 work: 13 tracked files, 423 insertions and 137 deletions, plus untracked reports/tests/artifacts; it is not solely a Step 06 diff. No unrelated production component or existing test was modified in this step.

Remaining risks: widget tests verify listener detachment and callbacks, not heap retention under a profiler. The upstream TextField still retains its listener on the *disposed proxy* until garbage collection; there is no remaining listener on a caller-owned controller. Overlay/focus behavior beyond tested teardown and replacement paths, and rapid repeated controller swaps during IME composition, were not separately stress-measured. No next-phase work was started.
