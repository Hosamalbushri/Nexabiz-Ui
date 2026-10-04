# Phase 01 / Step 04 — Profile baseline

## Environment and method

- Target: Linux desktop (`linux-x64`), Kali GNU/Linux Rolling kernel `6.18.12+kali-amd64`, Mesa Intel HD Graphics 630 (KBL GT2). The connected Android 13 device was not used; results are **not** Android measurements.
- SDK: Flutter 3.44.4 stable (framework `ad70ec4617`), Dart 3.12.2, resolved `shadcn_flutter 0.0.53`.
- Build: `flutter run --profile --no-pub -d linux -t packages/nexabiz_ui/benchmark/profile_baseline.dart` from the workspace root. The benchmark entrypoint lives in the active package; the root app only supplies its existing Linux host and package resolution. No dependency was added.
- Data: `Option 00000` through `Option N-1` for N = 10, 100, 1,000, 10,000. The harness configures each field, enters autocomplete queries `O`, `Op`, `Opt`, `Option 9`, and injects pointer down/up events at the actual select trigger and outside it. `FrameTiming` reports build and raster durations. The harness reports wall time through the first `endOfFrame` and waits 120 ms before and after an action to attribute timing batches. This pacing is benchmark-only, not a UI debounce.
- This is **one profile run per configuration**, with no statistical repetition. Frame timing batches can include popup animation and adjacent frames; `build_us` and `raster_us` below are raw per-frame arrays, not pure filter/layout durations. There is no reliable isolated filter CPU or layout-only measurement, no measured scrolling/keyboard latency, and no memory trace. Small differences must not be treated as demonstrated improvements or regressions.

## Source analysis before change

`UiAutocompleteField` (`lib/src/fields/autocomplete_field.dart:47–121`) listens to every controller change and calls `setState`, then filters in `build`; non-empty queries lowercase every candidate and allocate a new list. A cursor/selection-only controller notification can therefore re-run filtering. Upstream `AutoComplete` (`shadcn_flutter-0.0.53/lib/src/components/form/autocomplete.dart:295–520`) compares old/new suggestion lists in `didUpdateWidget`, manages an overlay, and renders suggestions through `ListView.builder`. This is O(N) local search by design; no time-based throttle exists. The Workbench uses only five suggestions (`lib/main.dart:570–580`), and the prior widget test exercised up to 1,000 without timing (`test/autocomplete_field_test.dart`).

`UiSelectField` and `UiMultiSelectField` (pre-change popup blocks around `select_field.dart:116`, `multi_select_field.dart:131`) created one `SelectGroup` with every option button, then placed that group as one `SelectItemList` child. Upstream `SelectPopup` uses a lazy `ListView.builder` over delegate children (`shadcn_flutter-0.0.53/lib/src/components/form/select.dart:1970–2070`), but the single child eagerly constructs and lays out all option buttons. The prior Workbench has only four options per field; existing interaction tests did not include large lists.

## Raw pre-change profile output

Numbers are microseconds. `build_us` and `raster_us` preserve every timing in each action's reported batch. An empty field was not interpreted as zero work.

