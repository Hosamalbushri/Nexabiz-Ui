// Isolated Step 02-P diagnostic. Run in Flutter profile mode on each target.
import 'dart:developer' as developer;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart' as rendering_debug;
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/widgets.dart' as widgets_debug;
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

enum Scenario {
  buttonPointer,
  iconPointer,
  loadingTransition,
  spinnerInsertion,
  buttonRebuild,
  iconTooltipPointer,
}

final _key = GlobalKey<_BenchState>();
final _timings = <ui.FrameTiming>[];
int _pointer = 1;
int _controlBuilds = 0;

class _CountedButton extends UiButton {
  const _CountedButton({
    required super.label,
    super.isLoading,
    super.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    _controlBuilds++;
    return super.build(context);
  }
}

class _CountedIconButton extends UiIconButton {
  const _CountedIconButton({
    required super.icon,
    required super.semanticLabel,
    super.tooltip,
    super.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    _controlBuilds++;
    return super.build(context);
  }
}

class _CountedSpinner extends UiSpinner {
  const _CountedSpinner();

  @override
  Widget build(BuildContext context) {
    _controlBuilds++;
    return super.build(context);
  }
}

class _Bench extends StatefulWidget {
  const _Bench({super.key});

  @override
  State<_Bench> createState() => _BenchState();
}

class _BenchState extends State<_Bench> {
  Scenario? scenario;
  bool ambient = false;
  bool loading = false;
  bool showSpinner = false;
  int revision = 0;
  int parentBuilds = 0;
  int callbacks = 0;

  void configure(Scenario? next, {required bool animated}) => setState(() {
    scenario = next;
    ambient = next != null && animated;
    loading = false;
    showSpinner = false;
    revision = 0;
  });

  void reset() => setState(() {
    loading = false;
    showSpinner = false;
  });

  void transition() => setState(() => loading = true);
  void insertSpinner() => setState(() => showSpinner = true);
  void rebuild() => setState(() => revision++);

  @override
  Widget build(BuildContext context) {
    parentBuilds++;
    Widget? control;
    switch (scenario) {
      case Scenario.buttonPointer ||
          Scenario.loadingTransition ||
          Scenario.buttonRebuild:
        control = _CountedButton(
          label: 'Save',
          isLoading: loading,
          onPressed: () => callbacks++,
        );
      case Scenario.iconPointer || Scenario.iconTooltipPointer:
        control = _CountedIconButton(
          icon: const Icon(IconData(0xe145, fontFamily: 'MaterialIcons')),
          semanticLabel: 'Add',
          tooltip: scenario == Scenario.iconTooltipPointer
              ? 'Add record'
              : null,
          onPressed: () => callbacks++,
        );
      case Scenario.spinnerInsertion:
        control = showSpinner
            ? const _CountedSpinner()
            : const SizedBox(width: 16, height: 16);
      case null:
        control = null;
    }
    return shadcn.Scaffold(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [?control, if (ambient) const UiSpinner()],
        ),
      ),
    );
  }
}

Element? _find(Element root, bool Function(Widget) test) {
  if (test(root.widget)) return root;
  Element? result;
  root.visitChildren((child) => result ??= _find(child, test));
  return result;
}

Future<void> _frame() async {
  SchedulerBinding.instance.scheduleFrame();
  await WidgetsBinding.instance.endOfFrame;
}

Future<void> _tap(Type type) async {
  final element = _find(
    WidgetsBinding.instance.rootElement!,
    (widget) => widget.runtimeType == type,
  )!;
  final box = element.renderObject! as RenderBox;
  final position = box.localToGlobal(box.size.center(Offset.zero));
  final pointer = _pointer++;
  final binding = GestureBinding.instance;
  developer.Timeline.timeSync('NEXA_pointer_dispatch', () {
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
  });
  await _frame();
}

