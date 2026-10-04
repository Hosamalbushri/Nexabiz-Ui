# Phase 02 / Step 02-P — Isolated action-control performance investigation

**Recommendation: CONDITIONAL PASS for Step 02-P investigation; no production optimization approved by the evidence.** The earlier mixed benchmark overstated what could be attributed to a single control. Warm Android full-frame UI spans still exceed the planning document's 2 ms *atomic-control* target, but these spans include framework layout/paint and the host tree, so they do not establish a component-local defect. No Step 03 work was started.

## Scope and reproduction

Inspected the actual `UiButton`, `UiIconButton`, and `UiSpinner` source, the original `benchmark/action_controls_profile.dart`, the Step 02 implementation report, `quality_and_performance_gates.md`, Phase 01 certification, and pinned shadcn_flutter 0.0.53 `Button`, `Clickable`, `Tooltip`, and `CircularProgressIndicator` source. The previous working tree, including the unrelated untracked `nexabiz_ui.tar.xz`, was preserved. No production file, dependency, upstream source, existing test, or public contract was changed.

The new diagnostic entrypoint is `packages/nexabiz_ui/benchmark/action_controls_isolated_profile.dart`. From the workspace root, run each of these on `R5CN219FC7T` and separately on `linux`:

```text
flutter run --profile --no-pub --dart-define=BENCH_MODE=quiet -d DEVICE -t packages/nexabiz_ui/benchmark/action_controls_isolated_profile.dart
flutter run --profile --no-pub --dart-define=BENCH_MODE=animated -d DEVICE -t packages/nexabiz_ui/benchmark/action_controls_isolated_profile.dart
flutter run --profile --no-pub --dart-define=BENCH_MODE=cold -d DEVICE -t packages/nexabiz_ui/benchmark/action_controls_isolated_profile.dart
```

`DEVICE` was `R5CN219FC7T` (physical Samsung SM-G986U, Android 13/API 33, ARM64, Impeller) or `linux` (Linux x64). Flutter was 3.44.4 / Dart 3.12.2. The five required scenarios each mount independently: button pointer, icon pointer, loading transition, spinner insertion, and unchanged-value parent/button rebuild. A sixth diagnostic checks icon pointer activation with a tooltip wrapper. For every warm scenario/environment, iterations 0–1 are excluded warm-ups and iterations 2–11 are the **10 measured samples**. The screen is unmounted between scenarios; a 250 ms idle window after teardown recorded **zero frames in all 24 cases**. The quiet environment has no unrelated spinner. The animated environment deliberately mounts one background `UiSpinner` to measure interference without altering production behavior. Cold mode records one first-mount sample per component, separately from warm distributions.

Pointer actions inject real Flutter pointer events through `GestureBinding`, hit-testing the visible control; callback counts are checked. This excludes OS touch-controller/input-delivery latency and is not a physical-finger experiment. `TimelineTask` brackets each action through its first frame. `FrameTiming` callbacks are flushed for 250 ms before and after attribution because the engine batches them; the first implementation used 65 ms and produced zero-frame false readings, so **those preliminary readings were discarded**. Wall time ends at the first `endOfFrame`; it includes waiting for vsync. The table's “UI” column is the **maximum `FrameTiming.buildDuration` in the 250 ms window**—a full UI-thread frame span, not an isolated `UiButton.build` stopwatch. “Raster” is the maximum raster duration. Continuous animation creates multiple frames in one window. Values are milliseconds in **min / median / mean / max / sample standard deviation** order.

## Warm profile distributions — Android (10 samples per row)

