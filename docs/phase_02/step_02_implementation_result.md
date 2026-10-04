# Phase 02 / Step 02 — Action controls and loading indicators

Status: **implemented; conditional performance acceptance**. Scope ends at Step 02. No Step 03 work was started.

## Public contract and implementation

The barrel exports only `UiSpinner`, `UiButton`, `UiIconButton`, `UiButtonVariant`, and `UiButtonSize`. `UiButton` retains `String label`, `VoidCallback? onPressed`, variant (`primary`, `secondary`/outline, `ghost`, `destructive`, `link`), size (`sm`, `md`, `lg`), leading/trailing icons, `isLoading`, and `enabled`. Its default, `.outline`, `.ghost`, and `.destructive` constructors all accept the approved additive `String? loadingSemanticLabel`. `UiSpinner` retains optional `size` and `color` and adds `String? semanticLabel`. `UiIconButton` retains required `icon` and `semanticLabel`, optional `tooltip`, `onPressed`, variant, size, and enabled state. No upstream type is public; shadcn_flutter 0.0.53 remains the internal primitive source.

`String label` covers standard localized administrative actions and dynamic plain text. Rich inline text/badges inside the button are outside this approved contract; adjacent composition remains possible. No further API change was made.

The application owns localization. A busy button uses `loadingSemanticLabel` when supplied and otherwise keeps `label` as its accessible name. `UiSpinner` exposes a caller-provided label only when supplied; it invents no English fallback. The spinner nested in `UiButton` is excluded from semantics, leaving one button announcement. The button reserves its original content dimensions during loading and suppresses pointer/keyboard callbacks; disabled buttons and icon buttons similarly suppress callbacks. Colors, text styling, size and focus/hover mechanics derive from upstream theme and controls. The Workbench action tab supplies its own English/Arabic labels and uses only NexaBiz action components.

Relevant implementation: `packages/nexabiz_ui/lib/src/feedback/spinner.dart`, `lib/src/actions/button.dart`, `lib/src/actions/icon_button.dart`, public barrel `lib/nexabiz_ui.dart`, and Workbench `lib/main.dart`. The former unexported placeholder `UiButton` in `src/foundation/tokens.dart` was removed to allow the approved real contract. G3 now permits exactly the five reviewed exports; existing G15 rejects upstream types in exported contracts; new G16 guards the two additive accessibility parameters. No dependency was added.

## Interaction and accessibility evidence

New action tests use real pointer taps, Tab focus followed by Enter/Space, mouse hover and tooltip display. They assert one callback per valid activation, zero callbacks when disabled/loading, localized semantics, no nested progress semantics node, stable button size, named-constructor labels, RTL/LTR with 2× text scale, and public-barrel-only compilation. Spinner tests cover caller label, no generated English name, size/color, rebuild, and direction. Workbench has a dedicated action tab and an integration test.

Initial failures and corrections were preserved in the work log:

- The shell did not find `flutter`; commands were rerun with `/home/hosam/Downloads/flutter-sdk/flutter/bin/flutter` (Flutter 3.44.4, Dart 3.12.2).
- The first test compilation used an unavailable `SemanticsFlag` import, then a removed `SemanticsFlags.contains` API; the test now asserts `flagsCollection.isEnabled == Tristate.isFalse` without weakening the disabled assertion.
- Keyboard tests initially sent Enter before focus and observed one callback instead of two. Explicit Tab focus made both Enter and Space activation pass; upstream `Clickable` uses `FocusableActionDetector` and `ActivateIntent`.
- Always-visible Workbench spinner caused all three existing `pumpAndSettle` tests to time out. Moving the showcase to a dedicated, initially inactive action tab restored them while retaining a standalone spinner example.
- The first hover assertion checked before the upstream tooltip's 500 ms delay and transition; advancing the test clock through both stages made the actual tooltip text visible.

## Profile measurements

Reproducible entrypoint: `packages/nexabiz_ui/benchmark/action_controls_profile.dart`. Invocations: `flutter run --profile --no-pub -d linux -t packages/nexabiz_ui/benchmark/action_controls_profile.dart` and the same with `-d R5CN219FC7T`. Each run executes **10 iterations per scenario** on one screen: button rebuild after loading, button pointer, icon pointer, loading transition, spinner insertion. `FrameTiming` supplies per-window maximum build/raster duration; wall time spans action dispatch through the next frame. Each cell below is **min / median / mean / max / sample standard deviation**, in milliseconds, across the 10 iterations.