Future<void> _sample(
  _BenchState state,
  Scenario scenario,
  bool ambient,
  int iteration, {
  required bool warmup,
}) async {
  if (scenario == Scenario.loadingTransition ||
      scenario == Scenario.spinnerInsertion) {
    state.reset();
    await _frame();
  }
  // FrameTiming callbacks are batched by the engine; allow prior batches to
  // arrive before attribution, then collect beyond one batching interval.
  await Future<void>.delayed(const Duration(milliseconds: 250));
  _timings.clear();
  _controlBuilds = 0;
  final beforeParent = state.parentBuilds;
  final beforeCallbacks = state.callbacks;
  final task = developer.TimelineTask()
    ..start('NEXA_${scenario.name}_${ambient ? 'animated' : 'quiet'}');
  final watch = Stopwatch()..start();
  switch (scenario) {
    case Scenario.buttonPointer:
      await _tap(_CountedButton);
    case Scenario.iconPointer || Scenario.iconTooltipPointer:
      await _tap(_CountedIconButton);
    case Scenario.loadingTransition:
      developer.Timeline.timeSync('NEXA_setState_loading', state.transition);
      await _frame();
    case Scenario.spinnerInsertion:
      developer.Timeline.timeSync('NEXA_setState_spinner', state.insertSpinner);
      await _frame();
    case Scenario.buttonRebuild:
      developer.Timeline.timeSync('NEXA_setState_rebuild', state.rebuild);
      await _frame();
  }
  watch.stop();
  task.finish();
  await Future<void>.delayed(const Duration(milliseconds: 250));
  final frames = List<ui.FrameTiming>.of(_timings);
  final build = frames.map((e) => e.buildDuration.inMicroseconds).toList();
  final raster = frames.map((e) => e.rasterDuration.inMicroseconds).toList();
  // ignore: avoid_print
  print(
    'ISO scenario=${scenario.name} env=${ambient ? 'animated' : 'quiet'} iteration=$iteration '
    'warmup=$warmup wall_us=${watch.elapsedMicroseconds} frames=${frames.length} '
    'build_us=${build.join(',')} raster_us=${raster.join(',')} '
    'parent_builds=${state.parentBuilds - beforeParent} control_builds=$_controlBuilds '
    'callbacks=${state.callbacks - beforeCallbacks}',
  );
}

Future<void> main() async {
  const mode = String.fromEnvironment('BENCH_MODE', defaultValue: 'both');
  const target = String.fromEnvironment('BENCH_SCENARIO', defaultValue: 'all');
  const traceWidgets = bool.fromEnvironment('TRACE_WIDGETS');
  if (traceWidgets) {
    // Diagnostic only: per-widget timeline events distort measured durations.
    widgets_debug.debugProfileBuildsEnabled = true;
    rendering_debug.debugProfileLayoutsEnabled = true;
    rendering_debug.debugProfilePaintsEnabled = true;
  }
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addTimingsCallback(_timings.addAll);
  runApp(shadcn.ShadcnApp(home: _Bench(key: _key)));
  await _frame();
  final state = _key.currentState!;
  if (mode == 'cold') {
    for (final scenario in Scenario.values.where(
      (value) => target == 'all' || value.name == target,
    )) {
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _timings.clear();
      final watch = Stopwatch()..start();
      state.configure(scenario, animated: false);
      await _frame();
      watch.stop();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      final build = _timings.map((e) => e.buildDuration.inMicroseconds);
      final raster = _timings.map((e) => e.rasterDuration.inMicroseconds);
      // ignore: avoid_print
      print(
        'ISO cold=${scenario.name} wall_us=${watch.elapsedMicroseconds} '
        'frames=${_timings.length} build_us=${build.join(',')} raster_us=${raster.join(',')}',
      );
      state.configure(null, animated: false);
      await _frame();
    }
    // ignore: avoid_print
    print('ISO complete');
    return;
  }
  for (final ambient in [
    false,
    true,
  ].where((value) => mode == 'both' || (mode == 'animated') == value)) {
    for (final scenario in Scenario.values.where(
      (value) => target == 'all' || value.name == target,
    )) {
      state.configure(scenario, animated: ambient);
      await _frame();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      for (var i = 0; i < 12; i++) {
        await _sample(state, scenario, ambient, i, warmup: i < 2);
      }
      state.configure(null, animated: false);
      await _frame();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      _timings.clear();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      // ignore: avoid_print
      print(
        'ISO idle_after=${scenario.name} env=${ambient ? 'animated' : 'quiet'} frames=${_timings.length}',
      );
    }
  }
  // ignore: avoid_print
  print('ISO complete');
}
