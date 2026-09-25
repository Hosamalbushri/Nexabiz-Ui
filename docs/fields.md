# NexaBiz Field System & Selection Foundation (Phase 05)

## 1. Overview & Canonical Field Law

All fields in `nexabiz_ui` MUST compose `UiFieldShell` for presentation chrome (label, required indicator, description, supporting/error text, accessibility, and minimum control height).

```text
UiFieldShell
      ↓
canonical field presentation (label, required indicator, description, error/helper, semantics)

shadcn controls
      ↓
visual/input behavior (TextField, Select, MultiSelect, AutoComplete, DatePicker, DateRangePicker)

specialized Ui fields
      ↓
reusable composition/policy layer (UiTextField, UiNumberField, UiSelectField, UiMultiSelectField, UiAutocompleteField, UiDateField, UiDateRangeField)
```

---

## 2. Shared Field Contract

Every field accepts the standard `UiFieldShell` properties:

| Property | Type | Description |
| --- | --- | --- |
| `label` | `String` | Field header text. Must not be empty. |
| `requiredIndicator` | `String?` | Caller-localized required indicator string (e.g. "Required" or "مطلوب"). |
| `description` | `String?` | Secondary hint text rendered below the label. |
| `helper` | `String?` | Supporting text rendered below the control when no error exists. |
| `error` | `String?` | Validation error text. Triggers red text, destructive color scheme, and live region semantics. |
| `enabled` | `bool` | Whether the control accepts user interaction. |
| `readOnly` | `bool` | Whether the control is read-only. |

---

## 3. Public Field Symbol Reference

### `UiTextField`
Single-line or multi-line text input field.
- **State Ownership**: Caller owns `controller`, `focusNode`, `onChanged`, `onSubmitted`.
- **Multiline Support**: Configured via `minLines`, `maxLines`, and `keyboardType`.

### `UiNumberField`
Generic numeric input field.
- **Intermediate States**: Preserves intermediate editing strings (`-`, `.`, `-.`, `1.`, `0.`) without premature reset or emitting `0`.
- **Numeric Callbacks**: Emits `onNumberChanged(num?)` alongside `onChanged(String)`.
- **Options**: `allowDecimals = true`, `allowNegative = true`.

### `UiSelectField<T>`
Canonical single-selection dropdown field.
- **API**: `items: List<T>`, `itemLabelBuilder` or `itemBuilder`, `value: T?`, `onChanged`, `canUnselect`.

### `UiMultiSelectField<T>`
Canonical multi-selection dropdown field.
- **Content-Driven Selected Display**: Selected items render inside chips formatted cleanly per item using `SelectValueBuilder<T>`, handling 320/420/960 width hosts and TextScaler 2.0 without horizontal clipping or fixed total height.
- **API**: `items: List<T>`, `value: List<T>?`, `onChanged: ValueChanged<List<T>>?`.

### `UiAutocompleteField`
Local synchronous autocomplete field.
- **Behavior**: Filters local string suggestions as user types in `controller`, presenting a popover list of options when focused.
- **API**: `suggestions: List<String>`, `controller`, `onSelected`.

### `UiDateField`
Single date selection field.
- **Types**: Standard Dart `DateTime?`. No timezone or business rule imposition.
- **Presentation**: Integrated popover calendar with `UiFieldShell` chrome.

### `UiDateRangeField`
Date range selection field.
- **Types**: Standard Dart `DateTimeRange?`.
- **Presentation**: Formatted date-range selector with calendar popover.