| Environment / scenario | Wall to frame | Max UI span | Max raster span | Frames/window, median (range) |
| --- | --- | --- | --- | --- |
| Quiet / button pointer | 4.63 / 25.21 / 22.89 / 28.64 / 7.00 | 0.77 / 3.38 / 2.79 / 3.47 / 1.02 | 1.27 / 2.16 / 2.70 / 9.13 / 2.29 | 1 (1–1) |
| Quiet / icon pointer | 6.90 / 24.37 / 23.42 / 31.29 / 6.45 | 1.32 / 3.07 / 2.77 / 3.65 / 0.91 | 1.81 / 2.11 / 2.30 / 3.15 / 0.46 | 1 (1–1) |
| Quiet / loading transition | 10.94 / 17.74 / 18.79 / 33.52 / 6.28 | 4.60 / 8.17 / 7.59 / 9.19 / 1.64 | 1.88 / 2.36 / 2.44 / 3.19 / 0.48 | 14 (14–14) |
| Quiet / spinner insertion | 13.36 / 16.70 / 17.86 / 32.14 / 5.27 | 1.81 / 5.60 / 4.86 / 6.98 / 1.56 | 1.82 / 2.54 / 2.53 / 3.34 / 0.52 | 14 (13–14) |
| Quiet / button rebuild | 9.96 / 23.36 / 21.45 / 29.08 / 6.09 | 3.83 / 4.75 / 4.74 / 5.43 / 0.47 | 1.95 / 2.19 / 2.35 / 3.19 / 0.45 | 1 (1–1) |
| Quiet / icon with tooltip, pointer | 21.55 / 25.25 / 25.40 / 29.56 / 2.18 | 2.32 / 3.15 / 3.16 / 3.97 / 0.48 | 1.86 / 2.20 / 2.27 / 3.46 / 0.46 | 1 (1–1) |
| Animated / button pointer | 8.49 / 11.33 / 11.60 / 14.44 / 1.84 | 1.61 / 3.93 / 3.62 / 4.82 / 1.09 | 2.02 / 2.58 / 2.75 / 3.95 / 0.63 | 14 (14–21) |
| Animated / icon pointer | 9.67 / 12.38 / 12.09 / 14.41 / 1.62 | 1.54 / 3.62 / 3.36 / 5.49 / 1.43 | 2.03 / 2.33 / 2.43 / 3.08 / 0.39 | 14 (14–21) |
| Animated / loading transition | 12.47 / 16.26 / 16.61 / 22.28 / 2.77 | 5.47 / 8.67 / 8.34 / 10.14 / 1.47 | 1.81 / 2.49 / 2.50 / 3.23 / 0.58 | 14 (13–21) |
| Animated / spinner insertion | 14.05 / 16.22 / 16.96 / 21.84 / 2.62 | 4.02 / 5.94 / 5.78 / 6.76 / 0.88 | 1.87 / 2.77 / 2.77 / 3.60 / 0.49 | 14 (14–21) |
| Animated / button rebuild | 9.55 / 11.51 / 11.56 / 14.28 / 1.50 | 3.99 / 5.00 / 4.92 / 5.48 / 0.45 | 2.13 / 2.67 / 2.63 / 3.37 / 0.40 | 14 (14–21) |
| Animated / icon with tooltip, pointer | 10.91 / 13.57 / 13.55 / 16.54 / 1.58 | 3.54 / 4.08 / 4.18 / 5.41 / 0.54 | 1.97 / 3.01 / 2.91 / 4.13 / 0.63 | 14 (13–21) |

## Warm profile distributions — Linux (10 samples per row)

| Environment / scenario | Wall to frame | Max UI span | Max raster span | Frames/window, median (range) |
| --- | --- | --- | --- | --- |
| Quiet / button pointer | 10.49 / 12.59 / 12.50 / 13.84 / 1.08 | 0.35 / 0.48 / 0.70 / 1.69 / 0.43 | 0.32 / 0.65 / 0.67 / 1.06 / 0.26 | 1 (1–1) |
| Quiet / icon pointer | 11.45 / 12.75 / 12.77 / 14.12 / 0.78 | 0.73 / 0.81 / 0.82 / 0.98 / 0.07 | 0.75 / 0.83 / 0.87 / 1.10 / 0.11 | 1 (1–1) |
| Quiet / loading transition | 11.11 / 16.08 / 15.68 / 17.67 / 1.99 | 1.27 / 2.10 / 2.10 / 3.10 / 0.48 | 0.99 / 1.18 / 1.19 / 1.62 / 0.17 | 14 (13–16) |
| Quiet / spinner insertion | 14.59 / 15.55 / 15.57 / 16.48 / 0.59 | 0.84 / 1.21 / 1.23 / 1.73 / 0.27 | 0.75 / 1.01 / 1.00 / 1.20 / 0.13 | 14 (13–14) |
| Quiet / button rebuild | 11.92 / 12.98 / 12.80 / 13.44 / 0.51 | 0.54 / 0.88 / 0.88 / 1.06 / 0.14 | 0.68 / 1.03 / 1.01 / 1.28 / 0.18 | 1 (1–1) |
| Quiet / icon with tooltip, pointer | 11.61 / 13.04 / 12.93 / 13.76 / 0.64 | 0.62 / 0.77 / 0.75 / 0.83 / 0.06 | 0.74 / 0.79 / 0.84 / 1.10 / 0.12 | 1 (1–1) |
| Animated / button pointer | 6.50 / 10.44 / 10.33 / 12.32 / 1.65 | 0.54 / 0.84 / 0.91 / 1.65 / 0.34 | 0.61 / 0.96 / 1.11 / 1.90 / 0.39 | 14 (13–21) |
| Animated / icon pointer | 6.57 / 8.84 / 9.42 / 11.82 / 1.59 | 0.89 / 1.28 / 1.29 / 1.59 / 0.21 | 0.76 / 1.12 / 1.15 / 1.70 / 0.25 | 14 (13–21) |
| Animated / loading transition | 11.33 / 12.91 / 12.88 / 15.16 / 1.29 | 0.93 / 1.69 / 1.85 / 2.83 / 0.59 | 0.65 / 1.10 / 1.06 / 1.49 / 0.25 | 14 (13–20) |
| Animated / spinner insertion | 8.16 / 12.08 / 11.76 / 13.33 / 1.62 | 0.79 / 1.76 / 1.69 / 2.20 / 0.48 | 0.96 / 1.22 / 1.24 / 1.58 / 0.21 | 17 (13–21) |
| Animated / button rebuild | 7.82 / 9.15 / 9.27 / 11.78 / 1.21 | 0.84 / 1.28 / 1.29 / 1.77 / 0.35 | 0.76 / 1.09 / 1.16 / 1.72 / 0.30 | 14 (13–21) |
| Animated / icon with tooltip, pointer | 6.17 / 8.80 / 8.81 / 11.51 / 1.39 | 0.86 / 1.21 / 1.22 / 1.69 / 0.26 | 0.89 / 1.18 / 1.17 / 1.49 / 0.19 | 14 (13–14) |

