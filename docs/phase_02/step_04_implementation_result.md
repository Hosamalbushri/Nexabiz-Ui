# Phase 02 / Step 04 — form controls implementation result

**Recommendation: CONDITIONAL PASS.** The approved Step 04 controls are implemented and all automated functional/architecture gates pass. Profile-mode samples exist on Linux and physical Android, but whole-frame timings are not component-local certification, and screen-reader adjustment of a slider with a localized value requires a further public contract decision. Step 05 was not started.

## Scope and approved contracts

Implemented only `UiCheckbox`, `UiCheckboxField`, `UiSwitch`, `UiSwitchField`, `UiRadioOption<T>`, `UiRadioGroup<T>`, `UiRadioGroupField<T>`, `UiSlider`, and `UiSliderField` in the four planned `packages/nexabiz_ui/lib/src/fields/*_field.dart` files. The source is exported via the public barrel. The approved additive `String? semanticLabel` is on all four standalone controls; `String? semanticValue` is on `UiSlider`. The two field contracts match the user's approved signatures: radio has label/options/value/callback, field metadata, `bool requiredIndicator`, enabled and read-only; slider adds min/max/divisions, caller-localized `valueLabel` and `semanticValue`. The public API architecture document now records these contracts. No dependency or upstream source was changed, and no upstream type is exported.

All values are controlled by the caller. Checkbox maps `bool?` to upstream `CheckboxState` and retains the pinned checked → unchecked → indeterminate cycle. Slider maps `double` to `SliderValue.single`; invalid non-finite or reversed bounds, out-of-range values, and non-positive divisions throw `ArgumentError` rather than permitting upstream division by zero or nonsensical states. Parent rebuilds render incoming values without firing callbacks. Fields gate both upstream `enabled` and callbacks for disabled/read-only states. The field shell supplies field names, descriptions, helper/error live regions; `requiredIndicator` maps to Flutter's `Semantics.isRequired` and does **not** invent a localized required phrase or a visible text marker. `valueLabel` is visible but excluded from semantics so it cannot duplicate the independently caller-supplied `semanticValue`.

Standalone checkbox/switch/slider semantics expose caller-supplied names, state/role, and enabled status while excluding duplicate upstream subtree announcements. Radio groups expose a caller-supplied group name plus individual caller-labeled choices with selected/disabled states. If a standalone control has no `semanticLabel`, its caller must provide an appropriate named semantic context; the package does not synthesize English. The Workbench now demonstrates the four field variants and one standalone switch through the NexaBiz barrel, with English/Arabic text supplied by the application. Existing direct shadcn application-shell/feedback use is deferred to its planned later step.

## Root causes, interaction and lifecycle

The installed `shadcn_flutter 0.0.53` checkbox/switch/slider controls provide pointer/keyboard interaction and parent-value synchronization. Upstream `RadioItem` handles pointer selection and focus-triggered selection, but its source has no arrow shortcut mapping; a real widget test showed Arrow Down left the value unchanged. A private `_RadioBridge` now owns per-option `FocusNode`s, maps vertical and direction-aware horizontal arrows, skips disabled options, and suppresses duplicate callbacks when focus change and shortcut selection coincide. Nodes are disposed on unmount and after option-list shrink; no caller-owned focus node/controller is passed to upstream. Radio option lists are read, never mutated. No overlay is used by these four controls.

Initial verification failures and actual corrections:

1. The first new test compilation failed because its local tri-state variable was inferred as non-nullable `bool` and the framework enum is `CheckedState.mixed`, not `isMixed`. The test types/imports were corrected without changing the tri-state assertion.
2. The first slider semantics implementation attached `onIncrease`/`onDecrease` while supplying `semanticValue`. Flutter asserted that these actions also require matching nonempty `increasedValue`/`decreasedValue`. The approved API offers only the current localized value, so no inaccurate future-value text is synthesized. Semantic adjustment actions were removed; upstream focus/arrow-key operation remains tested. This limitation is explicitly open.
3. The radio Arrow Down widget test initially failed with no selection change. The private bridge resolved the upstream shortcut gap. The strengthened test now checks a first arrow selects the first item and a second arrow selects the next, each with exactly one callback.
4. The new benchmark initially failed analysis because `FrameTiming` was not imported from `dart:ui`; the import was corrected. No production optimization was made.

## Functional and accessibility verification

