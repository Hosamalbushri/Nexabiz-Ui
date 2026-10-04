# Test and Guard Coverage

## Actual suites

Active package tests (86 executions):

- `autocomplete_field_test.dart`: render contract, source check for timing hacks, 1,000-item no-throw smoke.
- `composition_test.dart`: content/section/action/empty/error layout, directions, scaling and semantics.
- `date_field_test.dart`: date/date-range initial render plus RTL/LTR and 200% smoke.
- `form_system_test.dart`: spans, local widths, direct shadcn composition, custom shell, focus order, 25-field smoke.
- `number_field_test.dart`: initial text, intermediate states, negative/decimal restrictions, direction/scale.
- `overlay_interaction_test.dart`: confirmation results, barrier/Escape, focus restoration, Arabic/long labels, toast.
- `page_composition_test.dart`: form/details/settings/state/nested host/dialog/drawer/RTL recipes.
- `selection_field_test.dart`: initial selection/equality, list non-mutation, 10 chips, disabled/error smoke.
- `text_field_test.dart`: single/multiline, obscure text, formatter/action, scaling.
- `vertical_slice_test.dart`: tier boundaries, 18 direction/scale/width layout cases, controller sync, focus, validation, semantics and theme.

Workspace: 14 G1–G14 architecture tests and 3 Workbench widget tests. All passed during this audit.

## Architecture guard assessment

| Requirement | Current guard | Coverage judgment |
|---|---|---|
| No upstream types in public API | None | **Gap**; G3 checks exact export statements, not signature types |
| No direct shadcn controls in application code | None | **Gap**; G2 permits any dependency other than package internals/legacy |
| No business logic in generic package | G1, G4, G10, G14 | Partial and useful; mostly import/name substring checks |
| Minimal dependencies | G4–G6 | Good direct-dependency coverage |
| Local-constraint responsive behavior | G5, G7 and widget tests | Good baseline; extreme/nested popup widths missing |
| Consumer-owned localization | Documentation/import policy only | No source guard for hardcoded user-facing package strings; widget formatting not covered |
| RTL/accessibility | Widget tests | Partial; no semantics matrix for all fields/dropdowns or custom title widgets |
| Predictable state ownership | G10 only | **Gap**; no external value synchronization tests |
| Backward compatibility | G3 exact barrel | Export presence only; signatures and behavior are not API-diff checked |

G8 detects only three substrings (`class UiPage`, `UiScaffold`, `UiScreen`), so it cannot generally distinguish useful adapters from rename-only wrappers. G7 bans specific source strings, not equivalent viewport coupling. All source guards can be bypassed through aliases or alternate spellings; they are tripwires, not semantic proof.

## Defect-enabling test gaps

1. Rebuild `UiSelectField`, `UiMultiSelectField`, `UiDateField`, and value-only `UiNumberField` with a changed external value while retaining widget identity; assert displayed state changes.
2. Tap `UiDateRangeField(enabled: false)` and assert no dialog/overlay opens and no callback fires.
3. Distinguish `enabled: false` from `readOnly: true` for every field, including focusability, copy/selection behavior, semantics and callback suppression.
4. Enter Arabic-Indic digits, Eastern Arabic-Indic digits, comma decimal separators, paste signs/group separators, and verify caller-provided locale policy.
5. Measure (not merely render) autocomplete filtering and rebuilds at 10/100/1,000/10,000 items.
6. Open select/multi-select at the same scales and measure eager widget creation/frame time/memory.
7. Exercise autocomplete typing, keyboard navigation, selection, focus loss, disabled/read-only states and `onSelected` ordering.
8. Add semantics assertions for select, multi-select, date/date-range, error association, custom `titleWidget`, all directions and 100/150/200% scales.
9. Add a source/API guard that resolves exported public signatures and rejects `package:shadcn_flutter` types.
10. Add a consumer-source guard that forbids direct shadcn imports outside an explicitly documented bootstrap adapter boundary.

## Why the green baseline is insufficient

`autocomplete_field_test.dart:73-97` calls a 1,000-item render “performance” but captures no frame timings, rebuild count, CPU time or allocations. `form_system_test.dart:221-256` similarly calls a 25-field render “minimal LayoutBuilder overhead” without measuring builders. These are valid smoke tests but not performance evidence. Documentation claims of “without frame drop or memory leakage” are unsupported by those tests.

