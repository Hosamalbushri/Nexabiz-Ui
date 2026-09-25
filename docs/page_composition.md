# Page Composition & Application Boundary Rules

This document establishes the normative architecture boundary between generic reusable UI composition (`nexabiz_ui`) and consumer application ownership.

---

# 1. CORE ARCHITECTURAL INVARIANT

**`nexabiz_ui` MUST NEVER EXPOSE GENERIC PAGE TEMPLATE WRAPPERS.**

The foundation package provides **structural composition primitives**, NOT opinionated page layouts or application scaffolding wrappers.

```text
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION DOMAIN                       │
│  Routing (GoRouter) • State (Bloc/Provider) • Scaffold/AppBar│
│  Permissions • Feature Business Logic • Lifecycle Management │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│               NEXABIZ UI COMPOSITION LAYER                  │
│       UiContent • UiSection • UiActionGroup                 │
│       UiEmptyState • UiErrorState • UiFormLayout            │
└──────────────────────────────┬──────────────────────────────┘
                               │
                               ▼
┌─────────────────────────────────────────────────────────────┐
│                    SHADCN_FLUTTER CONTROLS                  │
│       Button • Switch • TextField • Calendar • Overlay      │
└─────────────────────────────────────────────────────────────┘
```

---

# 2. RESPONSIBILITY MATRIX

| Responsibility Domain | Owned By | Reason |
| :--- | :--- | :--- |
| `Scaffold`, `AppBar`, `Drawer`, `BottomNavigationBar` | **Application** | Application host controls layout frame, route chrome, and global navigation. |
| Page Navigation & Route Parameters | **Application** | Deep linking, URL sync, and route definitions belong to application router (`GoRouter`). |
| Data Fetching, Async State, Pagination | **Application** | Generic UI foundation must remain decoupled from state management and network SDKs. |
| Scroll Behavior (`SingleChildScrollView`, `ListView`) | **Application** | Application host defines scrolling context (e.g. slivers, nested scrolls, unconstrained views). |
| Structural Header (`title`, `description`, `trailing`) | **`UiSection`** | Standardizes semantic header hierarchy and heading level without card backgrounds. |
| Content Padding & Max Width Constraints | **`UiContent`** | Enforces consistent content margins and responsive maximum width constraints. |
| Button Layout, Alignment & Spacing | **`UiActionGroup`** | Standardizes primary/secondary button alignment and responsive button stacking. |

---

# 3. REJECTED PAGE WRAPPER MATRIX

| Proposed Class Name | Verdict | Direct Flutter / Composition Equivalent |
| :--- | :--- | :--- |
| `UiPage` | **REJECTED** | Application Scaffold host + `UiContent` |
| `UiFormPage` | **REJECTED** | Application Scaffold host + `UiContent` + `UiSection` + `Form` + `UiFormLayout` + `UiActionGroup` |
| `UiListPage` | **DEFERRED** | Application-owned list view with search/filters or future Data Display module |
| `UiDetailsPage` | **REJECTED** | Application Scaffold host + `UiContent` + `UiSection` + read-only data layout |
| `UiTablePage` | **DEFERRED** | Belongs to future dedicated Table & Data Grid phase |
| `UiDashboardPage` | **DEFERRED** | Application-owned metric grid / card layout |
| `UiSettingsPage` | **REJECTED** | Application Scaffold host + `UiContent` + `UiSection` + direct `shadcn_flutter` controls |
| `UiMasterDetailPage` | **DEFERRED** | Application router / split-pane responsive navigation |
| `UiPageHeader` | **REJECTED** | `UiSection` (supports title, description, trailing, and semantic heading level) |
| `UiPageBody` | **REJECTED** | `UiContent` (supports local constraint responsive padding) |
| `UiPageActions` | **REJECTED** | `UiActionGroup` (supports start/end alignment and responsive button wrapping) |

---

# 4. NORMATIVE COMPOSITION RECIPES

### Recipe A — Form-Style Page Composition
```dart
shadcn.Scaffold(
  child: SingleChildScrollView(
    child: UiContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          UiSection(
            title: 'Account Settings',
            description: 'Update user profile credentials.',
            child: Form(
              key: formKey,
              child: UiFormLayout(
                children: [
                  UiFormSpan(
                    span: UiFormSpanType.full,
                    child: UiTextField(
                      label: 'Display Name',
                      controller: nameController,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          UiActionGroup(
            children: [
              shadcn.PrimaryButton(
                onPressed: () => submitForm(),
                child: const Text('Save Changes'),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
```

### Recipe B — Details-Style Page Composition
```dart
shadcn.Scaffold(
  child: SingleChildScrollView(
    child: UiContent(
      child: UiSection(
        title: 'Tenant Metadata',
        description: 'Read-only organization settings.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text('Tenant Code: TN-9042'),
            Text('Status: Active'),
          ],
        ),
      ),
    ),
  ),
);
```

### Recipe C — Settings-Style Page Composition
```dart
shadcn.Scaffold(
  child: SingleChildScrollView(
    child: UiContent(
      child: UiSection(
        title: 'Preferences',
        description: 'Manage notification channels.',
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Push Notifications'),
            shadcn.Switch(
              value: enabled,
              onChanged: (val) => updatePreference(val),
            ),
          ],
        ),
      ),
    ),
  ),
);
```

---

# 5. PUBLIC CONTRACT CEILING

The approved public contract total for `nexabiz_ui` remains **21 symbols**. Zero public symbols were added in Phase 08.