`packages/nexabiz_ui/test/fields/binary_fields_test.dart` has **11 widget tests**: checkbox tri-state pointer/Space and parent reset; switch pointer/Enter; radio pointer choice, disabled option, parent update, option semantics, LTR arrows and RTL arrows skipping a disabled option, option removal and unmount; slider pointer, keyboard arrow and parent update; invalid slider arguments; field-derived semantics; four enabled/read-only combinations in both directions; and 320 px, 2× text scaling. `binary_public_api_compile_test.dart` adds one Flutter-and-public-barrel-only compile test. Tests use real widget taps and key events rather than directly calling component callbacks. The field-state matrix checks that disabled and read-only interactions invoke no value callback. Checkbox checked/unchecked/mixed and switch toggled state are asserted through Flutter semantics. Workbench integration has one new widget test; G3/G15/G18 protect reviewed exports, upstream type isolation and caller-owned semantic parameters. All existing tests remain present and were not weakened.

This is widget-semantics evidence, **not** TalkBack/VoiceOver certification. A standalone slider announces the application-provided `semanticValue`; if omitted, the package does not format a value. Screen-reader increment/decrement actions are not exposed under the approved value-only localization contract because Flutter requires translated prospective values for them. Physical keyboard, focus traversal across large dynamic radio lists, and screen-reader announcement order remain device-level risks. The `requiredIndicator` bool has a semantic required flag only; a separate approval would be needed for caller-localized visible required text under the existing `UiFieldShell` API.

## Isolated profile evidence

Entrypoint: `packages/nexabiz_ui/benchmark/choice_controls_profile.dart`, Flutter 3.44.4 / Dart 3.12.2. Runs used Linux x64 and separately Samsung SM-G986U, Android 13/API 33, ARM64 with Impeller. Each component was mounted alone. Iterations 0–1 were excluded warm-ups; iterations 2–11 are **ten measured warm samples** per scenario/platform. Checkbox and switch scenarios inject pointer down/up at the visible control, slider injects a pointer tap at alternating track positions, and radio alternates controlled parent values (it is a rebuild scenario, **not** a pointer benchmark). Pointer injection enters Flutter's gesture binding and excludes OS touch-delivery and display latency. A 350 ms collection interval followed the first frame; each component was then unmounted and an additional 250 ms idle window captured **zero frames** on both platforms. Checkbox, switch, radio and slider windows contained respectively 11–20, 8, 11 and 11 frames from the controls' own animations/host work. No unrelated spinner was mounted. First-mount/startup work was excluded; Android startup logs reported skipped frames.

Values are **min / median / mean / max in ms**, from ten warm samples. The UI and raster columns are each iteration's *maximum whole-frame* `FrameTiming` duration, not isolated component `build()` or raster cost. Wall time is dispatch through the first frame and includes vsync waiting.

| Platform | Scenario | Wall to first frame | Whole-frame UI span | Whole-frame raster span |
| --- | --- | --- | --- | --- |
| Linux | Checkbox pointer | 12.324 / 14.765 / 14.865 / 19.515 | 0.438 / 0.704 / 0.769 / 1.447 | 0.599 / 1.224 / 1.635 / 3.303 |
| Linux | Switch pointer | 13.558 / 14.445 / 14.475 / 15.591 | 0.477 / 0.892 / 0.839 / 1.042 | 0.479 / 0.974 / 0.864 / 1.059 |
| Linux | Radio parent update | 12.614 / 14.455 / 14.360 / 15.743 | 0.709 / 1.288 / 1.276 / 1.734 | 0.629 / 1.125 / 1.053 / 1.201 |
| Linux | Slider pointer | 13.250 / 14.785 / 14.607 / 15.944 | 0.841 / 1.124 / 1.119 / 1.405 | 0.917 / 1.089 / 1.086 / 1.480 |
| Android | Checkbox pointer | 11.108 / 27.421 / 25.724 / 33.253 | 1.469 / 3.763 / 3.563 / 5.375 | 2.166 / 2.858 / 2.880 / 3.451 |
| Android | Switch pointer | 7.936 / 13.050 / 12.745 / 16.923 | 1.017 / 3.139 / 2.699 / 3.972 | 1.287 / 2.186 / 2.269 / 3.036 |
| Android | Radio parent update | 14.799 / 26.331 / 24.997 / 32.509 | 3.446 / 5.124 / 4.981 / 5.983 | 2.202 / 2.864 / 2.727 / 3.403 |
| Android | Slider pointer | 9.707 / 10.982 / 12.934 / 30.279 | 3.164 / 3.663 / 3.736 / 4.535 | 1.898 / 2.037 / 2.304 / 3.037 |

Raw warm samples in iteration order, in **microseconds**, are preserved here as `wall / UI / raster`; UI/raster are per-window maxima:

