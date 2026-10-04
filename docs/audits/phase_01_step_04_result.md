# Phase 01 / Step 04 — Measured selection optimization

## Decision and change

The [profile baseline](phase_01_step_04_baseline.md) measured a large select-popup build cost at 1,000 and 10,000 options, and the pre-fix widget test counted all 1,000 option builders on open. This was caused by wrapping all options in one eager `SelectGroup` and passing that as a single `SelectItemList` child. The upstream `SelectPopup`'s lazy `ListView.builder` could not lazily build the group's children.

`UiSelectField` and `UiMultiSelectField` now use the pinned shadcn 0.0.53 `SelectItemBuilder` delegate with `childCount: widget.items.length` and an indexed button builder. The existing `SelectPopup` and its default shrink-wrap behavior remain. There is no public constructor/export change, dependency, debounce, controller change, or change to autocomplete. The former group had no header/footer, so flattening its children preserves option order and individual button styling; pointer and keyboard regression tests verify interaction. The new delegate creates visible option widgets on demand instead of constructing all 10,000 button widgets just to open a popup.

The `shadcn-flutter` skill's select guidance established the required popup/list composition; the resolved 0.0.53 implementation's `SelectItemBuilder` supplied the lazy path. It influenced only this measured selection change.

## Comparable profile observations

Same Linux host, Flutter 3.44.4 profile mode, benchmark entrypoint, 10/100/1,000/10,000 option generation, action order, pointer injection, and frame-timing method were used before and after. Each cell is the **largest build duration among the raw frames for one opening action**, in milliseconds. This is an observed one-run comparison, not a distribution or cross-device guarantee.

| Options | Select before | Select after | MultiSelect before | MultiSelect after |
| ---: | ---: | ---: | ---: | ---: |
| 10 | 5.108 | 6.355 | 16.504 | 6.159 |
| 100 | 62.586 | 8.550 | 46.834 | 12.936 |
| 1,000 | 356.133 | 5.827 | 374.953 | 8.509 |
| 10,000 | 3,725.461 | 8.193 | 3,659.813 | 4.426 |

The 10,000-option opening build frame fell from seconds to single-digit milliseconds in this profile run. Because baseline and post runs each have only one sample, do not interpret ratios or small-size variation as stable performance claims. Raster durations were comparatively small in the pre-fix slow-open frames (1.289 ms single and 0.885 ms multi at 10,000); the dominant measured cost was build/layout work, not rasterization. The baseline connection ended before multi-select close completed; the post-change run reached `BENCH complete`.

Autocomplete stayed unchanged. For the 10,000-option `Opt` query, its recorded largest build duration was 6.671 ms before and 6.370 ms after; this difference is run noise, **not** an optimization. Its source still filters all candidates on controller-driven rebuilds and allocates a fresh list for non-empty queries. Caching lowercased strings, skipping selection-only notifications, limiting results, or a paginated/async API remain proposals requiring separate evidence and (for API change) approval. Local debounce was rejected without evidence of benefit because it would add latency.

## Raw final-code profile output

Microseconds; arrays preserve every reported frame per action. See the baseline report for the equally raw pre-change output and the benchmark's measurement caveats.

