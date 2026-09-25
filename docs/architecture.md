# NexaBiz UI Foundation Architecture

The root application is the Foundation Workbench (`lib/main.dart`). It consumes the `nexabiz_ui` package through its public entrypoint and uses `shadcn_flutter` directly for application setup and standard controls.

```text
lib/main.dart                       external Workbench consumer & Page Composition Lab
packages/nexabiz_ui/lib/
  nexabiz_ui.dart                   reviewed public contracts (21 exported symbols)
  src/foundation/                   tokens, typography, local responsiveness
  src/composition/                  bounded content, sections, action groups, empty & error states
  src/fields/                       field shell, text, number, select, multi-select, autocomplete, date, date range
  src/forms/                        form layout and span specifications
  src/interaction/                  confirmation dialog contract
packages/nexabiz_ui_legacy/         immutable reference, excluded from active workspace tooling
test/architecture/                 workspace boundary guards G1–G14
packages/nexabiz_ui/test/           package behavior, field, form, overlay, and page composition tests
```

## Layer Structure

```text
shadcn_flutter (0.0.53)
       ↓
Foundation (Tokens, Typography, Responsive, Accessibility)
       ↓
Core Composition (UiContent, UiSection, UiActionGroup, UiEmptyState, UiErrorState)
       ↓
Fields & Forms (UiFieldShell, UiTextField, UiFormLayout, UiFormSpan, Field Suite)
       ↓
Interaction Contracts (showUiConfirmationDialog)
       ↓
Application Host Layer (Scaffold, AppBar, Router, Page Composition via Primitives)
```

## Definitive Dependency Law

```text
Consumer / Application
        ↓
    nexabiz_ui
        ↓
 shadcn_flutter (0.0.53)
        ↓
     Flutter
```

Consumer applications MUST NOT depend on `shadcn_flutter` UI APIs directly for supported design-system components. `nexabiz_ui` acts as the single UI design-system API surface for application developers, internally using `shadcn_flutter 0.0.53` as its visual implementation engine.

Public exports are strictly governed by G1–G14 architecture boundary guards.