```text
Linux checkbox: 14737,15133,15266,14857,13902,14793,14471,19515,12324,13653 / 651,731,845,649,788,815,651,676,1447,438 / 599,1269,1659,2279,903,1160,1180,1076,3303,2919
Linux switch:   14759,14311,13697,15308,15462,13558,14580,13723,13756,15591 / 1042,978,477,808,809,1037,864,920,496,954 / 973,846,519,1009,974,825,1059,982,479,977
Linux radio:    14180,15498,13648,14906,12614,15743,13598,14784,14730,13902 / 1533,1734,1146,1272,709,1315,1303,1215,1173,1360 / 1201,891,934,1098,629,1180,1133,1181,1168,1116
Linux slider:   13436,15813,14706,13399,15944,15019,13801,14864,13250,15842 / 904,1308,1209,1044,1203,1049,1026,1405,841,1199 / 1139,1152,963,1129,1119,1480,931,1058,917,971
Android checkbox: 33253,27665,30201,29039,27177,27032,33058,25278,11108,13432 / 4875,4416,4062,4418,3463,3170,5375,2261,2119,1469 / 3451,3211,2984,2792,2717,2846,3014,2747,2871,2166
Android switch: 11821,7936,16492,8417,11672,14010,16923,13179,12921,14074 / 3972,1575,3241,1296,1017,2161,3482,3037,3314,3899 / 2776,2707,2075,1905,1287,2296,2029,3036,2720,1862
Android radio: 28920,28600,29480,24063,32509,23229,14859,29473,24036,14799 / 5449,5159,5983,4699,5650,4149,4837,5345,3446,5089 / 2211,3403,2959,2202,2379,2954,3116,2315,2848,2880
Android slider: 12140,12502,10621,9707,11743,10408,10001,11344,30279,10592 / 3588,3433,4293,3379,3739,3164,3827,3373,4535,4032 / 1978,2096,2914,2779,1933,1898,1955,3037,2505,1941
```

These distributions show no isolated NexaBiz adapter hotspot. Android whole-frame UI spans exceeded the planning document's 2 ms *component-local build* target in some samples, but those are different quantities; the data cannot certify or refute that target. No before/after optimization or DevTools component-local trace was performed. No speculative production optimization was made. Multiple device sessions, physical touch latency, memory/thermal behavior and screen-reader performance remain unverified.

## Commands and repository state

| Command (all with `--no-pub` where applicable) | Actual final result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test packages/nexabiz_ui/lib packages/nexabiz_ui/test packages/nexabiz_ui/benchmark` (root) | Exit 0; 68 files checked, zero changed. |
| `flutter analyze --no-pub` (package) | Exit 0; no issues. |
| `flutter analyze --no-pub` (workspace) | Exit 0; no issues. |
| `flutter test --no-pub test/fields --reporter compact` (package) | Exit 0; 12/12 tests. |
| `flutter test --no-pub --reporter expanded` (package) | Exit 0; 201/201 tests. |
| `flutter test --no-pub test/architecture/boundary_test.dart test/workbench_test.dart --reporter expanded` (workspace) | Exit 0; 18 architecture + 6 Workbench = 24/24 tests. |
| `flutter run --profile --no-pub -d linux -t packages/nexabiz_ui/benchmark/choice_controls_profile.dart` | Exit 0; `CHOICE complete`, 10 warm measured samples × 4 scenarios; teardown idle frames 0. |
| Same profile command with `-d R5CN219FC7T` | Exit 0; `CHOICE complete`, 10 warm measured samples × 4 scenarios; teardown idle frames 0. |
| `git diff --check` | Exit 0; no whitespace errors. |

Tracked `git diff --stat` currently shows **5 files, 253 insertions, 39 deletions** across `lib/main.dart`, the public barrel, `tokens.dart`, the architecture test and Workbench test. This includes pre-existing Step 02/03 edits and excludes all untracked Step 02/03/04 source, tests, benchmarks and Phase 02 docs. The Step 04 additions are the four field source files, two field test files, one benchmark, approved public API/documentation updates, narrowly expanded G3/G18 guards, and scoped Workbench examples/test. The unrelated untracked `nexabiz_ui.tar.xz` and all pre-existing user changes were preserved. No files were committed, deleted or discarded.

### Remaining risks and acceptance boundary

- Physical TalkBack/VoiceOver testing and end-to-end announcement ordering are outstanding. In particular, localized slider increase/decrease semantic actions cannot be represented accurately with only the approved current `semanticValue`; adding caller-supplied prospective values/formatter would be a further public API decision.
- The approved boolean `requiredIndicator` yields a semantic required flag, but no visible localized required marker because the existing shell takes caller-supplied text. This should be reviewed with product accessibility and localization owners before release.
- Radio choice focus is package-owned and tested for arrows, disabled skipping, list shrink and disposal, but very large/reordered dynamic option lists and physical keyboard behavior have not been profiled or device-tested.
- Profile data are one ten-sample session per platform/scenario, with full-frame UI/raster spans and synthetic Flutter pointer dispatch. They do not certify per-component build budgets, thermal stability, OS input latency, or accessibility responsiveness.

No Step 05 implementation was started.
