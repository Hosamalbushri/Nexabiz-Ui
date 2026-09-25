# Fields and forms

## State and validation decision

Phase 01 uses controlled, caller-owned validation. A caller owns text controllers,
calculates error strings on submit/change, and passes them to UiTextField.
The package does not install Flutter FormState or shadcn FormController, validate
implicitly, save data, submit a transaction or own buttons.

The Workbench demonstrates this contract: an empty display name produces a
caller-owned error on Validate; entering text clears that error; Reset clears
the caller's controllers and submitted state. RequiredIndicator is localized
presentation, not an implicit validator.

## Field contract

UiFieldShell accepts label, requiredIndicator, description, control, helper and
error, plus enabled/readOnly semantics. Error replaces helper while present.
All nonempty supporting text wraps with no maxLines or fixed total height.
Only the control receives a minimum height of 48. A caller using UiFieldShell
directly must make the supplied control's enabled/readOnly behavior match.

UiTextField requires a caller-owned TextEditingController. Optional FocusNode is
also caller-owned. It forwards changes/submission, enabled/readOnly and input
action to one native single-line shadcn TextField. It adds no controller lifetime
or validation state of its own.

## Composition

UiFormLayout owns columns and gaps only. It has no scroll view, Expanded, actions
or bounded-height requirement. The Workbench owns one SingleChildScrollView.
Labels and errors may be taller than adjacent fields.

Future: other inputs, form engine adapters and more advanced layout require a
new approved contract. They are not part of this package yet.