The single first-mount diagnostic samples are **not distributions** and were excluded above. Android first-mount UI/raster maxima (ms), in scenario order, were button 12.130/9.404, icon 28.995/4.721, loading scenario's initial *non-loading* button 2.127/2.212, spinner scenario's placeholder 2.724/2.942, button rebuild's initial button 6.121/10.197, and icon with tooltip 7.250/1.798. Linux corresponding samples were 3.841/8.316, 1.374/0.471, 1.089/0.648, 0.214/0.269, 0.677/0.389, and 0.780/0.420. Mount order, first-use effects and one sample per case prohibit generalizing these numbers; they do demonstrate why cold work must not be mixed with warm iterations.

## DevTools/VM timeline evidence and root cause

The profile VM service's `getVMTimeline` endpoint—the trace consumed by DevTools—was queried while Android runs remained attached. The trace includes `NEXA_*` async brackets, framework `BUILD`, `LAYOUT`, `PAINT`, `Frame`, and raster-thread `GPURasterizer::Draw` events. Representative uninstrumented quiet button rebuild: `NEXA_setState_rebuild` ran from timestamp 423497407602 to 423497407714 (**0.112 ms**); its frame began at 423497426067 (**about 18.5 ms after the setState start**), with top-level BUILD 0.640 ms, LAYOUT 2.522 ms (including a nested 2.450 ms BUILD), PAINT 0.753 ms, and frame end at 423497432314. This proves that wall-to-frame time is not UI-thread execution time and that top-level BUILD/LAYOUT event durations are nested, not additive independent costs.

Representative uninstrumented quiet loading transition: `setState` was 0.097 ms (423483239856–423483239953), frame start followed about 4.5 ms later, LAYOUT was 5.961 ms including a 4.944 ms nested BUILD, PAINT 0.636 ms, and raster `GPURasterizer::Draw` 1.852 ms. A separate diagnostic run enabled `debugProfileBuildsEnabled`, `debugProfileLayoutsEnabled` and `debugProfilePaintsEnabled` for **loading transition only**. One sample showed `setState` 0.056 ms, first frame beginning about 6.9 ms later, one `_CountedButton`/upstream `Button`/`Clickable` build, one `UiSpinner` build, LAYOUT 3.212 ms, PAINT 0.488 ms, and frame end about 6.4 ms after frame start. Across that instrumented trace, `AnimatedBuilder` and render-object events recur while the spinner animates; the control/parent build counter recorded **one rebuild per transition, zero extra application rebuilds**. These instrumented durations are diagnostic only because the tracing flags themselves add overhead.

**Confirmed benchmark root causes:**

