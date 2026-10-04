# Phase 01 / Step 05 — Public API audit and migration proposal

## Scope and evidence

Audited the **current** active package at Git commit `fec85f2` plus the existing uncommitted Phase 01 changes; historical certification reports were treated as references, not as current-source evidence. The supported barrel `packages/nexabiz_ui/lib/nexabiz_ui.dart:4–22` exports 21 symbols through explicit `show` clauses. I inspected each exported symbol's public constructor, field, callback, method, enum values, and generic constraints, plus every `shadcn.` reference in active `lib`. All active package tests, Workbench usages, relevant documentation, workspace architecture rules, and resolved `shadcn_flutter 0.0.53` date-range source were checked. No production or test code was changed in this audit.

## Current exported-surface inventory

“Flutter” includes standard Flutter SDK types (`Widget`, `BuildContext`, `TextEditingController`, `FocusNode`, `TextStyle`, input enums/formatters, etc.). Internal shadcn widget/theme/controller usage is intentionally **not** classified as public leakage.

| Exported symbol | Public constructor/properties/callbacks/methods and generic bounds | Upstream leak |
| --- | --- | --- |
| `UiTokens` | Five `double` constants; no constructor exposed | No |
| `UiTextRole` | Own four enum values; `resolve(BuildContext) → TextStyle` | No |
| `UiLayoutTier` | Own four enum values; `forWidth(double) → UiLayoutTier` | No |
| `UiResponsive` | `Widget Function(BuildContext,double,UiLayoutTier)` builder | No |
| `UiContent` | Flutter `Widget`, `EdgeInsetsGeometry`, `AlignmentGeometry`, `double?` | No |
| `UiSection` | Strings/Widgets, trailing Widget, `double` gap | No |
| `UiActionGroup` | `List<Widget>`, Flutter `WrapAlignment`/`WrapCrossAlignment`, spacing doubles | No |
| `UiEmptyState` | Strings/Widgets, Flutter padding, max-width double | No |
| `UiErrorState` | Same shape as empty state; internal shadcn color resolution only | No |
| `UiFieldShell` | Strings, child `Widget`, enabled/read-only booleans | No |
| `UiTextField` | Flutter controller/focus/input/formatter types, string callbacks, flags | No |
| `UiNumberField` | Flutter controller/focus/input types; `num?` value and callback; `parseNumeric(String) → num?` | No |
| `UiSelectField<T>` | Unbounded generic `T`; `List<T>`, `T?`, item builders, `ValueChanged<T?>?`; private shadcn controller | No |
| `UiMultiSelectField<T>` | Unbounded generic `T`; `List<T>?`, fresh-list callback, item builders; private shadcn controller | No |
| `UiAutocompleteField` | Flutter controller/focus/input types, `List<String>`, string callbacks | No |
| `UiDateField` | `DateTime?` and `ValueChanged<DateTime?>?`; private shadcn controller | No |
| `UiDateRangeField` | `shadcn.DateTimeRange? value` and `ValueChanged<shadcn.DateTimeRange?>? onChanged` | **Confirmed** |
| `UiFormLayout` | `List<Widget>`, maximum column count | No |
| `UiFormSpan` | Flutter child `Widget`, own `UiFormSpanType` (normal/wide/full); three named constructors | No |
| `UiFormSpanType` | Own enum values only | No |
| `showUiConfirmationDialog` | Flutter `BuildContext`, localized strings, booleans; returns `Future<bool?>` | No |

The only confirmed upstream type in an official exported contract is at `packages/nexabiz_ui/lib/src/fields/date_range_field.dart:27–28`; that class is exported at `lib/nexabiz_ui.dart:19`. Its current source comment at `date_range_field.dart:10` incorrectly calls the range “standard Dart.” `UiButton` exists in `tokens.dart:19` but is excluded by the barrel's `show UiTokens`; it is not this leak and is out of scope. Direct `lib/src/...` imports are not the supported public barrel. No public typedef or shadcn-constrained generic was found among the exported symbols.

## Upstream and independent range semantics

The pinned upstream defines a distinct positional `shadcn.DateTimeRange(start,end)` at `shadcn_flutter-0.0.53/lib/src/components/form/date_picker.dart:382–420`. It stores arbitrary `DateTime` endpoints, compares both by value, and does **not** validate ordering. `DateRangePicker.value` and `onChanged` use that type (`date_picker.dart:442–447`); the picker passes the value to `ObjectFormField` and converts calendar selection back to a shadcn range (`date_picker.dart:500–546`). The calendar's `RangeCalendarValue` normalizes selected endpoints (`lib/src/components/display/calendar.dart:738–751`). Upstream display formats dates with `showTime: false`, but the value retains the original time portions.

