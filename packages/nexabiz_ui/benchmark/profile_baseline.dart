// Profile-mode field benchmark. Run from the workspace root with:
// flutter run --profile --no-pub -d linux -t packages/nexabiz_ui/benchmark/profile_baseline.dart
import 'dart:async';
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

final _benchmarkKey = GlobalKey<_BenchmarkState>();
final _frameTimings = <ui.FrameTiming>[];
var _pointer = 1;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addTimingsCallback(_frameTimings.addAll);
  runApp(shadcn.ShadcnApp(home: _Benchmark(key: _benchmarkKey)));
  await WidgetsBinding.instance.endOfFrame;
  await _run();
}

enum _Field { autocomplete, select, multiSelect }

class _Benchmark extends StatefulWidget {
  const _Benchmark({super.key});

  @override
  State<_Benchmark> createState() => _BenchmarkState();
}

class _BenchmarkState extends State<_Benchmark> {
  final controller = TextEditingController();
  final focusNode = FocusNode();
  _Field field = _Field.autocomplete;
  List<String> options = const [];
  String? selected;
  List<String> selectedMany = const [];

  void configure(_Field nextField, int count) {
    controller.clear();
    focusNode.unfocus();
    setState(() {
      field = nextField;
      options = List<String>.generate(
        count,
        (index) => 'Option ${index.toString().padLeft(5, '0')}',
        growable: false,
      );
      selected = options.first;
      selectedMany = [options.first];
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget control;
    switch (field) {
      case _Field.autocomplete:
        control = UiAutocompleteField(
          label: 'Search',
          controller: controller,
          focusNode: focusNode,
          suggestions: options,
        );
      case _Field.select:
        control = UiSelectField<String>(
          label: 'Select',
          items: options,
          value: selected,
          onChanged: (value) => setState(() => selected = value),
        );
      case _Field.multiSelect:
        control = UiMultiSelectField<String>(
          label: 'MultiSelect',
          items: options,
          value: selectedMany,
          onChanged: (value) => setState(() => selectedMany = value),
        );
    }
    return shadcn.Scaffold(
      child: Center(child: SizedBox(width: 400, child: control)),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    focusNode.dispose();
    super.dispose();
  }
}

Element? _find(Element root, bool Function(Widget) predicate) {
  if (predicate(root.widget)) return root;
  Element? result;
  root.visitChildren((child) {
    result ??= _find(child, predicate);
  });
  return result;
}

Future<void> _tap(Offset position) async {
  final pointer = _pointer++;
  final binding = GestureBinding.instance;
  binding.handlePointerEvent(
    PointerAddedEvent(pointer: pointer, position: position),
  );
  binding.handlePointerEvent(
    PointerDownEvent(pointer: pointer, position: position),
  );
  binding.handlePointerEvent(
    PointerUpEvent(pointer: pointer, position: position),
  );
  binding.handlePointerEvent(
    PointerRemovedEvent(pointer: pointer, position: position),
  );
  await WidgetsBinding.instance.endOfFrame;
}

Future<void> _tapSelect(_Field field) async {
  final root = WidgetsBinding.instance.rootElement!;
  final target = _find(
    root,
    (widget) => field == _Field.select
        ? widget is shadcn.Select<String>
        : widget is shadcn.Select<Iterable<String>>,
  );
  if (target == null) throw StateError('Select trigger not found');
  final box = target.renderObject! as RenderBox;
  await _tap(box.localToGlobal(box.size.center(Offset.zero)));
}

Future<void> _measure(String caseName, Future<void> Function() action) async {
  // Allow previously submitted frame timings to arrive before attribution.
  await Future<void>.delayed(const Duration(milliseconds: 120));
  _frameTimings.clear();
  final watch = Stopwatch()..start();
  await action();
  watch.stop();
  await Future<void>.delayed(const Duration(milliseconds: 120));
  final timings = List<ui.FrameTiming>.of(_frameTimings);
  final build = timings
      .map((timing) => timing.buildDuration.inMicroseconds)
      .join(',');
  final raster = timings
      .map((timing) => timing.rasterDuration.inMicroseconds)
      .join(',');
  // ignore: avoid_print
  print(
    'BENCH case=$caseName wall_us=${watch.elapsedMicroseconds} '
    'frames=${timings.length} build_us=$build raster_us=$raster',
  );
}

Future<void> _run() async {
  final state = _benchmarkKey.currentState!;
  for (final count in [10, 100, 1000, 10000]) {
    for (final field in _Field.values) {
      await _measure('${field.name}_$count.build', () async {
        state.configure(field, count);
        await WidgetsBinding.instance.endOfFrame;
      });
      if (field == _Field.autocomplete) {
        state.focusNode.requestFocus();
        await WidgetsBinding.instance.endOfFrame;
        for (final query in ['O', 'Op', 'Opt', 'Option 9']) {
          await _measure('${field.name}_$count.type_$query', () async {
            state.controller.text = query;
            await WidgetsBinding.instance.endOfFrame;
          });
        }
        state.focusNode.unfocus();
        await WidgetsBinding.instance.endOfFrame;
      } else {
        await _measure('${field.name}_$count.open', () => _tapSelect(field));
        await _measure(
          '${field.name}_$count.close',
          () => _tap(const Offset(5, 5)),
        );
      }
    }
  }
  // ignore: avoid_print
  print('BENCH complete');
}
