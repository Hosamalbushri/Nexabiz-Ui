# Component Roadmap

## Phase 01 — Clean Foundation (PASS)
- `UiTokens`
- `UiTextRole`
- `UiResponsive`
- `UiLayoutTier`

## Phase 02 — shadcn Boundary (PASS)
- Visual authority pin: `shadcn_flutter: 0.0.53`
- Architecture guards G1–G7

## Phase 03 — Foundation Hardening (PASS)
- Structural constraint law & local-constraint responsiveness
- Comprehensive vertical slice tests

## Phase 04 — Core Composition Primitives (PASS)
- `UiContent`: Bounded, responsive content container
- `UiSection`: Structural header and content grouping with header accessibility
- `UiActionGroup`: Responsive wrap for action triggers with content-fit wrapping
- `UiEmptyState`: Standardized presentation for empty states
- `UiErrorState`: Accessible presentation for error states with live region semantics

## Phase 05 — Field System & Selection Foundation (PASS)
- `UiFieldShell`: Canonical field shell primitive
- `UiTextField`: Accessible text input wrapper over `shadcn.TextField`
- `UiNumberField`: Accessible numeric input
- `UiSelectField`: Single option popover select
- `UiMultiSelectField`: Multiple selection input
- `UiAutocompleteField`: Async/sync local filter search
- `UiDateField`: Single calendar date picker
- `UiDateRangeField`: Date range picker

## Phase 06 — Definitive Form System (PASS)
- `UiFormLayout`: Content-driven responsive grid form host
- `UiFormSpan`: Grid span metadata wrapper (`UiFormSpanType`)

## Phase 07 — Overlays & Interaction Contracts (PASS)
- `showUiConfirmationDialog`: Caller-owned localized confirmation contract

## Phase 08 — Page Composition & Application Boundary Certification (PASS)
- Forensic audit of generic page abstractions: **0 page wrappers created**
- Strict boundary certified: Application owns Scaffold/routing/state/lifecycle; `nexabiz_ui` provides generic structural composition (`UiContent`, `UiSection`, `UiActionGroup`)
- Architecture Guard G14 added
- Approved public contract count strictly maintained at **21 symbols**

## Phase 09 — Data Display Foundation (PASS)
- Candidate Decision Matrix evaluated: `UiKeyValue` implemented as presentation primitive; `UiDataTable`, `UiPagination`, `UiRowActions` certified as `DIRECT_SHADCN`.
- Standardized primitive: `UiKeyValue` for structured record detail presentation.
- Direct `shadcn_flutter` table & pagination composition certified for lists, tables, and pagination.
- Architecture Guard G15 added (prohibits data source engines and domain table contracts in `lib/src`).
- Approved public contract count expanded to **22 symbols**.

