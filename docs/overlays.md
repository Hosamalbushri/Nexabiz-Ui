# Overlay & Interaction Architecture Normative Contract

## 1. Direct `shadcn_flutter` Overlay Policy
`nexabiz_ui` does NOT create a parallel overlay abstraction layer or hide `shadcn_flutter`'s native overlay primitives.
Consumers and application components directly utilize `shadcn_flutter` overlay APIs:
* **Dialogs**: `const shadcn.DialogOverlayHandler().show<T>()` / `shadcn.AlertDialog`
* **Drawers / Sheets**: `shadcn.openDrawerOverlay()`
* **Popovers**: `const shadcn.PopoverOverlayHandler().show()`
* **Toasts**: `shadcn.showToast()` (requires `shadcn.ToastLayer` at root scaffold level)

---

## 2. Reusable Composition Exemption (`showUiConfirmationDialog`)
The **ONLY** public interaction helper function exposed by `nexabiz_ui` is `showUiConfirmationDialog`.

### Signature
```dart
Future<bool?> showUiConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
  bool barrierDismissible = true,
});
```

### Key Architectural Requirements
1. **Caller-Owned Localization**: `confirmLabel` and `cancelLabel` are `required String` parameters. The package owns ZERO hardcoded user-visible strings.
2. **Deterministic Result Contract**:
   * `true`: Explicit user confirmation (primary or destructive button clicked).
   * `false`: Explicit user cancellation (cancel button clicked).
   * `null`: Implicit non-explicit dismissal (barrier tap or Escape key press).
3. **Barrier Policy**:
   * `barrierDismissible: true` -> Barrier tap closes dialog and resolves to `null`.
   * `barrierDismissible: false` -> Barrier tap is ignored; modal remains open until explicit user action.
4. **Focus Restoration**: Focus is captured by the modal dialog on launch and restored to the launching focus node upon closure.

---

## 3. Architecture Governance (Guard G13)
Guard **G13** is a source-level architecture guard that prohibits:
* Stored static `BuildContext` singletons (`static BuildContext`)
* Global focus hacks (`FocusManager.instance.primaryFocus`)
* Global `NavigatorState` keys (`GlobalKey<NavigatorState>`)
