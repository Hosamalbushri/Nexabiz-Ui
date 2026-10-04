# Component Coverage

## Active package matrix

| Component | Implementation | Tests | Audit status / notable gap |
|---|---|---|---|
| `UiTokens` | `src/foundation/tokens.dart` | indirect | Constants covered through geometry; stray `UiButton` is unused |
| `UiTextRole` | `src/foundation/typography.dart` | `vertical_slice`, composition | Theme resolution covered |
| `UiResponsive` / tier | `src/foundation/responsive.dart` | `vertical_slice` | Local constraint and boundaries covered |
| `UiContent` | `src/composition/content.dart` | `composition` | Width/text scale covered |
| `UiSection` | `src/composition/section.dart` | `composition`, page composition | String title semantics covered; custom `titleWidget` semantics and sub-200 width are not |
| `UiActionGroup` | `src/composition/action_group.dart` | composition/form/page tests | Wrapping covered; oversized individual child not covered |
| `UiEmptyState` | `src/composition/empty_state.dart` | composition/page tests | Rendering/container semantics covered |
| `UiErrorState` | `src/composition/error_state.dart` | composition/page tests | Rendering/live region covered |
| `UiFieldShell` | `src/fields/field_shell.dart` | `vertical_slice` and field tests | Label/hint/live region covered; nested semantics conflicts and required-state semantics not audited by tests |
| `UiTextField` | `src/fields/text_field.dart` | `text_field`, `vertical_slice` | Strongest field coverage: controller sync, input, focus, multiline, scaling |
| `UiNumberField` | `src/fields/number_field.dart` | `number_field` | ASCII dot-decimal only; external value sync/localized digits absent |
| `UiSelectField` | `src/fields/select_field.dart` | `selection_field` | Initial render/equality/disabled smoke covered; selection interaction, external sync and scale absent |
| `UiMultiSelectField` | `src/fields/multi_select_field.dart` | `selection_field` | Initial chips/wrapping covered; interaction, external sync and large item list absent |
| `UiAutocompleteField` | `src/fields/autocomplete_field.dart` | `autocomplete_field` | Initial render/no-timer/1,000-item no-throw only; typing, selection, rebuild count and timing absent |
| `UiDateField` | `src/fields/date_field.dart` | `date_field` | Initial render/scaling only; interaction, disabled/read-only and external sync absent |
| `UiDateRangeField` | `src/fields/date_range_field.dart` | `date_field` | Initial render/scaling only; disabled bug, interaction, type boundary absent |
| `UiFormLayout` / span | `src/forms/*` | `form_system`, `vertical_slice` | Columns/spans/focus/25 fields covered; no frame timing |
| confirmation dialog | `src/interaction/confirmation_dialog.dart` | `overlay_interaction` | confirm/cancel/barrier/Escape/focus/RTL/long labels covered |

## Workbench coverage

The Workbench demonstrates every Phase 05 field and composition/interaction recipes. It also directly uses 20 distinct shadcn symbols through 46 qualified references in `lib/main.dart`, including app/scaffold, buttons, checkbox/radio/switch, drawers, toast, and `DateTimeRange`. This is useful as a component gallery but violates the newly preserved “no direct shadcn controls in application code after migration” boundary.

Its three tests verify a 320px/200% scenario, theme/direction/content/scale/validation toggles, and existence of all field primitives. They do not traverse all tabs or open/test each field dropdown, select an item, verify Arabic locale formatting, or assert semantics for Workbench controls.

## Legacy distinction

The legacy package has a much larger catalog (layout/scaffolds, theme, localization, tables, navigation, overlays, inputs, gallery/playground and many tests). None is exported by the active package. Its existence is not active component coverage and must not be used to claim implementation completeness.

## Coverage conclusion

Current coverage is credible for basic composition and smoke behavior, but thin for mutable field contracts, very large collections, disabled/read-only parity, locale-sensitive input, dropdown semantics, and actual performance. The most consequential missing tests align directly with confirmed defects.

