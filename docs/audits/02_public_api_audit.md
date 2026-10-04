# Public API Audit

## Result

The barrel at `packages/nexabiz_ui/lib/nexabiz_ui.dart:4-22` deliberately exports 21 symbols through explicit `show` clauses. Export control is good, but the API is not upstream-neutral: `UiDateRangeField.value` and `onChanged` expose `shadcn.DateTimeRange` at `src/fields/date_range_field.dart:27-28`.

## Exported contracts

| Symbol | Public contract summary | Ownership assessment |
|---|---|---|
| `UiTokens` | Five static layout/size constants | Foundation-owned, stable |
| `UiTextRole` | Four roles; `resolve(BuildContext) -> TextStyle` | Public method exposes Flutter only; internal shadcn theme resolution is legitimate adapter logic |
| `UiLayoutTier` | `compact`, `medium`, `expanded`, `wide`; `forWidth` | Foundation-owned |
| `UiResponsive` | local `LayoutBuilder` callback with width/tier | Foundation-owned |
| `UiContent` | child, max width, directional padding/alignment | Foundation-owned composition |
| `UiSection` | title/description string-or-widget, trailing, gap, child | Foundation-owned composition |
| `UiActionGroup` | children and Flutter wrap alignment/spacing | Foundation-owned composition |
| `UiEmptyState` | caller strings/widgets, action, padding, max width | Foundation-owned composition |
| `UiErrorState` | same, with live-region/destructive presentation | Legitimate adapter |
| `UiFieldShell` | field chrome/semantics around arbitrary Flutter `Widget` | Legitimate reusable policy |
| `UiTextField` | required caller controller; Flutter input/focus types | Legitimate adapter; predictable controller ownership |
| `UiNumberField` | optional controller or `value`, raw/numeric callbacks and flags | Ambiguous controller/value ownership; locale-limited |
| `UiSelectField<T>` | items, `value`, callback, builders, state flags | Looks controlled but passes `value` as upstream `initialValue` |
| `UiMultiSelectField<T>` | item/value lists, callback/builders, state flags | Looks controlled but passes `value` as upstream `initialValue` |
| `UiAutocompleteField` | required controller and local `List<String>` suggestions | Controller ownership clear; filtering policy too narrow for large data |
| `UiDateField` | `DateTime? value` and callback | Looks controlled but passes `value` as upstream `initialValue` |
| `UiDateRangeField` | range value and callback | **Leaks upstream `shadcn.DateTimeRange`** |
| `UiFormLayout` | children and maximum columns | Foundation-owned composition |
| `UiFormSpan` | decorator child/span | Foundation-owned composition |
| `UiFormSpanType` | normal/wide/full | Foundation-owned |
| `showUiConfirmationDialog` | Flutter context and localized strings; returns `Future<bool?>` | Cohesive interaction contract; internal shadcn use is legitimate |

## Leakage reproduction

Consumer code cannot declare a range for `UiDateRangeField` using only the NexaBiz barrel and standard Flutter widget imports. It must import `package:shadcn_flutter/shadcn_flutter.dart` to construct the required value:

```dart
shadcn.DateTimeRange? range;
UiDateRangeField(value: range, onChanged: (next) => range = next);
```

This is a CONFIRMED high-priority architecture violation. Remediate with a package-owned immutable range value or a standard Flutter range type and map to/from shadcn internally. Changing the existing parameter type is breaking; use a deprecation/migration window or approve a major-version break.

## Controlled/uncontrolled contract audit

`UiSelectField`, `UiMultiSelectField`, and `UiDateField` name their public input `value`, which conventionally denotes the current source of truth, but pass it to `Controlled* .initialValue` (`select_field.dart:71-73`, `multi_select_field.dart:70-72`, `date_field.dart:47-49`). In shadcn 0.0.53, `ControlledComponentAdapter` copies `initialValue` only in `initState` and its `didUpdateWidget` handles only controller replacement (`control.dart:221-241` in the resolved dependency). Therefore a parent rebuild with a new `value` does not update the displayed selection/date. This is CONFIRMED, not merely naming preference.

`UiNumberField` similarly passes its `value` through the text field's `initialValue` only when no controller is supplied (`number_field.dart:83-87`). Controller mode synchronizes; value-only mode does not promise or provide external synchronization. Its dual modes need explicit naming (`initialValue`) or a truly controlled implementation.

## Internal adapters versus rename-only wrappers

The active field wrappers and confirmation function add shared semantics, localization ownership, conversion, field chrome, and interaction policy; they are not purely rename-only. `UiContent`, `UiSection`, and `UiActionGroup` also encode reusable composition rules.

The empty `UiButton` at `tokens.dart:19` is neither an adapter nor a component. It is not exported or referenced and should be removed during an approved implementation phase. Proposed future wrappers in documentation are not current API.

## Compatibility constraints for remediation

- Preserve existing symbol names where possible.
- Adding optional controllers can be source-compatible, but changing `value` semantics may reveal latent application assumptions and needs regression tests.
- Replacing `shadcn.DateTimeRange` is source-breaking for current consumers.
- Do not expose upstream controllers/enums to solve synchronization; keep conversions internal.
- Avoid wrappers that only rename a shadcn class. Add a wrapper only where it establishes stable NexaBiz semantics, tokens, accessibility, or cross-version adaptation.