```text
BENCH case=autocomplete_10.build wall_us=63158 frames=4 build_us=780,347,3615,4059 raster_us=522,555,1808,573
BENCH case=autocomplete_10.type_O wall_us=9584 frames=4 build_us=1464,2030,1216,294 raster_us=670,3742,1524,497
BENCH case=autocomplete_10.type_Op wall_us=4732 frames=1 build_us=814 raster_us=738
BENCH case=autocomplete_10.type_Opt wall_us=7861 frames=1 build_us=1430 raster_us=789
BENCH case=autocomplete_10.type_Option 9 wall_us=21225 frames=2 build_us=925,336 raster_us=638,679
BENCH case=select_10.build wall_us=12003 frames=3 build_us=369,1921,211 raster_us=380,1715,395
BENCH case=select_10.open wall_us=23125 frames=7 build_us=6355,699,204,315,193,225,268 raster_us=449,4474,1723,1031,814,3513,589
BENCH case=select_10.close wall_us=19037 frames=7 build_us=144,123,756,383,249,202,202 raster_us=422,557,658,826,660,605,757
BENCH case=multiSelect_10.build wall_us=6250 frames=2 build_us=1752,408 raster_us=1226,664
BENCH case=multiSelect_10.open wall_us=26776 frames=7 build_us=6159,710,271,198,203,216,197 raster_us=619,663,1165,512,681,536,770
BENCH case=multiSelect_10.close wall_us=17137 frames=7 build_us=155,211,495,209,278,251,163 raster_us=618,799,570,626,659,694,625
BENCH case=autocomplete_100.build wall_us=6571 frames=2 build_us=1458,516 raster_us=477,562
BENCH case=autocomplete_100.type_O wall_us=12226 frames=4 build_us=318,1492,605,485 raster_us=394,720,627,618
BENCH case=autocomplete_100.type_Op wall_us=5871 frames=1 build_us=1347 raster_us=716
BENCH case=autocomplete_100.type_Opt wall_us=4958 frames=1 build_us=872 raster_us=447
BENCH case=autocomplete_100.type_Option 9 wall_us=6923 frames=2 build_us=975,281 raster_us=513,430
BENCH case=select_100.build wall_us=10937 frames=3 build_us=334,940,238 raster_us=554,528,869
BENCH case=select_100.open wall_us=14147 frames=7 build_us=8550,922,629,318,285,258,240 raster_us=618,910,1178,967,987,932,591
BENCH case=select_100.close wall_us=18594 frames=7 build_us=338,417,951,490,472,399,393 raster_us=986,802,700,887,1033,1037,958
BENCH case=multiSelect_100.build wall_us=19602 frames=2 build_us=1417,342 raster_us=567,476
BENCH case=multiSelect_100.open wall_us=17873 frames=6 build_us=12936,592,198,171,258,171 raster_us=685,564,523,474,490,453
BENCH case=multiSelect_100.close wall_us=8995 frames=7 build_us=142,141,782,280,272,292,285 raster_us=495,467,463,562,572,634,607
BENCH case=autocomplete_1000.build wall_us=5124 frames=2 build_us=964,489 raster_us=454,424
BENCH case=autocomplete_1000.type_O wall_us=10583 frames=4 build_us=357,1181,425,356 raster_us=453,523,582,533
BENCH case=autocomplete_1000.type_Op wall_us=6148 frames=1 build_us=1030 raster_us=421
BENCH case=autocomplete_1000.type_Opt wall_us=8302 frames=1 build_us=2809 raster_us=1239
BENCH case=autocomplete_1000.type_Option 9 wall_us=21545 frames=2 build_us=1621,296 raster_us=725,407
BENCH case=select_1000.build wall_us=10979 frames=3 build_us=300,848,118 raster_us=366,480,355
BENCH case=select_1000.open wall_us=10913 frames=7 build_us=5827,559,169,182,185,167,167 raster_us=396,496,458,581,534,477,424
BENCH case=select_1000.close wall_us=17976 frames=7 build_us=167,133,518,215,241,202,260 raster_us=410,405,452,631,533,620,581
BENCH case=multiSelect_1000.build wall_us=10143 frames=2 build_us=3141,738 raster_us=1058,955
BENCH case=multiSelect_1000.open wall_us=31227 frames=6 build_us=8509,623,267,265,189,216 raster_us=774,612,577,449,586,465
BENCH case=multiSelect_1000.close wall_us=9236 frames=7 build_us=190,169,716,236,230,250,263 raster_us=691,613,692,598,807,724,780
BENCH case=autocomplete_10000.build wall_us=6894 frames=2 build_us=1262,457 raster_us=382,513
BENCH case=autocomplete_10000.type_O wall_us=14585 frames=4 build_us=444,3149,461,363 raster_us=499,563,524,542
BENCH case=autocomplete_10000.type_Op wall_us=21480 frames=1 build_us=2208 raster_us=472
BENCH case=autocomplete_10000.type_Opt wall_us=11628 frames=1 build_us=6370 raster_us=1284
BENCH case=autocomplete_10000.type_Option 9 wall_us=22658 frames=2 build_us=6003,414 raster_us=1451,586
BENCH case=select_10000.build wall_us=10874 frames=3 build_us=443,1079,118 raster_us=479,569,375
BENCH case=select_10000.open wall_us=13140 frames=7 build_us=8193,585,232,361,221,196,176 raster_us=383,623,671,983,678,521,696
BENCH case=select_10000.close wall_us=14860 frames=7 build_us=173,315,529,202,176,411,214 raster_us=677,569,463,764,711,909,724
BENCH case=multiSelect_10000.build wall_us=25786 frames=2 build_us=2865,687 raster_us=1001,1097
BENCH case=multiSelect_10000.open wall_us=23908 frames=7 build_us=4426,617,151,160,184,158,184 raster_us=534,649,448,471,518,511,412
BENCH case=multiSelect_10000.close wall_us=3457 frames=7 build_us=236,255,914,257,240,176,179 raster_us=859,827,666,568,487,519,522
BENCH complete
```