```text
BENCH case=autocomplete_10.build wall_us=41500 frames=4 build_us=821,145,1418,1129 raster_us=453,1043,1819,5260
BENCH case=autocomplete_10.type_O wall_us=5598 frames=7 build_us=1192,406,440,781,578,2485,388 raster_us=1389,411,556,953,502,10253,903
BENCH case=autocomplete_10.type_Op wall_us=16958 frames=1 build_us=902 raster_us=661
BENCH case=autocomplete_10.type_Opt wall_us=6625 frames=1 build_us=1354 raster_us=752
BENCH case=autocomplete_10.type_Option 9 wall_us=6615 frames=2 build_us=1422,419 raster_us=699,599
BENCH case=select_10.build wall_us=12066 frames=3 build_us=381,1251,138 raster_us=575,742,376
BENCH case=select_10.open wall_us=10816 frames=7 build_us=5108,743,163,188,399,525,229 raster_us=584,17423,1471,1832,775,1181,5539
BENCH case=select_10.close wall_us=3924 frames=7 build_us=317,757,282,358,220,204,388 raster_us=459,903,553,1001,667,520,860
BENCH case=multiSelect_10.build wall_us=7428 frames=2 build_us=2704,662 raster_us=1781,894
BENCH case=multiSelect_10.open wall_us=36459 frames=7 build_us=16504,1437,325,219,206,202,183 raster_us=1093,2365,1088,642,741,602,577
BENCH case=multiSelect_10.close wall_us=8141 frames=7 build_us=313,1204,519,464,346,577,472 raster_us=1113,1073,1332,1650,944,1622,1570
BENCH case=autocomplete_100.build wall_us=7116 frames=2 build_us=2404,728 raster_us=698,484
BENCH case=autocomplete_100.type_O wall_us=9013 frames=4 build_us=517,1390,462,423 raster_us=637,665,647,549
BENCH case=autocomplete_100.type_Op wall_us=10100 frames=1 build_us=3726 raster_us=1289
BENCH case=autocomplete_100.type_Opt wall_us=20638 frames=1 build_us=2325 raster_us=1183
BENCH case=autocomplete_100.type_Option 9 wall_us=21982 frames=2 build_us=2555,577 raster_us=1124,1324
BENCH case=select_100.build wall_us=12199 frames=3 build_us=408,994,188 raster_us=475,510,451
BENCH case=select_100.open wall_us=83861 frames=5 build_us=62586,1472,195,121,151 raster_us=570,453,460,377,360
BENCH case=select_100.close wall_us=16076 frames=6 build_us=217,216,2799,375,319,402 raster_us=756,715,1048,926,984,909
BENCH case=multiSelect_100.build wall_us=17812 frames=3 build_us=387,2801,728 raster_us=644,940,793
BENCH case=multiSelect_100.open wall_us=66572 frames=5 build_us=46834,2079,298,178,151 raster_us=442,643,554,823,908
BENCH case=multiSelect_100.close wall_us=13419 frames=6 build_us=304,394,2221,396,362,708 raster_us=1342,1078,1619,984,1427,868
BENCH case=autocomplete_1000.build wall_us=15583 frames=3 build_us=154,2147,933 raster_us=945,671,853
BENCH case=autocomplete_1000.type_O wall_us=10071 frames=4 build_us=630,2127,645,507 raster_us=977,896,742,775
BENCH case=autocomplete_1000.type_Op wall_us=23620 frames=1 build_us=2694 raster_us=1206
BENCH case=autocomplete_1000.type_Opt wall_us=22852 frames=1 build_us=2969 raster_us=1208
BENCH case=autocomplete_1000.type_Option 9 wall_us=22214 frames=2 build_us=2842,679 raster_us=1291,1594
BENCH case=select_1000.build wall_us=9646 frames=3 build_us=449,1207,152 raster_us=703,642,592
BENCH case=select_1000.open wall_us=364592 frames=2 build_us=356133,11250 raster_us=438,602
BENCH case=select_1000.close wall_us=92570 frames=2 build_us=120,6010 raster_us=411,539
BENCH case=multiSelect_1000.build wall_us=16568 frames=2 build_us=2239,596 raster_us=1296,1030
BENCH case=multiSelect_1000.open wall_us=395523 frames=2 build_us=374953,9441 raster_us=444,512
BENCH case=multiSelect_1000.close wall_us=119960 frames=3 build_us=300,349,10478 raster_us=761,738,1602
BENCH case=autocomplete_10000.build wall_us=16214 frames=2 build_us=3387,1571 raster_us=991,1168
BENCH case=autocomplete_10000.type_O wall_us=10810 frames=4 build_us=504,3354,497,439 raster_us=627,670,586,602
BENCH case=autocomplete_10000.type_Op wall_us=25966 frames=1 build_us=6633 raster_us=1067
BENCH case=autocomplete_10000.type_Opt wall_us=23177 frames=1 build_us=6671 raster_us=1133
BENCH case=autocomplete_10000.type_Option 9 wall_us=22506 frames=2 build_us=6099,670 raster_us=1125,1020
BENCH case=select_10000.build wall_us=9984 frames=3 build_us=389,1769,200 raster_us=527,632,635
BENCH case=select_10000.open wall_us=3763107 frames=1 build_us=3725461 raster_us=1289
BENCH case=select_10000.close wall_us=10326 frames=2 build_us=170286,231 raster_us=426,403
BENCH case=multiSelect_10000.build wall_us=6868 frames=1 build_us=1330 raster_us=474
BENCH case=multiSelect_10000.open wall_us=3683126 frames=1 build_us=3659813 raster_us=885
```

The profile connection ended before the `multiSelect_10000.close` and `BENCH complete` lines. The cause of disconnection was not determined; it is not evidence of an out-of-memory failure by itself.

## Baseline conclusion and limits

The 1,000- and 10,000-option opening build durations are far beyond a 16.7 ms frame budget, while raster time is small in the same recorded frames. A separate pre-fix widget test counted **1,001** item-builder calls for a 1,000-option single select and **1,000** for multi-select; the single-select extra call is the displayed selected value. The popup's eager group construction is therefore a demonstrated scalability defect, not merely a theoretical concern. Autocomplete's O(N) filtering is a plausible future target, but this one-run profile did not establish that it exceeds budget on this Linux target; no autocomplete optimization was authorized by this evidence.
