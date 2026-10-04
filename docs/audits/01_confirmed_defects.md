# Confirmed Defects and Suspected Findings

Classification vocabulary: **CONFIRMED** = demonstrated by current source/behavior; **SUSPECTED** = evidence warrants a targeted reproduction but is not conclusive; **DESIGN LIMITATION** = explicit/current design cannot satisfy the broader requirement; **NOT REPRODUCED** = tested scenario did not fail.

## Summary

| ID | Suspected area | Classification | Priority |
|---|---|---|---|
| F01 | Upstream shadcn type leakage | CONFIRMED | High |
| F02 | Direct shadcn usage in consumer code | CONFIRMED | High |
| F03 | Controlled versus uncontrolled behavior | CONFIRMED | High |
| F04 | External value synchronization | CONFIRMED | High |
| F05 | Autocomplete rebuild frequency | CONFIRMED | High |
| F06 | Autocomplete filtering performance | DESIGN LIMITATION | High at large scale |
| F07 | Select/MultiSelect performance | DESIGN LIMITATION | High at large scale |
| F08 | Numeric input/localization | CONFIRMED | High |
| F09 | Disabled/read-only consistency | CONFIRMED | High |
| F10 | Responsive layout/overflow | NOT REPRODUCED in certified widths; DESIGN LIMITATION below 200px | Medium |
| F11 | RTL/accessibility | CONFIRMED | Medium |
| F12 | Documentation inconsistencies | CONFIRMED | High (assurance risk) |
| F13 | Obsolete/unused source | CONFIRMED | Low |
| F14 | Architecture guard coverage | CONFIRMED | High |
| F15 | Dependency/upgrade risks | CONFIRMED | High |

No critical-severity production defect was confirmed. “High” here means likely contract failure, architecture violation, or severe scaling risk.

## F01 — Public upstream type leakage

**Evidence:** `packages/nexabiz_ui/lib/src/fields/date_range_field.dart:27-28` declares `shadcn.DateTimeRange? value` and `ValueChanged<shadcn.DateTimeRange?>?`. The class is exported at `lib/nexabiz_ui.dart:19`. Existing docs independently acknowledge the leak at `docs/shadcn_type_leak_audit.md:30-43`.

**Reproduction:** In a consumer importing only `package:nexabiz_ui/nexabiz_ui.dart`, attempt to construct and type a non-null range. Compilation requires a direct shadcn import.

**Impact:** Consumers are coupled to the implementation dependency and its value semantics; replacing/upgrading shadcn becomes a public breaking change.

**Remediation:** Introduce a NexaBiz-owned/standard range contract and internal bidirectional adapter. Treat removal of the current type as breaking or provide a deprecation bridge.

## F02 — Direct shadcn in consumer application

**Evidence:** `lib/main.dart:3` imports shadcn. There are 46 `shadcn.` references, beginning with app/theme setup at lines 18-24, a public range value at 70-73, scaffold/toast at 106-107, and direct controls/overlays throughout lines 263-832. `docs/architecture.md:47` says consumers must not directly depend on supported shadcn APIs, while `docs/forms.md:56-84` still recommends direct controls.

**Reproduction:** Remove the root `shadcn_flutter` dependency/import; the Workbench fails to compile on its root, theme, controls and range type.

**Impact:** The Workbench proves the current application-facing surface is not encapsulated. An upstream upgrade touches application code directly.

**Remediation:** Define only cohesive missing NexaBiz contracts, establish a narrowly documented bootstrap/theme boundary, migrate Workbench usages, then guard consumer `lib/` imports. Avoid mechanical wrappers without policy value.

## F03/F04 — “Controlled” fields are initialized, not externally controlled

**Evidence:** `UiSelectField` passes `value` as `initialValue` (`select_field.dart:71-73`); MultiSelect does the same (`multi_select_field.dart:70-72`); Date does the same (`date_field.dart:47-49`). Resolved shadcn 0.0.53 `ControlledComponentAdapter` copies `initialValue` in `initState` and does not reconcile changed `initialValue` in `didUpdateWidget` (`lib/src/components/form/control.dart:221-241` in the dependency cache). `UiNumberField` uses `initialValue` when no controller is provided (`number_field.dart:83-87`).

**Reproduction:** Pump a field with `value A`, retain its key/position, pump the same field with `value B`, and inspect the displayed value. Select, MultiSelect, Date and controllerless Number retain their internal prior state.

**Impact:** Reset, record switching, async load, undo, and server reconciliation can show stale values despite correct parent state. Public naming falsely suggests predictable caller ownership.

**Remediation:** Prefer truly value-controlled upstream primitives or internal NexaBiz controllers synchronized in `didUpdateWidget`. Specify one ownership model per constructor. Add reset/external-update tests before changing implementation.