## Functional and tooling verification

The new `test/selection_lazy_build_test.dart` tests failed before the production change: single-select itemBuilder called **1,001** times and multi-select **1,000** times for 1,000 options. After the change, both tests passed their strict `<100` visible-build assertion. No existing test was weakened or removed.

| Command | Actual result |
| --- | --- |
| `dart format --output=none --set-exit-if-changed lib test benchmark` in active package | Final exit 0; 35 files, 0 changed |
| `flutter analyze --no-pub` in active package | Final exit 0; no issues (2.3 s) |
| `flutter test --no-pub test/selection_lazy_build_test.dart --reporter expanded` | Exit 0; 2 passed after the final shrink-wrap change |
| `flutter test --no-pub test/field_state_contract_test.dart --reporter expanded` | Exit 0; 12 passed |
| `flutter test --no-pub test/select_interaction_test.dart --reporter expanded` | First concurrent invocation failed before running tests because generated `NativeAssetsManifest.json` was temporarily missing; serial rerun exit 0, 16 passed |
| `flutter test --no-pub test/selection_lazy_build_test.dart test/field_state_contract_test.dart test/select_interaction_test.dart --reporter expanded` | Final exit 0; 30 focused tests passed |
| `flutter test --no-pub --reporter expanded` in active package | Final exit 0; 124 passed |
| `flutter test --no-pub test/architecture/boundary_test.dart --reporter expanded` at workspace root | Final exit 0; 14 passed |
| `flutter test --no-pub test/workbench_test.dart --reporter expanded` at workspace root | Final exit 0; 3 passed |

The native-assets error was an environmental race from concurrent Flutter test processes, not a production assertion failure. Tests were rerun serially where needed. The profile benchmark is not a widget test, and widget-test passes were not used as frame-time evidence.

## Diff, compatibility, and remaining work

Step 04 changes only two production popup implementations in the active package and adds one lazy-build test plus `benchmark/profile_baseline.dart` and these two reports. The benchmark is non-exported and uses no new dependency. Existing Step 01–03 dirty working-tree changes and audit archives were preserved. Final `git diff --stat` shows the **combined** tracked working tree: five files, 246 insertions and 96 deletions; that statistic includes earlier steps and excludes untracked tests, benchmark, and reports. `git diff --check` exited 0 with no whitespace errors.

Unmeasured or unresolved: physical Android performance; repeated-run variance and memory allocation; isolated filter CPU/layout cost; scrolling and keyboard latency at 10,000 options; automatic popup focus transfer across platforms; autocomplete filtering on selection-only controller notifications; and async/paginated data handling. Those are not presented as improvements. A new asynchronous or paginated API would require separate contract design and approval. No next step was started.
