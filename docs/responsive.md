# Responsive composition

`UiResponsive` receives the immediate parent's width through `LayoutBuilder`.
Its callback receives that width and the structural tier:

| Tier | Width |
| --- | --- |
| compact | less than 600 |
| medium | 600 through less than 1000 |
| expanded | 1000 through less than 1440 |
| wide | at least 1440 |

The mandatory test creates a 1920-pixel window and a 420-pixel nested host and
asserts width 420 and compact. No `MediaQuery` screen-width fallback exists.
Unbounded horizontal hosts cause a diagnostic FlutterError; callers must supply
a horizontal constraint. Unbounded vertical space is supported.

## Phase 04 Composition Responsive Laws
- **UiContent**: Applies optional `maxWidth` constraints (default 960) under parent constraints without screen width dependency.
- **UiSection**: Headers use `Wrap` between title/description block and trailing action when local space is constrained (<200px header width).
- **UiActionGroup**: Action items wrap naturally based on available local width (`Wrap` with `runSpacing` & `spacing`), keeping buttons at minimum 48px target size.
- **UiEmptyState & UiErrorState**: Center content up to `maxContentWidth` (default 400) under local constraints.

`UiFormLayout` chooses columns from local available width, `contentGap` and scaled
`formColumnMinWidth`, capped by `maxColumns` (default two). It uses `Wrap` with natural
child heights. At width 960 it uses two columns at 100% and 150%, and one at 200%.
At width 420 it uses one column. Directionality controls horizontal start order.
No component uses page-specific `isMobile` decisions.
