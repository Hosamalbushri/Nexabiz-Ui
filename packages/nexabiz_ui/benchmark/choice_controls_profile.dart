// Run in profile mode. Each case has two warm-ups and ten measured iterations.
// Pointer events use Flutter's gesture binding; they exclude OS input latency.
import 'dart:async';
import 'dart:io';
import 'dart:ui' show FrameTiming;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const shadcn.ShadcnApp(home: _Bench()));
}

class _Bench extends StatefulWidget {
  const _Bench();

  @override
  State<_Bench> createState() => _BenchState();
}

class _BenchState extends State<_Bench> {
  final _controlKey = GlobalKey();
  final _frames = <FrameTiming>[];
  String _scenario = 'none';
  bool _checkbox = false;
  bool _switch = false;
  int _radio = 0;
  double _slider = .25;
  int _pointer = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addTimingsCallback(_record);
    WidgetsBinding.instance.addPostFrameCallback((_) => unawaited(_run()));
  }

  void _record(List<FrameTiming> timings) => _frames.addAll(timings);

  Future<void> _pointerTap({double fraction = .5}) async {
    final box = _controlKey.currentContext!.findRenderObject()! as RenderBox;
    final point = box.localToGlobal(
      Offset(box.size.width * fraction, box.size.height / 2),
    );
    final binding = GestureBinding.instance;
    final id = _pointer++;
    binding.handlePointerEvent(PointerDownEvent(pointer: id, position: point));
    binding.handlePointerEvent(PointerUpEvent(pointer: id, position: point));
  }

  Future<void> _run() async {
    for (final scenario in ['checkbox', 'switch', 'radio', 'slider']) {
      if (!mounted) return;
      setState(() => _scenario = scenario);
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 500));
      for (var iteration = 0; iteration < 12; iteration++) {
        _frames.clear();
        final stopwatch = Stopwatch()..start();
        switch (scenario) {
          case 'checkbox':
          case 'switch':
            await _pointerTap();
          case 'slider':
            await _pointerTap(fraction: iteration.isEven ? .75 : .25);
          case 'radio':
            setState(() => _radio = 1 - _radio);
        }
        await WidgetsBinding.instance.endOfFrame;
        stopwatch.stop();
        await Future<void>.delayed(const Duration(milliseconds: 350));
        final build = _frames.fold<int>(
          0,
          (max, frame) => frame.buildDuration.inMicroseconds > max
              ? frame.buildDuration.inMicroseconds
              : max,
        );
        final raster = _frames.fold<int>(
          0,
          (max, frame) => frame.rasterDuration.inMicroseconds > max
              ? frame.rasterDuration.inMicroseconds
              : max,
        );
        // ignore: avoid_print
        print(
          'CHOICE platform=${Platform.operatingSystem} scenario=$scenario '
          'iteration=$iteration warm=${iteration >= 2} frames=${_frames.length} '
          'wall_us=${stopwatch.elapsedMicroseconds} build_us=$build raster_us=$raster',
        );
      }
      setState(() => _scenario = 'none');
      await WidgetsBinding.instance.endOfFrame;
      await Future<void>.delayed(const Duration(milliseconds: 350));
      _frames.clear();
      await Future<void>.delayed(const Duration(milliseconds: 250));
      // ignore: avoid_print
      print(
        'CHOICE idle platform=${Platform.operatingSystem} scenario=$scenario frames=${_frames.length}',
      );
    }
    // ignore: avoid_print
    print('CHOICE complete');
    WidgetsBinding.instance.removeTimingsCallback(_record);
    exit(0);
  }

  @override
  Widget build(BuildContext context) => shadcn.Scaffold(
    child: Center(
      child: SizedBox(
        width: 300,
        child: switch (_scenario) {
          'checkbox' => UiCheckbox(
            key: _controlKey,
            value: _checkbox,
            semanticLabel: 'Choice',
            onChanged: (next) => setState(() => _checkbox = next ?? false),
          ),
          'switch' => UiSwitch(
            key: _controlKey,
            value: _switch,
            semanticLabel: 'Switch',
            onChanged: (next) => setState(() => _switch = next),
          ),
          'radio' => UiRadioGroup<int>(
            options: const [
              UiRadioOption(value: 0, label: 'First'),
              UiRadioOption(value: 1, label: 'Second'),
            ],
            value: _radio,
            semanticLabel: 'Radio',
            onChanged: (next) => setState(() => _radio = next),
          ),
          'slider' => UiSlider(
            key: _controlKey,
            value: _slider,
            semanticLabel: 'Slider',
            onChanged: (next) => setState(() => _slider = next),
          ),
          _ => const SizedBox.shrink(),
        },
      ),
    ),
  );
}
