// Run with flutter run --profile -d DEVICE -t packages/nexabiz_ui/benchmark/visual_components_profile.dart.
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

enum Scenario {
  cardRebuild,
  badgeRebuild,
  avatarRebuild,
  dividerRebuild,
  chipPointer,
  tooltipHover,
}

final _key = GlobalKey<_BenchState>();
final _timings = <ui.FrameTiming>[];
int _pointer = 1;

class _Bench extends StatefulWidget {
  const _Bench({super.key});

  @override
  State<_Bench> createState() => _BenchState();
}

class _BenchState extends State<_Bench> {
  Scenario? scenario;
  int revision = 0;
  int callbacks = 0;

  void configure(Scenario? next) => setState(() {
    scenario = next;
    revision = 0;
  });

  void rebuild() => setState(() => revision++);

  @override
  Widget build(BuildContext context) {
    Widget? control;
    switch (scenario) {
      case Scenario.cardRebuild:
        control = UiCard(title: 'Record', child: Text('Value $revision'));
      case Scenario.badgeRebuild:
        control = UiBadge(label: 'Status $revision');
      case Scenario.avatarRebuild:
        control = UiAvatar(name: revision.isEven ? 'Jane Doe' : 'John Smith');
      case Scenario.dividerRebuild:
        control = UiDivider(thickness: revision.isEven ? 1 : 2);
      case Scenario.chipPointer:
        control = UiChip(
          label: const Text('Filter'),
          onPressed: () => callbacks++,
        );
      case Scenario.tooltipHover:
        control = const UiTooltip(
          message: 'Details',
          waitDuration: Duration.zero,
          child: SizedBox(width: 100, height: 48, child: Text('Hover target')),
        );
      case null:
        control = null;
    }
    return shadcn.Scaffold(child: Center(child: control));
  }
}

Element? _find(Element root, bool Function(Widget) predicate) {
  if (predicate(root.widget)) return root;
  Element? found;
  root.visitChildren((child) => found ??= _find(child, predicate));
  return found;
}

Offset _center(Type type) {
  final element = _find(
    WidgetsBinding.instance.rootElement!,
    (widget) => widget.runtimeType == type,
  )!;
  final box = element.renderObject! as RenderBox;
  return box.localToGlobal(box.size.center(Offset.zero));
}

Future<void> _frame() async {
  SchedulerBinding.instance.scheduleFrame();
  await WidgetsBinding.instance.endOfFrame;
}

Future<void> _act(_BenchState state, Scenario scenario) async {
  if (scenario == Scenario.chipPointer) {
    final position = _center(UiChip);
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
  } else if (scenario == Scenario.tooltipHover) {
    final position = _center(UiTooltip);
    GestureBinding.instance.handlePointerEvent(
      PointerAddedEvent(
        pointer: 900,
        kind: PointerDeviceKind.mouse,
        position: const Offset(0, 0),
      ),
    );
    GestureBinding.instance.handlePointerEvent(
      PointerHoverEvent(
        pointer: 900,
        kind: PointerDeviceKind.mouse,
        position: position,
      ),
    );
  } else {
    state.rebuild();
  }
  await _frame();
}

Future<void> _sample(
  _BenchState state,
  Scenario scenario,
  int iteration,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 250));
  _timings.clear();
  final beforeCallbacks = state.callbacks;
  final timeline = developer.TimelineTask()
    ..start('NEXA_VISUAL_${scenario.name}');
  final watch = Stopwatch()..start();
  await _act(state, scenario);
  watch.stop();
  timeline.finish();
  await Future<void>.delayed(const Duration(milliseconds: 250));
  final build = _timings.map((e) => e.buildDuration.inMicroseconds).join(',');
  final raster = _timings.map((e) => e.rasterDuration.inMicroseconds).join(',');
  // ignore: avoid_print
  print(
    'VISUAL scenario=${scenario.name} iteration=$iteration warmup=${iteration < 2} '
    'wall_us=${watch.elapsedMicroseconds} frames=${_timings.length} '
    'build_us=$build raster_us=$raster callbacks=${state.callbacks - beforeCallbacks}',
  );
  if (scenario == Scenario.tooltipHover) {
    GestureBinding.instance.handlePointerEvent(
      const PointerRemovedEvent(pointer: 900, kind: PointerDeviceKind.mouse),
    );
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}

Future<void> main() async {
  const scenarioFilter = String.fromEnvironment(
    'BENCH_SCENARIO',
    defaultValue: 'all',
  );
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addTimingsCallback(_timings.addAll);
  runApp(shadcn.ShadcnApp(home: _Bench(key: _key)));
  await _frame();
  final state = _key.currentState!;
  for (final scenario in Scenario.values.where(
    (value) => scenarioFilter == 'all' || value.name == scenarioFilter,
  )) {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    _timings.clear();
    final watch = Stopwatch()..start();
    state.configure(scenario);
    await _frame();
    watch.stop();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // ignore: avoid_print
    print(
      'VISUAL cold=${scenario.name} wall_us=${watch.elapsedMicroseconds} '
      'frames=${_timings.length} '
      'build_us=${_timings.map((e) => e.buildDuration.inMicroseconds).join(',')} '
      'raster_us=${_timings.map((e) => e.rasterDuration.inMicroseconds).join(',')}',
    );
    for (var i = 0; i < 12; i++) {
      await _sample(state, scenario, i);
    }
    state.configure(null);
    await _frame();
    await Future<void>.delayed(const Duration(milliseconds: 350));
    _timings.clear();
    await Future<void>.delayed(const Duration(milliseconds: 250));
    // ignore: avoid_print
    print('VISUAL idle_after=${scenario.name} frames=${_timings.length}');
  }
  // ignore: avoid_print
  print('VISUAL complete');
}
