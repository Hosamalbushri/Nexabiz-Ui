# Phase 02 — Upstream Component Inventory & Architectural Classification (Revised)

**Package:** `packages/nexabiz_ui` (NexaBiz UI Foundation)  
**Upstream Dependency:** `shadcn_flutter 0.0.53` (Pinned)  
**Author:** Principal Flutter Architect, Design System Engineer and Reusable Package Architect  
**Status:** Approved Architectural Inventory (Updated for Step 01-B)  

---

## 1. Inventory Strategy & Philosophy

NexaBiz UI strictly enforces the **Definitive Dependency Law**:
```text
Application / Consumer Code (including Workbench)
         ↓
     nexabiz_ui (Canonical Public API)
         ↓
  shadcn_flutter (0.0.53 Pinned Internal Engine)
         ↓
       Flutter SDK
```

Consumer applications **must never import `shadcn_flutter` directly**. Every UI capability required to construct complete enterprise administrative and ERP applications must be supplied through canonical `Ui*` contracts.

### 1.1. Classification Taxonomy
Upstream components are classified into six distinct architectural categories:
1. **`SUPPORTED_P01`**: Components implemented, stress-tested, and certified during Phase 01.
2. **`EXPOSE_NEXABIZ`**: Upstream components requiring a canonical `Ui*` public contract with strict type isolation.
3. **`COMPOSE_NEXABIZ`**: Composite capabilities assembled from multiple upstream primitives into an ergonomic business contract.
4. **`INTERNAL_SHADCN`**: Upstream primitives used strictly inside `nexabiz_ui/src/` as hidden implementation machinery.
5. **`REJECTED_BY_G8`**: Upstream components whose direct wrapping is prohibited by Architecture Boundary Guard G8 (e.g., rename-only visual wrappers or monolithic page templates).
6. **`NOT_REQUIRED`**: Promotional, marketing, or consumer widgets out of scope for enterprise administrative software.

### 1.2. Verification Status Legend
- **`VERIFIED`**: Inspected in `shadcn_flutter 0.0.53` source; constructors, properties, and runtime behavior confirmed.
- **`UNCERTAIN`**: Upstream capabilities require internal adaptation or custom rendering to meet NexaBiz standards.
- **`UNSUPPORTED`**: Excluded from scope or forbidden by architectural guards.

---

## 2. Comprehensive Component Inventory Table

