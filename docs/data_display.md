# Data Display Foundation Rules & Architecture (`docs/data_display.md`)

## 1. Overview
The Data Display Foundation establishes the certified patterns for presenting structured records, lists, tables, and pagination in `nexabiz_ui`.

## 2. Standardized Primitives

### `UiKeyValue`
- **Purpose**: Displays a label-value pair in horizontal or vertical orientation.
- **Contract**: Accepts `Widget label` and `Widget value`, with convenience `UiKeyValue.text()` constructor.
- **RTL & Scaling**: Fully supports RTL directionality and `TextScaler` (1.0–2.0).
- **Semantics**: Groups key and value in `Semantics(container: true)`.

## 3. Direct `shadcn_flutter` Usage (`DIRECT_SHADCN`)

### Table (`shadcn.Table`)
- Use `shadcn.Table` directly inside `UiContent` or a horizontal scroll container.
- Use `shadcn.TableHeader`, `shadcn.TableRow`, and `shadcn.TableCell` for row and cell definitions.
- Custom cell widgets (Badges, Switches, Action buttons) are placed directly inside `shadcn.TableCell`.

### Pagination (`shadcn.Pagination`)
- Use `shadcn.Pagination` directly for paginated navigation.
- Localization is handled via `ShadcnLocalizations`.

## 4. Architectural Invariants
1. **Zero Data Source Engines**: The generic foundation prohibits `UiTableDataSource`, pagination controllers, or data acquisition logic.
2. **Zero Domain Table Contracts**: Domain tables (e.g. `UiVoucherTable`, `UiInvoiceTable`) belong in application capabilities, not in `nexabiz_ui`.
3. **No Page Scaffolds in Tables**: Table widgets must not embed headers, toolbars, or page scaffolds.
4. **Caller-Owned Localization**: Hardcoded UI strings in table or pagination primitives = 0.
