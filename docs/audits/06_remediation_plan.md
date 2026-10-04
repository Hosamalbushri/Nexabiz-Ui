# Remediation Plan

No implementation is authorized by Phase 00. This plan orders confirmed defects before enhancements and preserves consumer localization, local constraints, generic ownership, and backward compatibility unless a breaking change is explicitly approved.

## Dependency sequence

```text
Characterization tests + architecture guards
  -> state/disabled correctness
  -> public type boundary + consumer encapsulation
  -> localized numeric extension
  -> scalable collection APIs
  -> measured performance work
  -> optional shadcn/toolchain upgrade
  -> documentation recertification
```

## P0 — Make the contracts testable and enforceable

1. Add failing characterization tests for external value replacement, all enabled/read-only combinations, localized numeric entry, and custom-title semantics.
2. Add an exported-signature guard rejecting shadcn types and a consumer-import guard for `lib/`, with an explicit bootstrap exception only if architecture approves one.
3. Add dropdown interaction/semantics tests before refactoring.

Dependencies: none.  
Regression risk: low; tests may expose additional upstream behavior.  
Acceptance: tests demonstrably fail on current defects and guard messages identify exact symbol/file.

## P1 — Correct state ownership and disabled behavior

1. Fix `UiDateRangeField(enabled: false)` so it cannot open/change.
2. Make Select, MultiSelect and Date truly synchronize from current external values, or rename/deprecate value constructors as uncontrolled `initialValue` contracts.
3. Resolve controllerless Number ambiguity.
4. Specify consistent disabled/read-only focus, mutation and semantics behavior across every field.

Dependencies: P0 characterization.  
Breaking changes: behavior may change for consumers relying on internal state; constructor renaming/removal is source-breaking.  
Regression risks: duplicate callbacks, cursor/focus loss, popup closure, reset loops, equality/list identity.  
Acceptance: external resets/record switches display immediately; one callback per user action; disabled never mutates; the state matrix passes in LTR/RTL and 1.0/1.5/2.0 scale.

## P2 — Remove upstream leakage and application coupling

1. Replace public `shadcn.DateTimeRange` with an upstream-neutral range contract and internal conversion.
2. Inventory the 20 direct Workbench shadcn symbols and classify each as: bootstrap boundary, existing NexaBiz contract, justified new adapter, or application composition.
3. Implement only adapters that carry stable semantic/accessibility/theme value; migrate supported controls and remove the root direct dependency when feasible.

Dependencies: P0 guards; coordinate range migration with P1 date state work.  
Breaking changes: range type replacement is breaking unless bridged/deprecated; eliminating direct shadcn can alter visuals/semantics.  
Regression risks: date equality/time handling, themes, overlays, focus, action variants.  
Acceptance: public API contains zero shadcn types; consumer production source contains zero unapproved shadcn imports; package tests and visual/accessibility regression matrices pass.

## P3 — Enable consumer-owned numeric localization

Add a parser/formatter policy (or formatter/parser injection) while retaining the existing ASCII behavior as the compatibility default. Provide test fixtures for ASCII, Arabic-Indic, Eastern Arabic-Indic and comma-decimal input. Keep currency, rounding and business precision outside the package.

Dependencies: P0 tests; independent of P2 except public API review.  
Breaking changes: none if additive; a new default locale behavior would be breaking and is not recommended.  
Regression risks: formatter loops, cursor jumps, paste behavior, intermediate negative/decimal states.  
Acceptance: consumers can supply locale behavior without forking the widget; intermediate states remain intact; callbacks are deterministic.

## P4 — Establish scalable collection contracts

1. Optimize autocomplete rebuild isolation and normalized-label caching.
2. Add optional caller matching/async suggestion source and a result cap.
3. Add lazy/searchable select and multi-select APIs for large data; keep eager simple select for small lists with a documented threshold.
4. Ensure selected-value rendering remains bounded/useful for very large selections.

Dependencies: approved benchmark harness and captured baseline from `03_performance_audit.md`; state fixes from P1.  
Breaking changes: avoid by adding new constructors/policies; changing default matching/order is behavioral.  
Regression risks: stale async responses, focus/keyboard navigation, overlay positioning, equality and selection retention.  
Acceptance: functional benchmark assertions pass; agreed p90/p99/frame/memory budgets pass at 10/100/1,000/10,000; lazy option element count is viewport-bounded.

## P5 — Responsive and accessibility hardening

1. Preserve `header: true` semantics for `titleWidget`.
2. Decide and test minimum supported local width; remove/cap the 200px section header minimum if narrower hosts are supported.
3. Make the Workbench Arabic mode set an actual locale or label it only as RTL/Arabic-content simulation.
4. Complete semantics/keyboard tests for every dropdown/date/autocomplete state.

Dependencies: P1 state matrix; P2 control surface may change semantics.  
Breaking changes: none expected.  
Regression risks: merged/duplicate semantics, heading announcements, layout changes.  
Acceptance: screen-reader semantics snapshot/manual audit, keyboard-only flows, RTL/LTR, widths and scaling matrix all pass without overflow.

## P6 — Dependency migration (separate approval)

Evaluate shadcn 0.0.55 only after encapsulation and characterization. Use an isolated branch with Flutter >=3.47/Dart >=3.13, read the 0.0.54/0.0.55 breaking changes, compare dependency graph, run full functional/semantic/performance baselines, and document rollback. Do not combine this upgrade with unrelated component expansion.

Dependencies: P1/P2 strongly recommended.  
Breaking changes: toolchain minimum, Material/Cupertino interop, removed/reorganized APIs and packages.  
Regression risks: app bootstrap, localization, text editing, selection, overlays and dependency-provided symbols.  
Acceptance: approved toolchain; clean analyze/tests; API diff reviewed; zero direct upstream leakage; performance no worse than agreed budgets.

## P7 — Documentation and dead-code cleanup

Remove the unused `UiButton` placeholder, correct normative docs, mark historical evidence with commit/version, replace false performance claims with measured evidence, reconcile phase status/test counts, and populate or delete empty ADR placeholders according to documentation policy.

Dependencies: perform final wording after P1–P6 decisions; the dead-code removal can occur earlier.  
Breaking changes: none for exported API; verify no unsupported `src/` import consumer before deletion.  
Acceptance: documentation matches generated/current inventory and commands; all claims cite a current test or benchmark; no obsolete declaration remains.

## Recommended first implementation step

After explicit Phase 01 approval, begin with P0 plus the narrow P1 `UiDateRangeField` disabled fix. That secures reproducible failing tests and closes the only confirmed case where a control marked disabled can still mutate before broader API migration.

