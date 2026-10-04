# NEXABIZ UI — PHASE 01 / STEP 03
## Select & MultiSelect End-to-End Interaction

### ROLE

You are a Principal Flutter Engineer specializing in widget interaction, overlays, keyboard navigation, accessibility, and regression testing.

**MODE: AUDIT → REPRODUCE → TARGETED FIX → VERIFY**

Work exclusively on the active NexaBiz UI package.

Do not assume that the popup implementation is defective merely because an earlier test harness could not activate an option.

### 1. Inspect the implementation

Read the actual source and existing tests for:

- UiSelectField
- UiMultiSelectField
- Their shared field infrastructure
- The resolved shadcn_flutter 0.0.53 Select implementation
- SelectPopup, SelectGroup, SelectItemList and SelectItemButton
- Relevant overlay and focus-management code

Inspect the upstream usage examples to establish the correct component composition.

### 2. Build real interaction tests

Create widget tests that exercise the actual UI rather than invoking component callbacks directly.

Verify:

1. Opening the dropdown through its visible trigger.
2. Selecting an item through an actual pointer tap.
3. Displaying the selected value.
4. Emitting the expected callback exactly once.
5. Closing or retaining the popup according to the intended interaction.
6. Selecting and deselecting multiple items.
7. Preserving existing selections.
8. Disabled and read-only behavior.
9. Keyboard navigation and focus.
10. Escape and outside-tap behavior.
11. RTL and LTR interaction.
12. Parent value updates after selection.

Ensure the widget test environment supplies the required application, theme, overlay and localization infrastructure.

Do not substitute direct callback invocation for actual pointer-interaction tests.

### 3. Establish the root cause

Run the tests against the current implementation before changing production code.

If an interaction fails, determine whether the cause is:

- Incorrect production widget composition.
- Missing upstream popup context.
- Incorrect overlay configuration.
- Gesture interception.
- Focus handling.
- An incomplete or incorrect test harness.

Record evidence for each conclusion.

If production behavior is correct, do not introduce an unnecessary fix.

### 4. Implement confirmed fixes

Correct only demonstrated production defects.

Preserve:

- Existing public constructors and exports.
- The state synchronization established in Step 02.
- Caller-owned collection immutability.
- RTL support.
- Accessibility.
- Existing visual design.

Do not introduce new dependencies or redesign the public API.

Avoid unnecessary widget rebuilds and duplicate callbacks.

### 5. Verify regression safety

Execute:

- Dart formatting verification.
- Flutter static analysis.
- All new interaction tests.
- Step 02 state-contract tests.
- Step 01 date-range interaction tests.
- The complete package test suite.
- Workspace architecture tests.
- Workbench tests.

Report actual results. Do not claim success for tests that were not executed.

### 6. Required report

Create:

docs/audits/phase_01_step_03_result.md

Include:

- Inspected source files.
- Confirmed upstream composition requirements.
- Pre-fix interaction results.
- Root causes.
- Production changes, if required.
- Post-fix results.
- Remaining interaction and accessibility risks.
- Git diff summary.

Do not weaken or remove existing tests.

Do not start Step 04 automatically.