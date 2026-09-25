# NexaBiz UI Public API Plan (`docs/shadcn_public_api_plan.md`)

## 1. Overview
This document specifies the exact API design principles, parameter filtering rules, and proposed public symbols for encapsulating `shadcn_flutter 0.0.53` inside `nexabiz_ui`.

## 2. API Design Principles
1. **NexaBiz UI Vocabulary First**: Public contracts represent business design-system concepts (`UiButton`, `UiCard`, `UiBadge`), not mechanical `shadcn` wrappers with `Ui` prefixes.
2. **Zero Upstream Type Leakage**: No `shadcn` enums, controllers, or visual option classes appear in public signatures (`0` leaked types target).
3. **Controlled API Size**: Cohesive component families with semantic enum parameters (e.g. `UiButton` + `UiButtonVariant`) preferred over multiplying classes (`UiPrimaryButton`, `UiOutlineButton`, `UiGhostButton`).
4. **Parameter Classification**: Upstream parameters are strictly evaluated and classified before exposure:
   - `REQUIRED`: Essential for functional usage (`onPressed`, `child`, `value`, `onChanged`).
   - `USEFUL`: Standard customization (`enabled`, `padding`, `icon`).
   - `INTERNAL`: Implementation details hidden inside `nexabiz_ui`.
   - `TOO_IMPLEMENTATION_SPECIFIC`: Upstream enums or visual flags omitted.
   - `DEFER`: Advanced options deferred until caller demand is proven.

---

## 3. Proposed Component Contracts (By Family)

### A. Buttons & Actions (`UiButton`, `UiIconButton`)
- **Symbol**: `UiButton`
  ```dart
  enum UiButtonVariant { primary, secondary, outline, ghost, destructive }
  enum UiButtonSize { small, medium, large }

  class UiButton extends StatelessWidget {
    const UiButton({
      super.key,
      required this.onPressed,
      required this.child,
      this.variant = UiButtonVariant.primary,
      this.size = UiButtonSize.medium,
      this.icon,
      this.enabled = true,
    });
    ...
  }
  ```
- **Rationale**: Single cohesive class with `UiButtonVariant` enum provides superior discoverability, smaller public API footprint, and complete isolation from `shadcn` button implementations.

### B. Basic Inputs (`UiCheckbox`, `UiRadioGroup`, `UiSwitch`, `UiSlider`)
- **`UiCheckbox`**:
  ```dart
  class UiCheckbox extends StatelessWidget {
    const UiCheckbox({
      super.key,
      required this.value,
      required this.onChanged,
      this.enabled = true,
      this.label,
    });
  }
  ```
- **`UiRadioGroup<T>`**:
  ```dart
  class UiRadioGroup<T> extends StatelessWidget {
    const UiRadioGroup({
      super.key,
      required this.value,
      required this.onChanged,
      required this.items,
      this.enabled = true,
    });
  }
  ```
- **`UiSwitch`**:
  ```dart
  class UiSwitch extends StatelessWidget {
    const UiSwitch({
      super.key,
      required this.value,
      required this.onChanged,
      this.enabled = true,
      this.label,
    });
  }
  ```
- **`UiSlider`**:
  ```dart
  class UiSlider extends StatelessWidget {
    const UiSlider({
      super.key,
      required this.value,
      required this.onChanged,
      this.min = 0.0,
      this.max = 1.0,
      this.divisions,
      this.enabled = true,
    });
  }
  ```

### C. Feedback & Indicators (`UiBadge`, `UiProgress`, `UiSkeleton`, `UiAlert`, `showUiToast`, `UiTooltip`)
- **`UiBadge`**:
  ```dart
  enum UiBadgeVariant { primary, secondary, outline, destructive }
  class UiBadge extends StatelessWidget {
    const UiBadge({
      super.key,
      required this.child,
      this.variant = UiBadgeVariant.primary,
    });
  }
  ```
- **`UiProgress`**:
  ```dart
  class UiProgress extends StatelessWidget {
    const UiProgress({
      super.key,
      this.value, // null = indeterminate
    });
  }
  ```
- **`UiSkeleton`**:
  ```dart
  class UiSkeleton extends StatelessWidget {
    const UiSkeleton({
      super.key,
      required this.child,
      this.loading = true,
    });
  }
  ```
- **`UiAlert`**:
  ```dart
  enum UiAlertVariant { info, success, warning, destructive }
  class UiAlert extends StatelessWidget {
    const UiAlert({
      super.key,
      required this.title,
      this.description,
      this.variant = UiAlertVariant.info,
    });
  }
  ```
- **`showUiToast`**:
  ```dart
  void showUiToast({
    required BuildContext context,
    required String title,
    String? description,
  });
  ```

### D. Surface & Layout (`UiCard`, `UiDivider`)
- **`UiCard`**:
  ```dart
  class UiCard extends StatelessWidget {
    const UiCard({
      super.key,
      required this.child,
      this.padding,
    });
  }
  ```
- **`UiDivider`**:
  ```dart
  class UiDivider extends StatelessWidget {
    const UiDivider({
      super.key,
      this.axis = Axis.horizontal,
    });
  }
  ```

### E. App Bootstrap (`UiApp`)
- **`UiApp`**:
  ```dart
  class UiApp extends StatelessWidget {
    const UiApp({
      super.key,
      required this.home,
      this.title = '',
      this.locale,
      this.supportedLocales = const [Locale('en'), Locale('ar')],
    });
  }
  ```
