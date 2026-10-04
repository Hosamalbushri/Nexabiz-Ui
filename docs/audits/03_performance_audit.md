# Performance Audit and Benchmark Specification

## Certification status

Performance is **not certified**. No profile-mode benchmark target, integration test, DevTools trace, stable device/browser runner, frame timing capture, memory capture, or rebuild instrumentation exists in the repository. This audit makes no invented latency, FPS, allocation or memory claim.

Source inspection identifies likely scaling behavior:

- Autocomplete: full field `setState` for every controller notification and synchronous O(n) filtering with lowercase/string/list allocations (`autocomplete_field.dart:57,75-95`).
- Autocomplete overlay: upstream uses lazy `ListView.builder`, which is positive, but receives a newly filtered list and reconciles it after widget updates (`autocomplete.dart:334-451` in shadcn 0.0.53).
- Select/MultiSelect: package eagerly maps all options to a `SelectGroup`; upstream group uses `Column`, so popup construction is O(n) elements (`select_field.dart:89-97`, `multi_select_field.dart:91-100`, upstream `select.dart:643-670`).
- MultiSelect trigger: one chip widget per selected item in a `Wrap`; layout cost scales with selection size (upstream `select.dart:1584-1597`).
- Forms: one `LayoutBuilder` for the form plus normal widget build/layout per child; the existing 25-field test is a no-throw smoke test, not timing evidence.

## Required benchmark harness

Create in a future implementation phase (not Phase 00):

- Flutter `integration_test` or dedicated benchmark app, run in **profile** mode.
- Fixed physical device and at least one representative desktop/web target; record CPU, OS, renderer, refresh rate and build SHA.
- `FrameTiming` capture for build/raster durations; report p50/p90/p99 and missed-frame count against device refresh budget.
- Timeline spans around filtering, popup construction and open/close transitions.
- Rebuild counters for field shell, input, overlay, and option rows.
- VM/DevTools allocation and retained-memory snapshots before/after repeated open-close cycles.
- Warm-up phase and at least 30 measured iterations; publish raw samples and harness source.

Debug widget tests may verify counts and functional invariants but must not be used for end-user timing thresholds.

## Dataset matrix

Run every applicable interaction with 10, 100, 1,000, and 10,000 suggestions/options. Use deterministic labels with three distributions:

1. short ASCII labels (`Item 00001`);
2. long localized labels (80–120 code points, Arabic and English);
3. adversarial match distribution: no matches, all matches, and late substring matches.

For MultiSelect, measure 0, 10, 100 and 1,000 selected values where the option count permits it. A 10,000-item eager plain select may be rejected by design after the baseline confirms its cost; it still needs one baseline run to justify the threshold.

## Scenario matrix

| Scenario | Operations | Primary observations |
|---|---|---|
| Keyboard input | focus, type 10 characters, cursor move, select/composition change, backspace | input latency, rebuilds, filter spans, allocations |
| Rapid typing | 10–15 key events/sec and paste | stale overlays, dropped frames, work cancellation |
| Field focus | Tab/Shift-Tab through small and large forms | focus latency, unexpected rebuilds |
| Dropdown open | cold and warm open for Select/MultiSelect/Autocomplete | time to first visible overlay, element count, peak allocation |
| Dropdown close | Escape, outside tap, select item; repeat 50 cycles | frame time, retained objects/overlays, focus restoration |
| Filtering | prefix/substring/no match/all match | CPU time and result latency by dataset size |
| Selection | first/middle/last item; MultiSelect toggle burst | callback-to-visual latency, popup rebuild extent |
| Overlay rendering | scroll from first to last result | lazy creation, raster/build p99, semantics cost |
| Forms | 5-field “small”; 25-, 50-, and 100-field “large” | initial build/layout and edit isolation |

Cross every scenario with:

- LTR and RTL;
- text scale 1.0, 1.5 and 2.0;
- local host widths 320, 420 and 960 logical pixels;
- enabled/read-only where interaction is relevant;
- light and dark only if traces show theme-dependent cost.

## Functional assertions within benchmarks

- Exactly one logical value callback per accepted user change.
- Selection-only controller changes do not re-filter autocomplete.
- External parent value replacement is visible before the next interaction.
- Disabled controls do not open overlays.
- Overlay focus returns to trigger on close.
- No stale result list is shown after rapid input.
- No horizontal overflow or clipped semantic label in the matrix.

## Proposed acceptance criteria process

Do not set numerical gates until the baseline is captured on named hardware. After baseline:

1. Define the frame budget from the target refresh rate.
2. Set p90/p99 interaction budgets and maximum missed-frame count with product owners.
3. Set maximum created option elements for lazy lists (proportional to viewport, not total n).
4. Set a no-growth retained-memory threshold across 50 open/close cycles, accounting for normal caches.
5. Compare remediations against the same locked harness/device, publishing raw and summarized results.

## Missing prerequisites

- No benchmark code or benchmark-specific target.
- No approved target devices/browsers or performance budgets.
- No profile-mode automation or trace-processing scripts.
- No representative production label distributions/locales.
- No decision on maximum supported option/selection count.

Until those are supplied and measurements executed, findings F06/F07 remain source-confirmed design limitations with unquantified runtime impact.