`UiTextField` and controller-backed autocomplete/number are **NOT REPRODUCED** for this defect: their caller-owned `TextEditingController` synchronizes external edits, as tested in `vertical_slice_test.dart:264-272`. `UiDateRangeField` passes its value directly to a stateless upstream picker, so the synchronization defect is not established there.

## F05 — Autocomplete rebuilds on every controller notification

**Evidence:** `autocomplete_field.dart:57` listens to the entire `TextEditingController`; lines 75-78 call `setState` unconditionally. A controller also notifies for selection and composing-region changes, not just changed text. Each build re-filters at line 95 and rebuilds `UiFieldShell`, `AutoComplete`, and `TextField` at lines 97-126.

**Reproduction:** Attach a build counter around/subclass instrumentation in a test; change only `controller.selection`, then type rapidly. Observe a full wrapper rebuild/filter on each notification, including selection-only updates.

**Impact:** Avoidable main-isolate work and overlay suggestion synchronization during typing; cost multiplies with large suggestion lists and multiple autocomplete fields.

**Remediation:** Track the last text and rebuild only when text changes; isolate suggestion computation/presentation with a listenable builder; preserve focus/selection without rebuilding the shell.

## F06 — Synchronous linear autocomplete filtering

**Evidence:** `autocomplete_field.dart:81-90` lowercases the query and every suggestion and materializes a new list on every non-empty query. Complexity is O(number of suggestions × string length), on the UI isolate. The only scale test (`autocomplete_field_test.dart:73-97`) renders 1,000 entries and records no timing.

**Reproduction:** Use the benchmark matrix in `03_performance_audit.md`, type a 10-character query rapidly against 10,000 long labels, and capture build/raster timings and allocations.

**Impact:** Plausible dropped frames and input latency. Exact severity is unmeasured, so no timing claim is made.

**Remediation:** Precompute normalized labels when the source list changes, expose a caller-supplied matcher/async source, debounce only when product semantics permit, cap/virtualize visible results, and benchmark.

## F07 — Select/MultiSelect eagerly create every option

**Evidence:** `select_field.dart:89-97` and `multi_select_field.dart:91-100` map the entire `items` list to widgets and `.toList()`. Upstream `SelectGroup` lays them in a `Column` (`select.dart:643-670`), not a lazy list. Opening the popup invokes this builder (`select.dart:1264-1288`). MultiSelect also builds all selected chips in a `Wrap` (`select.dart:1584-1597`).

**Reproduction:** Open each field at 10/100/1,000/10,000 options; record created element count, open-frame duration and memory. Toggle MultiSelect items and repeat.

**Impact:** Dropdown opening cost and memory scale linearly; 10,000 options is architecturally unsuitable even though popup height is constrained.

**Remediation:** Add searchable/lazy collection APIs, use a virtualized popup delegate/list, and document a threshold for simple eager select versus large-data picker.

## F08 — Numeric input is ASCII/dot-decimal only

**Evidence:** `number_field.dart:58-67` uses `num.tryParse`; lines 71-95 permit only `[0-9]`, `-`, and `.`. There is no locale/parser/formatter injection point. Arabic-Indic digits (`٠١٢٣`) and comma decimal separators are rejected before the consumer callback can normalize them.

**Reproduction:** Enter or paste `١٢٫٥`, `۱۲٫۵`, or `12,5`; the formatter removes/rejects locale-specific characters and `onNumberChanged` cannot emit the intended value.

**Impact:** Arabic and comma-decimal users cannot enter natural localized numbers. Consumer-owned localization is impossible through this API despite being the stated architecture.

**Remediation:** Keep localization owned by consumers by accepting a parser plus formatter list/numeric-input policy, with an ASCII default. Do not add business currency/precision rules to the foundation.

## F09 — Disabled/read-only behavior is inconsistent

**Evidence:** `UiDateRangeField` forwards `enabled/readOnly` only to `UiFieldShell` (`date_range_field.dart:39-46`) and passes an active callback whenever `readOnly == false` (`:47-49`); the underlying `DateRangePicker` has no enabled argument. Thus `enabled: false, readOnly: false` is semantically marked disabled but remains interactive. Select/MultiSelect/Date implement read-only by disabling the underlying picker (`select_field.dart:73-74`, `multi_select_field.dart:72-77`, `date_field.dart:49-50`), while Text/Number preserve enabled focus/selection and use native `readOnly` (`text_field.dart:69-70`, `number_field.dart:89-90`).

**Reproduction:** Pump each field in all four enabled/read-only combinations. Tapping disabled DateRange can still open and change. Compare focus/copy semantics of read-only text with read-only select/date.

**Impact:** A disabled field can mutate data; read-only meaning changes across field types.

**Remediation:** Fix DateRange interaction gating immediately. Then document a cross-field state matrix: disabled is non-focusable/non-interactive; read-only exposes value without mutation, with explicit focus/copy behavior where the control supports it.