| Platform and scenario | Wall ms | Max build/frame ms | Max raster/frame ms |
| --- | --- | --- | --- |
| Linux x64 button rebuild | 10.089 / 11.232 / 13.443 / 34.981 / 7.590 | 0.619 / 1.079 / 1.146 / 2.137 / 0.548 | 0.517 / 0.779 / 0.804 / 1.382 / 0.277 |
| Linux button pointer | 4.780 / 7.047 / 9.530 / 21.956 / 6.167 | 0.443 / 0.623 / 0.787 / 1.237 / 0.329 | 0.462 / 0.564 / 0.703 / 1.042 / 0.253 |
| Linux icon pointer | 5.777 / 6.448 / 7.177 / 13.841 / 2.373 | 0.445 / 0.746 / 0.849 / 1.320 / 0.324 | 0.372 / 0.789 / 1.263 / 5.953 / 1.671 |
| Linux loading transition | 4.554 / 7.142 / 7.681 / 15.383 / 3.028 | 0.750 / 1.440 / 1.641 / 2.666 / 0.679 | 0.453 / 1.031 / 1.063 / 2.202 / 0.501 |
| Linux spinner insertion | 3.732 / 5.654 / 5.733 / 8.519 / 1.305 | 0.872 / 1.152 / 1.406 / 2.640 / 0.551 | 0.519 / 0.836 / 1.002 / 2.547 / 0.597 |
| Android SM-G986U, API 33 button rebuild | 5.902 / 15.666 / 14.753 / 20.327 / 5.022 | 0.917 / 3.880 / 3.543 / 5.912 / 1.529 | 1.961 / 2.865 / 3.508 / 11.001 / 2.683 |
| Android button pointer | 5.443 / 18.715 / 17.281 / 29.104 / 6.779 | 0.750 / 1.713 / 2.182 / 4.335 / 1.187 | 1.534 / 2.007 / 1.993 / 2.800 / 0.368 |
| Android icon pointer | 7.700 / 23.285 / 21.726 / 26.116 / 5.217 | 0.736 / 2.140 / 2.917 / 5.239 / 1.582 | 1.133 / 2.155 / 2.070 / 2.684 / 0.418 |
| Android loading transition | 10.636 / 30.214 / 27.230 / 34.634 / 6.762 | 3.463 / 9.188 / 7.452 / 10.683 / 3.288 | 2.374 / 2.817 / 2.771 / 3.233 / 0.326 |
| Android spinner insertion | 6.191 / 22.778 / 21.947 / 31.339 / 6.425 | 3.054 / 8.704 / 7.754 / 10.159 / 2.477 | 1.772 / 2.890 / 2.648 / 3.754 / 0.664 |

The 2 ms build and 16 ms interaction targets are **not consistently met on Android**. This is not a claim of Android frame-budget certification or of a measured optimization. The continuously animated indicator contributes frames to later sample windows; window maxima and wall-to-next-frame include vsync, animation, and other app work rather than isolated component build/layout. The connected Android device reported Vulkan/OpenGLES Impeller initialization. No memory, battery, TalkBack/VoiceOver, or physical-keyboard study was performed. Further profiling should isolate animation and use DevTools timeline traces before considering optimizations.

## Final verification

| Command | Actual result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test benchmark` in package | 46 files, 0 changed; exit 0 |
| `dart format --output=none --set-exit-if-changed lib test` at workspace root | 3 files, 0 changed after formatting new Workbench test; exit 0 |
| `flutter analyze --no-pub` in package | No issues; exit 0 |
| `flutter analyze --no-pub` at workspace root | No issues; exit 0 |
| `flutter test --no-pub test/actions test/feedback` in package | 13/13 passed; exit 0 |
| `flutter test --no-pub --reporter compact` in package | 176/176 passed; exit 0 |
| `flutter test --no-pub test/architecture test/workbench_test.dart` at workspace root | 20/20 passed: 16 architecture, 4 Workbench; exit 0 |
| Linux and Android profile commands above | 10/10 iterations per scenario on each platform; `BENCH complete` observed |

The approved API changes are additive and leave Phase 01 exports/behavior intact. G3, G15 and G16 pass, and the public API compile test imports only Flutter and the NexaBiz barrel. There were no dependency changes and no existing tests were weakened.

## Repository diff and remaining risks

`git diff --stat` currently reports 5 tracked files, **71 insertions and 2 deletions** (`lib/main.dart`, barrel, `tokens.dart`, G3/G16 guards, Workbench test). Git does not include untracked new action/feedback source, tests, benchmark, or Phase 02 documentation in that statistic; these are present in `git status --short`. The unrelated untracked `nexabiz_ui.tar.xz` was untouched. No files were committed or discarded.

Remaining risks: Android profile targets are missed in this mixed animation scenario; accessibility has widget-semantic verification but no screen-reader device audit; tooltip and focus were tested in Flutter widget harness, not with a physical keyboard; narrow layout checks cover the button but not every icon/label combination. Further investigation is warranted before a performance certification claim. Do not start Step 03 without separate approval.
