# Canonical Form System & Form Recipe

## 1. Overview & Architectural Boundaries

`nexabiz_ui` provides a canonical, zero-state form layout system. The foundation enforces strict architectural boundaries:
- **Zero Form State**: The foundation owns NO `FormState`, `GlobalKey<FormState>`, or validation controllers. Form state management belongs entirely to the consumer application (e.g. `flutter_form_builder`, `flutter_bloc`, `riverpod`, or native Flutter `FormState`).
- **Zero Scroll Ownership**: Form layout primitives (`UiFormLayout`, `UiFormSpan`) NEVER embed scroll widgets (`SingleChildScrollView`, `ListView`). The consumer host controls scrolling.
- **Zero Horizontal Overflow**: `UiFormLayout` resolves field spans dynamically based on local container constraints, gracefully collapsing to single-column layout on compact viewports (e.g. <= 320px).

---

## 2. Canonical Form Recipe

The normative recipe for assembling forms in `nexabiz_ui` relies on direct composition of existing primitives:

```dart
// Consumer owns Form state and scroll host
Form(
  key: formKey,
  child: SingleChildScrollView(
    child: UiContent(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Form Section
          UiSection(
            title: 'User Profile & Preferences',
            description: 'Update account details and notification settings.',
            child: UiFormLayout(
              maxColumns: 2,
              children: [
                // Standard fields (occupy 1 column)
                UiTextField(
                  label: 'Full Name',
                  controller: nameController,
                  requiredIndicator: 'Required',
                ),
                UiSelectField<String>(
                  label: 'Role',
                  value: selectedRole,
                  items: const ['Admin', 'Manager', 'User'],
                  itemLabelBuilder: (v) => v,
                  onChanged: (v) => setState(() => selectedRole = v),
                ),
                
                // Full-width span field
                UiFormSpan.full(
                  child: UiTextField(
                    label: 'Bio / Notes',
                    controller: notesController,
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),

                // Direct shadcn control integration
                shadcn.Checkbox(
                  state: agreeTerms ? CheckboxState.checked : CheckboxState.unchecked,
                  onChanged: (st) => setState(() => agreeTerms = st == CheckboxState.checked),
                  trailing: const Text('Agree to Terms'),
                ),
                
                // Custom caller field via UiFieldShell
                UiFieldShell(
                  label: 'Priority Rating',
                  control: RatingStars(value: priority),
                ),
              ],
            ),
          ),

          const SizedBox(height: UiTokens.contentGap),

          // 2. Form Actions
          UiActionGroup(
            children: [
              shadcn.PrimaryButton(
                onPressed: onSave,
                child: const Text('Save Changes'),
              ),
              shadcn.OutlineButton(
                onPressed: onCancel,
                child: const Text('Cancel'),
              ),
            ],
          ),
        ],
      ),
    ),
  ),
);
```

---

## 3. Responsive Field Spanning (`UiFormSpan`)

Fields inside `UiFormLayout` can optionally request wider spans via `UiFormSpan`:

| Span Type | Request | Behavior on Compact (1-col) | Behavior on Medium (2-col) | Behavior on Expanded (3-col) |
|---|---|---|---|---|
| `normal` | 1 Column | 1 Column | 1 Column | 1 Column |
| `wide` | 2 Columns | 1 Column | 2 Columns | 2 Columns |
| `full` | All Columns | 1 Column | 2 Columns | 3 Columns |

```dart
UiFormSpan(
  span: UiFormSpanType.full,
  child: UiTextField(label: 'Full Address', controller: controller),
);
```

---

## 4. Architecture Laws (G10–G12)

- **G10**: Prohibit `FormState`, `GlobalKey<FormState>`, or validation engines inside `nexabiz_ui` production `lib/`.
- **G11**: Prohibit scroll widgets (`SingleChildScrollView`, `ListView`, `CustomScrollView`, `ScrollController`) inside `lib/src/forms/`.
- **G12**: Prohibit top-level `Expanded` inside form layout primitives.
