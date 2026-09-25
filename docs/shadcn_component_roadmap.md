# Encapsulation Component Roadmap (`docs/shadcn_component_roadmap.md`)

## 1. Overview
This roadmap establishes the controlled implementation waves to migrate `nexabiz_ui` from a partial wrapper baseline to 100% consumer encapsulation of `shadcn_flutter`.

---

## 2. Implementation Waves

### Encapsulation Wave 1 — Common Controls & Basic Feedback
- **Objective**: Expose standard input controls, button family, visual surfaces, and basic status indicators to eliminate ~80% of consumer direct `shadcn` imports in forms and screens.
- **Components**:
  - `UiButton` (semantic variants: `primary`, `secondary`, `outline`, `ghost`, `destructive`)
  - `UiIconButton`
  - `UiCheckbox` / `UiCheckboxField`
  - `UiRadioGroup` / `UiRadioField`
  - `UiSwitch` / `UiSwitchField`
  - `UiSlider` / `UiSliderField`
  - `UiBadge`
  - `UiCard`
  - `UiDivider`
  - `UiProgress`
  - `UiSkeleton`
  - `UiTooltip`
  - Remediation of `UiDateRangeField` to standard `DateTimeRange`

### Encapsulation Wave 2 — Feedback, Surfaces & Overlays
- **Objective**: Encapsulate popover dialogs, toasts, drawers, avatars, tabs, breadcrumbs, and presentation tables.
- **Components**:
  - `showUiToast`
  - `showUiDialog`
  - `showUiDrawer`
  - `UiAvatar`
  - `UiAlert`
  - `UiTabs` (presentation only)
  - `UiBreadcrumb`
  - `UiPagination` (presentation only)
  - `UiAccordion`
  - `UiTable` (presentation table composition)

### Encapsulation Wave 3 — Navigation Presentation & Setup Workflows
- **Objective**: Encapsulate navigation shell presentation, steppers, and OTP verification fields.
- **Components**:
  - `UiSidebar`
  - `UiNavigationBar`
  - `UiStepper`
  - `UiOtpField`

### Encapsulation Wave 4 — Advanced Interaction & Desktop Layout
- **Objective**: Encapsulate resizable split panes, drag-to-reorder lists, tree views, and file inputs.
- **Components**:
  - `UiResizable`
  - `UiSortable`
  - `UiTree`
  - `UiFileField`

### Encapsulation Wave 5 — Advanced Navigation & Search
- **Objective**: Encapsulate command palette search and shortcut presentation.
- **Components**:
  - `UiCommandPalette`
  - `UiKeyboardShortcut`