## F10 — Responsive/overflow

**Observed:** Current tests passed at 280/320/420/960 widths, LTR/RTL, and up to 200% text scale. No overflow was reproduced in those matrices.

**Limitation:** `UiSection` imposes a 200px minimum width on its header text block (`section.dart:78-92`). A locally constrained host below 200px cannot honor that minimum. This is a source-confirmed extreme-width limitation, not a failure in the currently certified width range. Select uses upstream `IntrinsicWidth`, which the package guard cannot see, and large selected-chip content grows vertically without a documented bound.

**Remediation:** Add 160/200/240px targeted tests if such hosts are supported; cap the header constraint to local max width or use a layout builder. Define minimum supported component widths.

## F11 — RTL and accessibility defects

**Evidence 1:** `UiSection` wraps only string titles in `Semantics(header: true)` (`section.dart:39-46`). A supplied `titleWidget` bypasses header semantics. **CONFIRMED.**

**Evidence 2:** The Workbench's “Arabic” toggle only changes strings/direction (`lib/main.dart:58-63,132-138`) and does not set `Locale` or localization delegates. Date formatting therefore does not demonstrate Arabic localization. **CONFIRMED Workbench defect**, not a package localization ownership violation.

**Not reproduced:** Existing RTL layout, dialog focus restoration, field accessible labels, live regions and 200% scaling tests all passed. No general RTL failure was reproduced. Dropdown keyboard/semantics coverage remains insufficient and is classified SUSPECTED until tested.

**Remediation:** Always apply section header semantics regardless of string/widget title; make Workbench locale real or rename the toggle; add semantics/keyboard matrices for non-text fields.

## F12 — Documentation contradicts current implementation

Examples:

- `README.md:1` calls the repository “Phase 01” and line 10 says Phase 02 has not started, while docs claim through Phase 09.
- `docs/package_boundary.md:12-14` claims seven contracts/six exports; current barrel has 21 symbols/19 exports.
- `docs/testing.md:28-37` records Flutter 3.29.1/Dart 3.7.0 and 49 tests/G1–G7; actual is 3.44.4/3.12.2 and 103 total executions/G1–G14.
- `docs/fields.md:71-74` calls the exposed range “Standard Dart `DateTimeRange`”; source uses shadcn's type.
- `docs/phase_05_certification.md:63` claims no frame drops or memory leaks from a no-throw test with no measurements.
- `docs/phase_09_evidence.md:5-8` claims `UiKeyValue`, G15, 101 package and 18 workspace tests; no `UiKeyValue` source/export or G15 exists at this revision.
- Six ADR files and `docs/phase_03_evidence.md` are empty.

**Impact:** Historical certification cannot be trusted as current evidence; it can drive incorrect migration decisions.

**Remediation:** Label historical reports with commit/scope, generate baseline counts where possible, correct normative docs, and prohibit unmeasured performance language.

## F13 — Obsolete source

**Evidence:** Empty, non-exported, unreferenced `class UiButton {}` at `tokens.dart:19`. Searches find no use. It appears to be a placeholder for a proposed API.

**Impact:** Low runtime impact; confusing evidence for API audits and future button work.

**Remediation:** Remove during Phase 01 implementation after confirming no private import consumers; do not expand it in the tokens file.

## F14 — Architecture guards miss mandatory boundaries

**Evidence:** G2 (`boundary_test.dart:63-80`) checks only illegal NexaBiz internal/legacy imports and permits shadcn. G3 (`:82-114`) compares export text but not public signature types. No guard covers external state synchronization, numeric locale injection, disabled parity, or performance. Source substring guards G7–G14 are intentionally narrow.

**Impact:** All guards pass while F01, F02, F03/F04 and F09 remain present.

**Remediation:** Add analyzer/API-based type-boundary checks and explicit consumer import rules first; then behavioral contract tests. Keep lightweight source guards as supplementary tripwires.

## F15 — Dependency and upgrade risk

**Evidence:** Exact `shadcn_flutter: 0.0.53` pin appears in root and package manifests. As of audit date, official pub.dev lists 0.0.55. Versions 0.0.54/0.0.55 require Flutter 3.47/Dart 3.13, while the repository uses 3.44.4/3.12.2. The official changelog documents breaking Material/Cupertino separation and dependency removals. Current 0.0.53 brings a wide transitive graph including localization, skeletonizer, country/phone, expression, cross-file and web packages.

**Impact:** The pin prevents surprise breakage but also holds known architecture/behavior and a larger graph. Upgrade requires a toolchain move and API migration, not a routine version bump.

**Remediation:** First encapsulate public/consumer coupling and add characterization tests. Then test 0.0.55 in an isolated branch with Flutter 3.47+, compare API/semantics/performance, and update deliberately. No upgrade was performed in Phase 00.

