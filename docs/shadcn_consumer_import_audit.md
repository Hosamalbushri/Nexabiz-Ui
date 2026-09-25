# Consumer Direct-Import Audit (`docs/shadcn_consumer_import_audit.md`)

## 1. Executive Summary
- **Audited Target**: Workbench application (`lib/main.dart`)
- **Direct `shadcn_flutter` Import Declarations**: 1 (`import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;`)
- **Direct `shadcn` Widget References**: 44 references across 6 component families.
- **Target Architecture State**: `0` direct `shadcn` imports in consumer application code.

---

## 2. Occurrence Breakdown by Component Family

| Component Family | Direct `shadcn` Types Referenced | Reference Count | Replacement NexaBiz API | Encapsulation Phase |
|---|---|---|---|---|
| **Buttons & Actions** | `shadcn.OutlineButton`<br>`shadcn.PrimaryButton`<br>`shadcn.SecondaryButton`<br>`shadcn.GhostButton`<br>`shadcn.DestructiveButton` | 24 | `UiButton`<br>`UiIconButton` | Encapsulation Wave 1 |
| **Selection Controls** | `shadcn.Checkbox`<br>`shadcn.RadioGroup`<br>`shadcn.RadioItem`<br>`shadcn.Switch`<br>`shadcn.Slider` | 8 | `UiCheckbox`<br>`UiRadioGroup`<br>`UiSwitch`<br>`UiSlider` | Encapsulation Wave 1 |
| **Feedback & Surface** | `shadcn.PrimaryBadge`<br>`shadcn.Tooltip`<br>`shadcn.Card` | 5 | `UiBadge`<br>`UiTooltip`<br>`UiCard` | Encapsulation Wave 1 |
| **Overlays & Dialogs** | `shadcn.ToastLayer`<br>`shadcn.AlertDialog`<br>`shadcn.Dialog` | 3 | `showUiConfirmationDialog`<br>`showUiToast`<br>`showUiDialog` | Encapsulation Wave 2 |
| **Bootstrap & Root** | `shadcn.ShadcnApp`<br>`shadcn.Scaffold` | 2 | `UiApp`<br>`UiScaffold` | Encapsulation Wave 1 |
| **Date Types** | `shadcn.DateTimeRange` | 2 | Standard Flutter `DateTimeRange` | Encapsulation Wave 1 |

---

## 3. Migration Plan
In future Encapsulation Waves (1–4), `lib/main.dart` will be systematically refactored to consume ONLY:
```dart
import 'package:nexabiz_ui/nexabiz_ui.dart';
```
all direct `shadcn` prefixes will be removed, eliminating consumer source coupling to `shadcn_flutter`.
