# Phase 02 / Step 03 — visual components implementation result

**Recommendation: CONDITIONAL PASS.** The approved six component groups are implemented, exported, functionally tested and integrated into the Workbench. Linux and physical Android profile samples were collected independently, but they are full-frame measurements and do not certify the component-local 2/4 ms planning targets or physical-device accessibility. Step 04 has not begun.

## Approved public contracts and implementation

| Public symbols | Contract and internal adapter |
| --- | --- |
| `UiCard` | Required `Widget child`; optional `String? title`, `String? description`, `Widget? header`, `Widget? footer`, `Widget? actions`, `EdgeInsetsGeometry? padding`, `bool filled=false`. Uses upstream `Card` for the themed surface and existing `UiSection` for headings/actions; structural spacing uses existing `UiTokens`. |
| `UiBadge`, `UiBadgeVariant` | Required `String label`; optional variant (`primary`, `secondary`, `outline`, `destructive`) and `Widget? leadingIcon`. Maps to upstream four badge primitives. One status semantic name; no upstream public type. |
| `UiChip` | Required `Widget label`; optional `leading`, `trailing`, `onPressed`, `onDeleted`, `enabled=true`, `String? deleteSemanticLabel`. An assertion and runtime `ArgumentError` enforce a non-empty (non-whitespace) delete label when `onDeleted` is supplied. Uses upstream `Chip` and adjacent `ChipButton`, not a nested button. The delete target has its own semantics and keyboard action. Non-interactive chip bodies are removed from pointer and focus interaction because upstream null `onPressed` becomes a no-op callback. |
| `UiDivider`, `UiDividerOrientation` | Horizontal/vertical, optional `margin`, `thickness`, `semanticLabel`. Uses upstream divider primitives. Decorative semantics are excluded by default; caller text is announced when supplied. No nonexistent Flutter separator role is claimed. |
| `UiAvatar`, `UiAvatarSize` | Required `String name`; optional Flutter `ImageProvider? image`, size `sm/md/lg` = 32/40/48 logical pixels, `String? semanticLabel`. Uses upstream `Avatar` for image fallback. Internal initials handling groups base code points with common combining marks, variation selectors and joiners; tested with Arabic, English, combining marks and empty names. Accessible description is `semanticLabel ?? name`, with the image/initials subtree excluded to avoid double speech. |
| `UiTooltip` | Required `Widget child` and caller-localized `String message`; `waitDuration=500ms`. Uses upstream `OverlayController`, `PopoverConfiguration`, `TooltipContainer` and anchored `PopoverOverlayHandler`; Flutter mouse/focus/long-press events arbitrate one overlay. The target exposes the message as a semantic tooltip; the visible overlay is excluded from semantics to avoid duplicate announcements. No controller or upstream type is exported. |

The pinned upstream 0.0.53 source was checked at `lib/src/components/layout/card.dart`, `display/badge.dart`, `display/chip.dart`, `display/divider.dart`, `display/avatar.dart`, `overlay/tooltip.dart`, `overlay/overlay_configuration.dart` and `overlay/popover.dart`. Its `Tooltip` widget handles hover and mobile long-press but not focus. A tested mobile-handler path did not dismiss reliably with `OverlayController.close`; the adapter therefore uses the upstream anchored popover handler consistently. Its immediate popover close also caused a duplicate completion in a widget test, so ordinary animated close is used, and controller disposal defers closure safely during widget-tree teardown. Parent message changes update the live overlay configuration in a post-frame callback; pending hover timers are canceled on exit/disposal. The public API remains Flutter/NexaBiz-only.

All user-visible example text and internal accessible names are supplied by the consuming application. The Workbench now has a separate visual tab using only the public NexaBiz components; its existing shadcn app shell is outside this step's decoupling scope. Existing Phase 01 and Step 02 public APIs and dependencies were not changed.

## Interaction, accessibility and lifecycle evidence

`packages/nexabiz_ui/test/display/` has 13 tests: card slot composition and parent replacement; four badge variants; both divider orientations/decorative versus labeled semantics; three avatar sizes, Arabic/English/combining/empty names; chip pointer and keyboard callback counts, disabled state, independent delete semantics and invalid-label enforcement; tooltip delayed hover, focus, Escape, outside tap, long-press, parent message update and unmount; plus a public-barrel compile test with no shadcn import. The 320/420/960-pixel × 1.5/2.0 text-scale × RTL/LTR matrix checks the static visual composition and tooltip/chip layout with no overflow. It is widget-test evidence, not physical screen-reader certification.