Flutter provides `DateTimeRange<T extends DateTime>` in `package:flutter/material.dart` (`Flutter SDK lib/src/material/date.dart:451–480`), with named `start:`/`end:` arguments, value equality, and a documented/asserted `start <= end` invariant. It is a standard Flutter SDK value type, suitable for an upstream-neutral public contract without adding a dependency or inventing a rename-only package value class. However, the existing G7 workspace guard (`test/architecture/boundary_test.dart`, around line 166) forbids **any** `package:flutter/material.dart` import. A narrow exception for `import 'package:flutter/material.dart' show DateTimeRange;` is needed; that imports a value type only and does not transfer visual/theme authority to Material. A blanket relaxation would be inappropriate.

Proposed post-approval contract:

```dart
final DateTimeRange? value;
final ValueChanged<DateTimeRange?>? onChanged;
```

The internal adapter would map null to null; non-null input to `shadcn.DateTimeRange(value.start, value.end)`; and non-null picker output to `DateTimeRange(start: range.start, end: range.end)`. Clearing maps to a single `null` callback. Conversion must preserve each `DateTime` exactly (including UTC/local status and time-of-day), with **no** implicit truncation, timezone conversion, reordering, or duplicate callback. Flutter's range contract requires ordered endpoints; callers with previously reversed upstream ranges must normalize them explicitly before migration. Calendar-selected ranges are already normalized upstream. Equal endpoints are valid. Both range classes use endpoint equality, so a fresh internal object on rebuild should still reconcile by value; the test plan must prove parent update and null reset. The existing `enabled && !readOnly` callback boundary (`date_range_field.dart:47–49`) and LTR/RTL behavior must remain untouched.

This is a date-selection UI, not a general time-range editor: the picker shows dates and user calendar selection may produce date-only local-midnight values. The adapter should not introduce a new date-only normalization policy; any such policy needs separate approval.

## Compatibility and exact repository migration

Changing `UiDateRangeField.value` and `onChanged` to Flutter `DateTimeRange?` is **source-breaking**. Existing `shadcn.DateTimeRange` values are unrelated Dart types and cannot be passed to the new parameter; strongly typed callbacks/state also stop compiling. Positional construction becomes named construction. This is not a silent refactor, despite the existing misleading docs.

Known active call sites:

| Consumer | Existing usage | Required migration after approval |
| --- | --- | --- |
| Workbench `lib/main.dart:70–73,587–590` | `shadcn.DateTimeRange?` state, positional constructor, field value/callback | Import Flutter `DateTimeRange` via a narrow `show`; change state type and constructor to named endpoints; callback state assignment remains structurally the same |
| `packages/nexabiz_ui/test/date_range_interaction_test.dart:20–29,33–50` | Upstream range fixtures and typed callback capture | Use Flutter range fixtures/capture; keep upstream picker/dialog assertions and actual interaction expectations, converting expected values as needed |
| `packages/nexabiz_ui/test/date_field_test.dart:58–102` | Upstream range fixtures passed to field | Use Flutter range fixture and retain rendering/RTL assertions |
| `packages/nexabiz_ui/test/field_state_contract_test.dart:257–310` | Upstream range fixtures and parent updates | Use Flutter ranges; retain reset/reuse/callback-count assertions |
| `test/workbench_test.dart:94` | Type-existence assertion only | No source change expected; rerun |
| `docs/fields.md:71–74`, `docs/phase_05_evidence.md:13,27`, `docs/phase_05_certification.md:65–66` | Claims “standard Dart DateTimeRange” today | Correct wording to “Flutter `DateTimeRange`” after migration and document import/constructor and date-only behavior |

Repository search found no other active source call sites. The legacy package is a separate reference and is **not** part of this migration. External consumers are unknown; those using upstream ranges must perform the same type/constructor migration. A compatibility-only extra constructor or deprecated upstream-typed parameter would keep leakage in the exported API, so it does not meet the objective. An `Object?`/`dynamic` bridge would sacrifice type safety and is not recommended. If consumers require a deprecation window instead of an immediate break, a versioned transition must be approved as a different contract strategy.

## Proposed implementation and verification after approval

1. Update only `UiDateRangeField`'s public value/callback to Flutter `DateTimeRange?` and add the internal nullable two-way adapter. Preserve the existing interaction boundary and semantics.
2. Migrate the listed Workbench/tests/docs call sites without weakening assertions. Add LTR/RTL tests for initial value, actual user selection, one converted callback, parent update, null reset, ordered/equal endpoints, disabled/read-only behavior, and preserved time components.
3. Add a compile-level public API isolation test that imports only the NexaBiz barrel plus Flutter's `DateTimeRange` and type-checks both value and callback. Extend the architecture guard to inspect exported public signatures for upstream-qualified types while allowing shadcn in private implementation; update G7 only for a show-only `DateTimeRange` import. Avoid scanning all `shadcn.` occurrences, which would prohibit legitimate adapters.
4. Run format, analyze, full active package suite, architecture suite, and Workbench suite; record actual output and any migration failure.

**Approval gate:** no production, Workbench, existing test, or architecture-guard edits were made because this change breaks the public API. Do not implement until the breaking contract and migration scope are explicitly approved.