| Upstream Component (`shadcn_flutter 0.0.53`) | Source Path (`lib/src/...`) | NexaBiz Status | Proposed NexaBiz Contract | Verification Status | Classification | Architectural Decision & Type Safeguards |
|---|---|---|---|---|---|---|
| `TextField` | `components/form/text_field.dart` | Certified (P01) | `UiTextField` | `VERIFIED` | `SUPPORTED_P01` | Certified in Step 07. Wraps `UiFieldShell` + `FieldTextControllerBridge`. |
| `TextArea` | `components/form/text_field.dart` | Certified (P01) | `UiTextField` (`maxLines: null`) | `VERIFIED` | `SUPPORTED_P01` | Covered via multiline parameters on `UiTextField`. |
| `Select` / `ControlledSelect` | `components/form/select.dart` | Certified (P01) | `UiSelectField` | `VERIFIED` | `SUPPORTED_P01` | Certified in Step 07. Virtualized via `SelectItemBuilder`; caller decoupled from `SelectController`. |
| `MultiSelect` / `ControlledMultiSelect` | `components/form/multi_select.dart` | Certified (P01) | `UiMultiSelectField` | `VERIFIED` | `SUPPORTED_P01` | Certified in Step 07. Virtualized via `SelectItemBuilder`; immutability preserved. |
| `AutoComplete` | `components/form/autocomplete.dart` | Certified (P01) | `UiAutocompleteField` | `VERIFIED` | `SUPPORTED_P01` | Certified in Step 07. Synchronous in-memory string suggestions with proxy bridge. |
| `DatePicker` / `ControlledDatePicker` | `components/form/date_picker.dart` | Certified (P01) | `UiDateField` | `VERIFIED` | `SUPPORTED_P01` | Certified in Step 07. Standard Dart `DateTime` contract with `UiFieldShell`. |
| `DateRangePicker` | `components/form/date_picker.dart` | Certified (P01) | `UiDateRangeField` | `VERIFIED` | `SUPPORTED_P01` | Certified in Step 07. Standard Flutter `DateTimeRange` contract with strict interaction gating. |
| `AlertDialog` | `components/overlay/alert_dialog.dart` | Certified (P01) | `showUiConfirmationDialog` | `VERIFIED` | `SUPPORTED_P01` | Certified in Step 07. Functional async confirmation dialog contract. |
| `PrimaryButton`, `Button` | `components/control/button.dart` | Direct Workbench Use | `UiButton` | `VERIFIED` | `EXPOSE_NEXABIZ` | Unified button with canonical `UiButtonVariant.primary`. Requires `UiSpinner` for `isLoading`. |
| `OutlineButton` | `components/control/button.dart` | Direct Workbench Use | `UiButton.outline` | `VERIFIED` | `EXPOSE_NEXABIZ` | Secondary outline action trigger. |
| `GhostButton` | `components/control/button.dart` | Direct Workbench Use | `UiButton.ghost` | `VERIFIED` | `EXPOSE_NEXABIZ` | Borderless subtle action trigger. |
| `DestructiveButton` | `components/control/button.dart` | Direct Workbench Use | `UiButton.destructive` | `VERIFIED` | `EXPOSE_NEXABIZ` | Dangerous / delete action trigger. |
| `IconButton` | `components/control/button.dart` | Direct Workbench Use | `UiIconButton` | `VERIFIED` | `EXPOSE_NEXABIZ` | Accessible icon button with required semantic label and tooltip. |
| `CircularProgressIndicator` / `Spinner` | `components/display/circular_progress_indicator.dart`, `display/spinner.dart` | Direct Workbench Use | `UiSpinner` | `VERIFIED` | `EXPOSE_NEXABIZ` | **Corrected Path:** Located in `display/`. Essential primitive loading indicator co-delivered with `UiButton` in Step 02. |
| `Checkbox` | `components/form/checkbox.dart` | Direct Workbench Use | `UiCheckbox` / `UiCheckboxField` | `VERIFIED` | `EXPOSE_NEXABIZ` | **Type Isolation:** Upstream uses `CheckboxState` (`checked`, `unchecked`, `indeterminate`). `UiCheckbox` strictly exposes `bool?` to caller; zero `CheckboxState` leakage. |
| `Switch` | `components/form/switch.dart` | Direct Workbench Use | `UiSwitch` / `UiSwitchField` | `VERIFIED` | `EXPOSE_NEXABIZ` | Standalone toggle + full field variant with error/helper text. |
| `RadioGroup`, `Radio` | `components/form/radio_group.dart` | Direct Workbench Use | `UiRadioGroup` / `UiRadioGroupField` | `VERIFIED` | `EXPOSE_NEXABIZ` | Accessible radio selection group + full field shell integration. |
| `Slider` | `components/form/slider.dart` | Missing | `UiSlider` / `UiSliderField` | `VERIFIED` | `EXPOSE_NEXABIZ` | **Type Isolation:** Upstream uses `SliderValue`. `UiSlider` strictly exposes primitive `double` (`min`, `max`, `divisions`). |
| `Card` | `components/layout/card.dart` | Missing | `UiCard` | `VERIFIED` | `COMPOSE_NEXABIZ` | **Corrected Path:** Located in `layout/`. Upstream `Card` has no header/title slots. `UiCard` provides structured slots (`title`, `description`, `header`, `footer`, `actions`). |
| `Divider`, `VerticalDivider` | `components/display/divider.dart` | Missing | `UiDivider` | `VERIFIED` | `EXPOSE_NEXABIZ` | Accessible horizontal and vertical visual separator. |
| `Badge`, `PrimaryBadge` | `components/display/badge.dart` | Missing | `UiBadge` | `VERIFIED` | `EXPOSE_NEXABIZ` | Status tag with semantic variants (primary, secondary, outline, destructive). |
| `Chip`, `ChipButton` | `components/display/chip.dart` | Missing Public Deliverable | `UiChip` | `VERIFIED` | `EXPOSE_NEXABIZ` | **Reconciled Deliverable:** Compact interactive chip with optional delete/dismiss callback. Used internally by `UiMultiSelectField`; now public. |
| `Avatar` | `components/display/avatar.dart` | Missing | `UiAvatar` | `VERIFIED` | `EXPOSE_NEXABIZ` | User initials fallback, image loading, and size variants (`sm`, `md`, `lg`). |
| `Tooltip` | `components/overlay/tooltip.dart` | Missing | `UiTooltip` | `VERIFIED` | `EXPOSE_NEXABIZ` | Accessible hover/long-press informational hint. |
| `Progress`, `LinearProgressIndicator` | `components/display/progress.dart`, `display/linear_progress_indicator.dart` | Missing | `UiProgress` | `VERIFIED` | `EXPOSE_NEXABIZ` | Determinate progress bar (0.0 to 1.0) and indeterminate animation. |
| `Skeleton` | `components/display/skeleton.dart` | Missing | `UiSkeleton` | `VERIFIED` | `EXPOSE_NEXABIZ` | Content-shaped loading placeholder for asynchronous data loading. |
| `Alert` | `components/display/alert.dart` | Missing | `UiAlert` | `VERIFIED` | `EXPOSE_NEXABIZ` | Prominent inline callout banner with title, description, and status icons. |
| `Tabs` | `components/navigation/tabs/tabs.dart` | Missing | `UiTabs<T>` | `VERIFIED` | `EXPOSE_NEXABIZ` | Typed segmented tab switcher for in-page navigation and view toggling. |
| `Breadcrumb` | `components/layout/breadcrumb.dart` | Missing | `UiBreadcrumb` | `VERIFIED` | `EXPOSE_NEXABIZ` | Hierarchical navigation trail with clickable links and current item. |
| `Pagination` | `components/navigation/pagination.dart` | Missing | `UiPagination` | `VERIFIED` | `EXPOSE_NEXABIZ` | Numeric page navigator with next/prev, ellipsis, and page size callback. |
| `Accordion` | `components/layout/accordion.dart` | Missing | `UiAccordion` | `VERIFIED` | `EXPOSE_NEXABIZ` | Collapsible panels with single or multiple expansion modes. |
| `Table` | `components/layout/table.dart` | Missing | `UiTable<T>` | `VERIFIED` | `COMPOSE_NEXABIZ` | Advanced data presentation grid with typed columns, row selection, and sorting. Hides `TableRow`, `TableCell`, `FlexTableSize`. |
| `DropdownMenu`, `Menu` | `components/overlay/menu.dart` | Missing | `showUiDropdownMenu<T>` | `VERIFIED` | `COMPOSE_NEXABIZ` | Contextual action menu triggered by button or pointer. |
| `Drawer`, `openDrawerOverlay` | `components/overlay/drawer.dart` | Direct Workbench Use | `showUiDrawerSheet<T>` | `VERIFIED` | `COMPOSE_NEXABIZ` | Contextual side drawer / sheet for record inspection and filters. |
| `Toast`, `ToastLayer`, `showToast` | `components/overlay/toast.dart` | Direct Workbench Use | `showUiToast`, `UiToastLayer` | `VERIFIED` | `COMPOSE_NEXABIZ` | Functional toast contract anchored to root overlay. |
| `ShadcnApp` | `shadcn_app.dart` | Direct Workbench Use | `UiApp` | `VERIFIED` | `COMPOSE_NEXABIZ` | Root app bootstrap wiring theme, scaling, toast layer, and open locales. |
| `ThemeData`, `ColorSchemes` | `theme/theme.dart`, `theme/generated_themes.dart` | Direct Workbench Use | `UiThemeData`, `UiColorScheme`, `UiTheme` | `VERIFIED` | `INTERNAL_SHADCN` | Encapsulated token-driven theme configuration; eliminates `shadcn.ThemeData` in `lib/main.dart`. |
| `Scaffold` | `components/layout/scaffold.dart` | Direct Workbench Use | None (Rejected) | `VERIFIED` | `REJECTED_BY_G8` | **Architectural Correction:** Prohibited by Guard G8 ("rename-only visual wrappers and application page templates prohibited"). Administrative pages are composed by callers using `UiContent`, `UiSection`, `UiCard`, `UiTable`. |
| `Clickable`, `Hover` | `components/control/clickable.dart` | Internal Detail | N/A | `VERIFIED` | `INTERNAL_SHADCN` | Implementation detail of buttons and interactive surfaces. |
| `SubFocus`, `FocusOutline` | `components/navigation/focus.dart` | Internal Detail | N/A | `VERIFIED` | `INTERNAL_SHADCN` | Internal focus ring and keyboard navigation machinery. |
| `SelectPopup`, `SelectItemBuilder` | `components/form/select.dart` | Internal Detail | N/A | `VERIFIED` | `INTERNAL_SHADCN` | Internal delegation mechanism inside `UiSelectField`. |
| `Collapsible` | `components/layout/collapsible.dart` | Internal Detail | N/A | `VERIFIED` | `INTERNAL_SHADCN` | Low-level primitive used inside `UiAccordion`. |
| `Popover`, `PopoverController` | `components/overlay/popover.dart` | Internal Detail | N/A | `VERIFIED` | `INTERNAL_SHADCN` | Overlay engine used internally by select, date, and menu. |
| `OverlayBarrier`, `BackdropTransform` | `components/overlay/overlay.dart` | Internal Detail | N/A | `VERIFIED` | `INTERNAL_SHADCN` | Internal modal surface management. |
| `ColorPicker`, `EyeDropper` | `components/form/color_picker.dart` | Excluded | N/A | `VERIFIED` | `NOT_REQUIRED` | Consumer graphic tool; out of scope for enterprise ERP. |
| `NumberTicker` | `components/display/number_ticker.dart` | Excluded | N/A | `VERIFIED` | `NOT_REQUIRED` | Marketing/promotional counter widget. |
| `Carousel` | `components/layout/carousel.dart` | Excluded | N/A | `VERIFIED` | `NOT_REQUIRED` | Consumer media slider; inappropriate for administrative views. |
| `StarRating` | `components/form/star_rating.dart` | Excluded | N/A | `VERIFIED` | `NOT_REQUIRED` | Consumer review widget. |
| `HoverCard` | `components/overlay/hover_card.dart` | Excluded | N/A | `VERIFIED` | `NOT_REQUIRED` | Duplicative with `UiTooltip` and `UiCard`. |