Initial test runs exposed and resolved: a vertically undersized test host for the card (the host now scrolls); a mistaken expected callback count across RTL/LTR loop iterations (assertions now use the actual iteration); nested chip controls merging semantics (controls were separated); the mobile tooltip handler retaining an overlay after close (anchored popover handler); immediate popover closure raising `Future already completed` (animated closure); overlay closure during `dispose` calling `markNeedsBuild` while the tree was locked (controller deferred disposal); and tooltip overlay text being absent from the non-modal semantics tree (the target now has the caller's semantic tooltip, with overlay semantics excluded). No existing production behavior or assertion was weakened to hide these failures.

## Profile method and results

`packages/nexabiz_ui/benchmark/visual_components_profile.dart` runs with Flutter 3.44.4 / Dart 3.12.2 in profile mode. Targets: Linux x64 desktop and a physical Samsung SM-G986U, Android 13/API 33, ARM64 with Impeller. Each scenario is mounted alone; one first-mount diagnostic is separate from two warm-up iterations and **ten measured warm iterations**. A 250 ms frame-timing collection interval captures `FrameTiming` samples; a 350+250 ms teardown/idle interval recorded zero frames after every scenario. Card, badge and avatar change incoming values; divider alternates thickness (so its transition legitimately renders 11 animation frames); chip dispatches a real pointer sequence and recorded exactly one callback each time; tooltip moves a synthetic mouse into its target, opens an animated overlay and then removes the pointer. The final tooltip semantics implementation was reprofiled on each platform. No background spinner was mounted. `wall_us` runs from action dispatch to the next frame; it includes vsync waiting and is **not** UI-thread work or finger-to-photon latency.

Values below are **minimum / median / maximum / mean / population standard deviation**, milliseconds, across the ten warm iterations. Build and raster figures are the largest `FrameTiming` duration in each iteration's collection window; they cover the whole frame, not just the named component. Single-frame cases had one frame; divider had 11; final tooltip had 13–14 Linux and 14 Android frames. The first five rows per platform came from the initial run; tooltip came from the final-code rerun.

| Platform | Scenario | Full UI frame span, ms | Raster frame span, ms | Wall to next frame, ms |
| --- | --- | --- | --- | --- |
| Linux | Card rebuild | 0.407 / 0.539 / 0.650 / 0.534 / 0.086 | 0.390 / 0.593 / 0.863 / 0.590 / 0.145 | 11.672 / 12.835 / 13.540 / 12.736 / 0.615 |
| Linux | Badge rebuild | 0.473 / 0.614 / 1.311 / 0.717 / 0.247 | 0.394 / 0.480 / 1.416 / 0.600 / 0.291 | 12.097 / 13.100 / 14.520 / 13.039 / 0.643 |
| Linux | Avatar rebuild | 0.351 / 0.459 / 0.684 / 0.478 / 0.089 | 0.329 / 0.473 / 0.694 / 0.488 / 0.114 | 12.158 / 13.037 / 13.694 / 12.881 / 0.473 |
| Linux | Divider thickness transition | 0.292 / 0.365 / 0.677 / 0.433 / 0.126 | 0.399 / 0.583 / 4.066 / 0.949 / 1.051 | 11.873 / 12.846 / 13.802 / 12.761 / 0.584 |
| Linux | Chip pointer | 0.248 / 0.371 / 0.891 / 0.450 / 0.194 | 0.343 / 0.431 / 0.824 / 0.502 / 0.159 | 6.075 / 13.147 / 13.774 / 12.387 / 2.139 |
| Linux | Tooltip hover/open | 0.635 / 1.084 / 1.287 / 1.037 / 0.197 | 0.850 / 1.344 / 1.533 / 1.322 / 0.188 | 9.609 / 10.834 / 11.558 / 10.794 / 0.566 |
| Android | Card rebuild | 2.532 / 6.359 / 6.916 / 5.603 / 1.531 | 2.040 / 2.544 / 8.190 / 3.215 / 1.753 | 12.294 / 23.721 / 29.775 / 22.954 / 5.585 |
| Android | Badge rebuild | 2.914 / 6.502 / 7.389 / 6.031 / 1.490 | 2.313 / 2.517 / 3.250 / 2.605 / 0.307 | 17.497 / 25.963 / 31.779 / 24.991 / 4.710 |
| Android | Avatar rebuild | 1.753 / 4.452 / 6.146 / 4.142 / 1.360 | 1.794 / 2.109 / 3.225 / 2.233 / 0.482 | 6.131 / 21.848 / 30.213 / 21.238 / 6.636 |
| Android | Divider thickness transition | 1.690 / 3.184 / 3.718 / 2.932 / 0.618 | 2.087 / 2.908 / 4.172 / 2.947 / 0.502 | 9.068 / 12.167 / 24.406 / 13.172 / 4.149 |
| Android | Chip pointer | 0.691 / 3.404 / 4.166 / 2.773 / 1.213 | 1.095 / 2.266 / 3.308 / 2.197 / 0.606 | 7.337 / 22.886 / 32.716 / 20.908 / 8.881 |
| Android | Tooltip hover/open | 1.228 / 2.484 / 4.556 / 2.646 / 1.104 | 2.247 / 3.206 / 3.876 / 3.063 / 0.529 | 7.881 / 23.309 / 30.481 / 20.784 / 8.343 |

Raw measured samples (microseconds), in iteration order, are provided below as `build / raster / wall`. For divider and tooltip, build/raster are each iteration's maximum frame value, not a sum of animated frames. The benchmark emits all individual frame values for reproduction.

```text
Linux card:    545,407,650,595,472,631,432,532,450,629 / 706,678,863,605,447,581,493,390,419,713 / 11672,12192,12577,13307,13093,13540,12256,13450,12153,13121
Linux badge:   596,699,540,631,500,473,916,585,1311,918 / 490,470,460,412,530,394,694,432,1416,705 / 13441,12568,13250,13208,12097,13219,12992,12346,14520,12750
Linux avatar:  566,491,684,434,453,351,465,501,443,389 / 677,398,694,474,552,329,428,471,475,383 / 13694,13195,12740,12158,12367,13028,13153,12219,13212,13045
Linux divider: 332,536,557,321,339,548,359,292,370,677 / 399,577,858,407,460,876,546,4066,709,589 / 13048,13367,12670,11991,13032,12777,12134,12914,11873,13802
Linux chip:    248,297,649,346,363,378,603,452,270,891 / 351,366,824,343,525,396,664,440,421,685 / 6075,13242,13193,12286,13327,13327,12921,12620,13100,13774
Linux tooltip: 725,1106,1287,1099,1029,1259,1038,1068,1125,635 / 850,1336,1403,1520,1348,1184,1453,1533,1340,1254 / 10896,11434,11558,10294,11411,10807,10642,10860,9609,10431
Android card:    2532,6363,6379,6916,6427,2643,6526,6355,6011,5873 / 2149,2559,4212,2523,2627,8190,2915,2528,2406,2040 / 12294,16866,28627,27825,23911,23531,16462,26857,23396,29775
Android badge:   6723,7389,5882,7136,6281,3513,7186,6173,7108,2914 / 2375,3250,3033,2486,2325,2313,2622,2770,2323,2548 / 27185,30548,28323,24227,26367,20478,17944,25558,31779,17497
Android avatar:  4385,1753,5327,4501,6146,4863,2188,4402,5081,2769 / 2099,1794,1847,2119,2209,3084,1807,3225,2140,2002 / 21759,6131,17731,26093,30213,21703,22501,15398,28919,21936
Android divider: 3410,3718,1690,2779,3201,3166,2881,1914,3317,3245 / 2954,4172,3247,3004,2744,2687,2087,2861,2692,3018 / 24406,9068,12469,11570,12900,11019,9466,11865,15582,13374
Android chip:    4166,3126,1652,3681,3871,3780,3716,691,1585,1466 / 2359,2173,1823,2448,2643,2724,3308,1603,1095,1793 / 32716,21209,9107,31591,28190,26848,24562,7337,15743,11777
Android tooltip: 1823,3800,4556,1797,1228,2772,2784,1424,4083,2196 / 2470,3087,3460,3325,2622,3568,3876,2247,3456,2521 / 7881,29157,28100,20217,8384,26641,24337,10361,30481,22281
```

First-mount diagnostic maxima (UI/raster, ms) were Linux Card 3.381/9.249 (3 frames), Badge 1.469/0.741, Avatar 0.809/0.565, Divider 0.373/16.649, Chip 0.644/0.444, final Tooltip 2.631/11.030 (2 frames); Android Card 12.129/10.804 (2 frames), Badge 11.343/4.720, Avatar 5.254/9.182, Divider 3.498/5.192, Chip 3.696/1.542, final Tooltip 12.083/11.479 (2 frames). These are single samples, and process startup/first-use work contaminates some of them. Android startup logs also reported skipped frames. They are not warm distributions or proof of component-local defects.

The Linux/Android differences and Android variance are substantial. A `FrameTiming.buildDuration` is the full UI-thread frame span, not the cost of the widget's `build` method; the wall value includes scheduling. Tooltip and divider scenarios intentionally animate their own overlays/thickness changes, so their multiple frames are not unrelated-spinner contamination. The 2/4 ms component-build targets cannot be inferred from these full-frame spans. No reproducible component-local hotspot was isolated; no speculative production optimization was made. VoiceOver/TalkBack, true finger-to-photon latency, controlled thermal/power runs, multiple Android devices, and image-provider failure on hardware remain unverified.

## Verification and repository hygiene

Commands and observed results (all `--no-pub`, with no dependency installation):

| Command | Result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test packages/nexabiz_ui/lib packages/nexabiz_ui/test packages/nexabiz_ui/benchmark` | Exit 0; 61 files checked, zero changed. |
| `flutter analyze --no-pub` (workspace) | Exit 0; no issues. |
| `flutter analyze --no-pub packages/nexabiz_ui` | Exit 0; no issues. |
| `flutter test --no-pub test/display` (package) | Exit 0; 13/13 tests. |
| `flutter test --no-pub` (package) | Exit 0; 189/189 tests. Initial run failed one new tooltip test because its own `SemanticsHandle` was disposed only in `addTearDown`; the handle was removed and the full suite rerun without weakening assertions. |
| `flutter test --no-pub test/architecture/boundary_test.dart test/workbench_test.dart` (workspace) | Exit 0; 17 architecture + 5 Workbench = 22 tests. |
| `flutter run --profile --no-pub -d linux -t packages/nexabiz_ui/benchmark/visual_components_profile.dart` and equivalent `-d R5CN219FC7T` | Both reached `VISUAL complete`; six first-mount samples plus 12 iterations/scenario (2 warm-up, 10 measured), idle frames zero. The final tooltip adapter was rerun on both devices with `--dart-define=BENCH_SCENARIO=tooltipHover`. |
| `git diff --check` | Exit 0. |

Only the six Step 03 source files, the reviewed barrel/architecture additions, Workbench example/test, four Step 03 test files, one Step 03 benchmark, and the relevant Phase 02 docs were changed for this step. The tracked `git diff --stat` currently includes pre-existing Step 02 edits and reports **5 files, 168 insertions, 2 deletions**; it does **not** include untracked Step 02/03 files or docs. Pre-existing `nexabiz_ui.tar.xz`, Step 02 sources/tests/benchmarks and unrelated worktree state were preserved. No files were committed, deleted from the repository, or discarded; no dependencies changed.

### Remaining risks

- `UiTooltip` uses the upstream anchored popover on mobile to ensure reliable dismissal; physical touch/hover/focus behavior and screen-reader announcement timing still need device accessibility testing. Its fade-out may remain visually present briefly after dismissal, as upstream animation intends.
- The Unicode initials helper covers the approved Arabic/English/combining-mark cases, not the full extended-grapheme standard for every script and emoji sequence. Full grapheme support would require a contract/dependency review.
- Chip body and delete are separate upstream controls for independent semantics; their adjacency may need visual golden review across themes/densities. The approved public contract remains unchanged.
- Android full-frame distributions and first-mount outliers do not certify planning targets or 60/120 Hz end-to-end responsiveness. Controlled trace attribution and hardware accessibility testing remain release gates.

No Step 04 components were implemented.