1. The original mixed benchmark kept `loading == true` during its standalone-spinner sample, creating **two simultaneous indeterminate spinners** (`action_controls_profile.dart:121–130`). Its next “button build” also turned off the prior loading spinner (`:115–118`), so that case was not an unchanged-value button rebuild. Its 120 ms collection windows (`:92–103`) could mix recurring animation frames with the target action. The new quiet/animated comparison confirms this: pointer cases move from one frame/window to roughly 14–21 frames/window with an ambient spinner, even though the target control still rebuilds zero times.
2. Upstream shadcn 0.0.53 wraps its indeterminate Material `CircularProgressIndicator` in a `RepaintBoundary` (`src/components/display/circular_progress_indicator.dart:241–254`). Material's indeterminate progress animation schedules ongoing frames as designed. `UiButton` adds one such spinner only when loading (`button.dart:183–199`), and `UiSpinner` delegates to that primitive (`spinner.dart:25–42`). The continued frame production is expected behavior, not a leak: all post-unmount idle windows recorded zero frames.
3. Quiet Android pointer cases have median wall-to-frame times around 24–25 ms while their full UI spans are around 3 ms and callback/control-build counters are exactly 1/0 respectively. The timeline shows waiting for a scheduled frame, not a repeated button build. In the animated environment wall-to-frame medians become **lower** (about 11–12 ms) despite more frames, because a frame is already being scheduled. Thus neither the old wall figure nor the new wall figure alone is a defensible physical touch-latency claim.

No overlay opens on a pointer tap of the tested icon button. The optional tooltip wrapper showed no clear pointer-tap regression beyond run-to-run variation; its actual delayed hover-overlay animation was not separately timed. Raster maxima were usually below the 8 ms engineering target in warm runs, with one quiet Android button-pointer 9.135 ms outlier. Warm Android full-frame UI spans exceeded the 2 ms *component-build* target, but these spans include host rebuild/layout/paint and, for loading/spinner cases, animation frames. The diagnostic trace does not isolate a reproducible NexaBiz adapter hotspot that would justify changing the public behavior or replacing upstream primitives.

## Changes and verification

**Production changes:** none. **Optimization before/after comparison:** not applicable; the quiet-versus-animated tables compare benchmark environments, not a code optimization. The only new source is the isolated diagnostic benchmark. The approved API, localized semantics, callback behavior and all existing tests remain untouched. No dependencies were installed or upgraded.

| Command | Actual result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test benchmark` in `packages/nexabiz_ui` | 47 files, 0 changed; exit 0 |
| `dart format --output=none --set-exit-if-changed lib test` at workspace root | 3 files, 0 changed; exit 0 |
| `flutter analyze --no-pub` in package | No issues; exit 0 |
| `flutter analyze --no-pub` at workspace root | No issues; exit 0 |
| `flutter test --no-pub --reporter compact` in package | 176/176 passed; exit 0 |
| `flutter test --no-pub test/architecture test/workbench_test.dart` at root | 20/20 passed (16 architecture, 4 Workbench); exit 0 |
| Four warm profile commands (quiet and animated on each platform) | 12 executions per scenario/environment: 2 excluded warm-ups + 10 measured; all reported `ISO complete`; all teardown idle windows 0 frames |
| Two cold profile commands | Six first-mount samples per platform; `ISO complete` |
| Android diagnostic `--dart-define=TRACE_WIDGETS=true --dart-define=BENCH_SCENARIO=loadingTransition --dart-define=BENCH_MODE=quiet` | 12 instrumented samples, timeline inspected; not included in baseline distributions |

`git diff --stat` still shows the pre-existing Step 02 tracked changes (5 files, 71 insertions, 2 deletions); Git excludes the already-untracked Step 02 files, this new benchmark and this report from that statistic. `git diff --check` exited 0 with no whitespace errors. No uncommitted user data was deleted or committed.

## Remaining limitations and verdict

This study does not provide OS-level finger-to-photon latency, power/thermal distributions, repeated fresh-process cold samples, a full hover-overlay benchmark, or an isolated render-object microbenchmark. Android pointer wall maxima exceed 16 ms and warm UI spans exceed 2 ms in some cases, so the planning targets are **not certified**. A product-level performance certification would need multiple hardware sessions under controlled thermal/load conditions and captured end-to-end input-to-display traces. Further adapter optimization should wait for a reproducible component-local bottleneck or a user-visible jank trace; no speculative production edit was made.

**CONDITIONAL PASS:** the isolated investigation is complete and identifies benchmark contamination and frame scheduling as the principal explanations for the Step 02 figures. Functional/architecture regression gates pass. Performance certification remains open; Step 03 is not started.
