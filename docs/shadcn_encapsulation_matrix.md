# `shadcn_flutter 0.0.53` Encapsulation Matrix (`docs/shadcn_encapsulation_matrix.md`)

## 1. Overview
This matrix classifies every UI capability in `shadcn_flutter 0.0.53` into the definitive NexaBiz UI architecture.

The `DIRECT_SHADCN` classification has been **REMOVED**. Consumer applications MUST NOT import `shadcn_flutter` directly.

### Architecture Classifications:
- `EXPOSE_NEXABIZ`: Directly exposed through an intentional, stable NexaBiz contract.
- `COMPOSE_NEXABIZ`: Formed by composing multiple primitives into a higher-level NexaBiz component.
- `INTERNAL_SHADCN`: Used internally inside `nexabiz_ui` implementation; hidden from consumer API.
- `APPLICATION_OWNED`: Domain logic, routing, authentication, business state, app-level lifecycle.
- `DEFER`: Useful capability deferred to a dedicated future encapsulation phase.
- `NOT_REQUIRED`: Upstream capability not required in NexaBiz UI vocabulary.
- `REJECT`: Conflicts with NexaBiz design-system architecture rules.

---

## 2. Capability Matrix Table

| shadcn Capability | Category | Consumer Need | Classification | Proposed NexaBiz API | shadcn Internal Implementation | Current Status | Future Phase | Notes |
|---|---|---|---|---|---|---|---|---|
| `ShadcnApp` | Theme & Root | App root bootstrap | `COMPOSE_NEXABIZ` | `UiApp` / `UiTheme` | `shadcn.ShadcnApp` | `INTERNAL` | Wave 1 | Bridges root theme & localizations |
| `Theme` / `ColorScheme` | Theme | Access theme styling | `INTERNAL_SHADCN` | `UiTextRole` / `UiTokens` | `shadcn.Theme` | `INTERNAL` | Certified | Prevents direct theme enums |
| `Button` / `PrimaryButton` | Buttons | Primary action trigger | `EXPOSE_NEXABIZ` | `UiButton` | `shadcn.PrimaryButton` | `UNEXPOSED` | Wave 1 | Uses `UiButtonVariant` |
| `OutlineButton` | Buttons | Secondary action | `EXPOSE_NEXABIZ` | `UiButton.outline` | `shadcn.OutlineButton` | `UNEXPOSED` | Wave 1 | Standard secondary button |
| `GhostButton` | Buttons | Subtle action | `EXPOSE_NEXABIZ` | `UiButton.ghost` | `shadcn.GhostButton` | `UNEXPOSED` | Wave 1 | Minimal chrome button |
| `DestructiveButton` | Buttons | Dangerous action | `EXPOSE_NEXABIZ` | `UiButton.destructive` | `shadcn.DestructiveButton` | `UNEXPOSED` | Wave 1 | Red semantic variant |
| `IconButton` | Buttons | Icon trigger | `EXPOSE_NEXABIZ` | `UiIconButton` | `shadcn.IconButton` | `UNEXPOSED` | Wave 1 | Accessible icon button |
| `Clickable` / `Hover` | Control | Interaction state | `INTERNAL_SHADCN` | N/A | `shadcn.Clickable` | `INTERNAL` | N/A | Implementation detail |
| `Toggle` / `ToggleGroup` | Control | Multi-state toggle | `DEFER` | `UiToggle` | `shadcn.Toggle` | `UNEXPOSED` | Wave 3 | Deferred |
| `TextField` / `Input` | Fields | Text input | `EXPOSE_NEXABIZ` | `UiTextField` | `shadcn.TextField` | **EXPOSED** | Phase 05 | Canonical field shell wrapper |
| `TextArea` | Fields | Multi-line text input | `EXPOSE_NEXABIZ` | `UiTextField.multiline` | `shadcn.TextArea` | **EXPOSED** | Phase 05 | Supported via `maxLines` |
| `Checkbox` | Inputs | Binary selection | `EXPOSE_NEXABIZ` | `UiCheckbox` / `UiCheckboxField` | `shadcn.Checkbox` | `UNEXPOSED` | Wave 1 | Standalone & field variant |
| `RadioGroup` / `RadioItem` | Inputs | Single choice group | `EXPOSE_NEXABIZ` | `UiRadioGroup` / `UiRadioField` | `shadcn.RadioGroup` | `UNEXPOSED` | Wave 1 | Accessible option group |
| `Switch` | Inputs | Toggle state | `EXPOSE_NEXABIZ` | `UiSwitch` / `UiSwitchField` | `shadcn.Switch` | `UNEXPOSED` | Wave 1 | Standalone & field variant |
| `Slider` | Inputs | Range selection | `EXPOSE_NEXABIZ` | `UiSlider` / `UiSliderField` | `shadcn.Slider` | `UNEXPOSED` | Wave 1 | Continuous & discrete slider |
| `InputOTP` | Inputs | Verification code | `DEFER` | `UiOtpField` | `shadcn.InputOTP` | `UNEXPOSED` | Wave 3 | Specialized input |
| `ColorPicker` / `EyeDropper` | Inputs | Color selection | `NOT_REQUIRED` | N/A | `shadcn.ColorPicker` | `UNEXPOSED` | N/A | Out of scope for ERP UI |
| `FileInput` / `FilePicker` | Inputs | File attachment | `DEFER` | `UiFileField` | `shadcn.FileInput` | `UNEXPOSED` | Wave 4 | Specialized field |
| `Select` | Selection | Popover single select | `EXPOSE_NEXABIZ` | `UiSelectField` | `shadcn.Select` | **EXPOSED** | Phase 05 | Canonical field wrapper |
| `MultiSelect` | Selection | Multi-option select | `EXPOSE_NEXABIZ` | `UiMultiSelectField` | `shadcn.MultiSelect` | **EXPOSED** | Phase 05 | Canonical field wrapper |
| `Autocomplete` | Selection | Local filter search | `EXPOSE_NEXABIZ` | `UiAutocompleteField` | `shadcn.Autocomplete` | **EXPOSED** | Phase 05 | Canonical field wrapper |
| `DatePicker` | Date/Time | Calendar date selection | `EXPOSE_NEXABIZ` | `UiDateField` | `shadcn.DatePicker` | **EXPOSED** | Phase 05 | Standard `DateTime` API |
| `DateRangePicker` | Date/Time | Date range selection | `EXPOSE_NEXABIZ` | `UiDateRangeField` | `shadcn.DateRangePicker` | **EXPOSED** | Phase 05 | Standard `DateTimeRange` API |
| `TimePicker` | Date/Time | Time selection | `DEFER` | `UiTimeField` | `shadcn.TimePicker` | `UNEXPOSED` | Wave 1 | Date/Time expansion |
| `Calendar` | Date/Time | Raw calendar grid | `DEFER` | `UiCalendar` | `shadcn.Calendar` | `UNEXPOSED` | Wave 1 | Embedded date display |
| `Command` | Selection | Command palette | `DEFER` | `UiCommandPalette` | `shadcn.Command` | `UNEXPOSED` | Wave 5 | Advanced navigation |
| `Badge` / `PrimaryBadge` | Feedback | Compact status tag | `EXPOSE_NEXABIZ` | `UiBadge` | `shadcn.PrimaryBadge` | `UNEXPOSED` | Wave 1 | Generic visual badge |
| `Progress` | Feedback | Loading progress | `EXPOSE_NEXABIZ` | `UiProgress` | `shadcn.Progress` | `UNEXPOSED` | Wave 1 | Deterministic & indeterminate |
| `Skeleton` | Feedback | Skeleton placeholder | `EXPOSE_NEXABIZ` | `UiSkeleton` | `shadcn.Skeleton` | `UNEXPOSED` | Wave 1 | Structural placeholder |
| `Alert` | Feedback | Inline status notice | `EXPOSE_NEXABIZ` | `UiAlert` | `shadcn.Alert` | `UNEXPOSED` | Wave 1 | Informational / warning banner |
| `Toast` / `ToastLayer` | Feedback | Transient toast notice | `EXPOSE_NEXABIZ` | `showUiToast` | `shadcn.Toast` | `UNEXPOSED` | Wave 2 | Functional delegate (no singleton) |
| `Tooltip` | Feedback | Hover hint | `EXPOSE_NEXABIZ` | `UiTooltip` | `shadcn.Tooltip` | `UNEXPOSED` | Wave 1 | Accessible hover hint |
| `Avatar` | Feedback | User avatar presentation | `EXPOSE_NEXABIZ` | `UiAvatar` | `shadcn.Avatar` | `UNEXPOSED` | Wave 2 | Visual identity |
| `Chip` | Feedback | Compact tag | `DEFER` | `UiChip` | `shadcn.Chip` | `UNEXPOSED` | Wave 2 | Compact tag display |
| `Spinner` | Feedback | Loading spinner | `INTERNAL_SHADCN` | N/A | `shadcn.Spinner` | `INTERNAL` | N/A | Internal indicator |
| `NumberTicker` | Feedback | Animated numbers | `NOT_REQUIRED` | N/A | `shadcn.NumberTicker` | `UNEXPOSED` | N/A | Marketing visual |
| `Card` | Surface | Visual container surface | `EXPOSE_NEXABIZ` | `UiCard` / `UiSurface` | `shadcn.Card` | `UNEXPOSED` | Wave 1 | Generic surface container |
| `Divider` | Surface | Visual separator | `EXPOSE_NEXABIZ` | `UiDivider` | `shadcn.Divider` | `UNEXPOSED` | Wave 1 | Horizontal/vertical rule |
| `Accordion` | Surface | Expandable sections | `EXPOSE_NEXABIZ` | `UiAccordion` | `shadcn.Accordion` | `UNEXPOSED` | Wave 2 | Collapsible content group |
| `Collapsible` | Surface | Low-level collapse | `INTERNAL_SHADCN` | N/A | `shadcn.Collapsible` | `INTERNAL` | N/A | Used inside `UiAccordion` |
| `Resizable` | Surface | Resizable split view | `DEFER` | `UiResizable` | `shadcn.Resizable` | `UNEXPOSED` | Wave 4 | Desktop split panes |
| `Carousel` | Surface | Image carousel | `NOT_REQUIRED` | N/A | `shadcn.Carousel` | `UNEXPOSED` | N/A | Non-ERP media widget |
| `Sortable` | Surface | Reorderable list | `DEFER` | `UiSortable` | `shadcn.Sortable` | `UNEXPOSED` | Wave 4 | Drag-to-reorder |
| `Dialog` / `AlertDialog` | Overlay | Modal dialog presentation | `COMPOSE_NEXABIZ` | `showUiConfirmationDialog` | `shadcn.AlertDialog` | **EXPOSED** | Phase 07 | Functional dialog contract |
| `Drawer` / `Sheet` | Overlay | Side panel overlay | `DEFER` | `showUiDrawer` | `shadcn.Drawer` | `UNEXPOSED` | Wave 2 | Side sheet overlay |
| `Popover` | Overlay | Contextual popover | `INTERNAL_SHADCN` | N/A | `shadcn.Popover` | `INTERNAL` | N/A | Used inside select & picker fields |
| `HoverCard` | Overlay | Preview hover card | `NOT_REQUIRED` | N/A | `shadcn.HoverCard` | `UNEXPOSED` | N/A | Out of scope |
| `Tabs` | Navigation | Local tab switching | `EXPOSE_NEXABIZ` | `UiTabs` | `shadcn.Tabs` | `UNEXPOSED` | Wave 2 | Presentation tab bar |
| `Breadcrumb` | Navigation | Location path presentation | `EXPOSE_NEXABIZ` | `UiBreadcrumb` | `shadcn.Breadcrumb` | `UNEXPOSED` | Wave 2 | Presentation breadcrumb |
| `Pagination` | Navigation | Page navigation control | `EXPOSE_NEXABIZ` | `UiPagination` | `shadcn.Pagination` | `UNEXPOSED` | Wave 2 | Presentation pagination |
| `NavigationBar` / `Sidebar` | Navigation | App shell navigation | `DEFER` | `UiSidebar` | `shadcn.Sidebar` | `UNEXPOSED` | Wave 3 | Navigation presentation |
| `Stepper` / `Steps` | Navigation | Multi-step progress | `DEFER` | `UiStepper` | `shadcn.Stepper` | `UNEXPOSED` | Wave 3 | Setup wizard presentation |
| `Timeline` | Navigation | Sequential timeline | `NOT_REQUIRED` | N/A | `shadcn.Timeline` | `UNEXPOSED` | N/A | Special visualization |
| `Tree` | Hierarchy | Tree node view | `DEFER` | `UiTree` | `shadcn.Tree` | `UNEXPOSED` | Wave 4 | Hierarchical record view |
| `Table` | Data Display | Data grid presentation | `COMPOSE_NEXABIZ` | `UiTable` | `shadcn.Table` | `UNEXPOSED` | Wave 2 | Presentation table wrapper |
