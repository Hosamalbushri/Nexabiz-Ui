# Public API Type Leak Audit (`docs/shadcn_type_leak_audit.md`)

## 1. Executive Summary
- **Certified Public Contracts Inspected**: 21
- **Contracts with 0 Leaked Types**: 20 (95.2%)
- **Contracts with Leaked Types**: 1 (4.8% - `UiDateRangeField`)
- **Total Leaked Upstream Types**: 1 (`shadcn.DateTimeRange`)
- **Target Long-Term State**: `0`

---

## 2. Detailed Audit Table (21 Public Contracts)

| Symbol Name | File Path | Exposed `shadcn` Types | Compliance Status | Remediation Plan |
|---|---|---|---|---|
| `UiTokens` | `src/foundation/tokens.dart` | `NONE` | PASS | N/A |
| `UiTextRole` | `src/foundation/typography.dart` | `NONE` | PASS | N/A |
| `UiResponsive` | `src/foundation/responsive.dart` | `NONE` | PASS | N/A |
| `UiLayoutTier` | `src/foundation/responsive.dart` | `NONE` | PASS | N/A |
| `UiContent` | `src/composition/content.dart` | `NONE` | PASS | N/A |
| `UiSection` | `src/composition/section.dart` | `NONE` | PASS | N/A |
| `UiActionGroup` | `src/composition/action_group.dart` | `NONE` | PASS | N/A |
| `UiEmptyState` | `src/composition/empty_state.dart` | `NONE` | PASS | N/A |
| `UiErrorState` | `src/composition/error_state.dart` | `NONE` | PASS | N/A |
| `UiFieldShell` | `src/fields/field_shell.dart` | `NONE` | PASS | N/A |
| `UiTextField` | `src/fields/text_field.dart` | `NONE` | PASS | N/A |
| `UiNumberField` | `src/fields/number_field.dart` | `NONE` | PASS | N/A |
| `UiSelectField` | `src/fields/select_field.dart` | `NONE` | PASS | N/A |
| `UiMultiSelectField` | `src/fields/multi_select_field.dart` | `NONE` | PASS | N/A |
| `UiAutocompleteField` | `src/fields/autocomplete_field.dart` | `NONE` | PASS | N/A |
| `UiDateField` | `src/fields/date_field.dart` | `NONE` | PASS | N/A |
| `UiDateRangeField` | `src/fields/date_range_field.dart` | `shadcn.DateTimeRange` | **DEFECT** | Replace with standard Flutter `DateTimeRange` in Wave 1 |
| `UiFormLayout` | `src/forms/form_layout.dart` | `NONE` | PASS | N/A |
| `UiFormSpan` | `src/forms/form_span.dart` | `NONE` | PASS | N/A |
| `UiFormSpanType` | `src/forms/form_span.dart` | `NONE` | PASS | N/A |
| `showUiConfirmationDialog` | `src/interaction/confirmation_dialog.dart` | `NONE` | PASS | N/A |

---

## 3. Defect Analysis & Remediation
- **Defect**: `UiDateRangeField` uses `shadcn.DateTimeRange? value` and `ValueChanged<shadcn.DateTimeRange?>? onChanged`.
- **Root Cause**: Upstream `DateRangePicker` required `shadcn.DateTimeRange` wrapper instead of Flutter core `DateTimeRange`.
- **Remediation**: `UiDateRangeField` will accept standard Flutter `DateTimeRange` (`import 'package:flutter/material.dart' show DateTimeRange;` or pure Dart class) and map internally to `shadcn.DateTimeRange`.