---

## 3. Reconciliation & Deliverable Scope

### 3.1. Phase 01 Baseline (100% Preserved)
All 21 public contracts certified at Phase 01 Step 07 remain intact and must never regress:
- `UiTokens`, `UiTextRole`, `UiLayoutTier`, `UiResponsive`
- `UiContent`, `UiSection`, `UiActionGroup`, `UiEmptyState`, `UiErrorState`
- `UiFieldShell`, `UiTextField`, `UiNumberField`, `UiSelectField`, `UiMultiSelectField`, `UiAutocompleteField`, `UiDateField`, `UiDateRangeField`
- `UiFormLayout`, `UiFormSpan`, `UiFormSpanType`
- `showUiConfirmationDialog`

### 3.2. Direct Workbench Imports to Completely Eliminate
By the end of Phase 02 Step 10, `lib/main.dart` must delete its `import 'package:shadcn_flutter/shadcn_flutter.dart'` directive completely. All direct usages will be replaced by canonical NexaBiz contracts:
- `shadcn.PrimaryButton`, `shadcn.OutlineButton`, `shadcn.GhostButton`, `shadcn.DestructiveButton` → `UiButton` / `UiButton.outline` / `UiButton.ghost` / `UiButton.destructive`
- `shadcn.Checkbox`, `shadcn.CheckboxState` → `UiCheckbox` / `UiCheckboxField` (pure `bool?` contract)
- `shadcn.Switch` → `UiSwitch` / `UiSwitchField`
- `shadcn.RadioGroup<int>`, `shadcn.Radio` → `UiRadioGroup<int>` / `UiRadioGroupField<int>`
- `shadcn.showToast`, `shadcn.ToastLayer` → `showUiToast`, `UiToastLayer`
- `shadcn.openDrawerOverlay`, `shadcn.OverlayPosition` → `showUiDrawerSheet`, `UiDrawerPosition`
- `shadcn.ShadcnApp`, `shadcn.AdaptiveScaling`, `shadcn.ThemeData`, `shadcn.ColorSchemes`, `shadcn.ThemeMode` → `UiApp`, `UiThemeData`, `UiColorScheme`
- `shadcn.Scaffold` → Standard Flutter layout (`Column` / `Row` / `Expanded`) composed with `UiSection`, `UiContent`, and `UiCard`.

### 3.3. New Capabilities Added in Step 01-B Corrections
1. **`UiSpinner`**: Explicitly elevated to Step 02 prerequisite to eliminate the dependency inversion with `UiButton.isLoading`.
2. **`UiChip`**: Formally added to Step 03 display elements inventory to decouple selected tags and interactive filters.
3. **`UiThemeData` & `UiColorScheme`**: Formally added to Step 10 deliverables to allow consumer apps and Workbench to configure themes cleanly without importing `shadcn_flutter`.
4. **Rejection of `UiScaffold`**: Formally removed as a proposed wrapper to honor Guard G8 and maintain pure composite architecture.
