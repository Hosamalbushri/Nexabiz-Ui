// Run from workspace root in profile mode on each target separately.
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

final _key = GlobalKey<_BenchState>();
final _timings = <ui.FrameTiming>[];
int _pointer = 1;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  WidgetsBinding.instance.addTimingsCallback(_timings.addAll);
  runApp(shadcn.ShadcnApp(home: _Bench(key: _key)));
  await WidgetsBinding.instance.endOfFrame;
  await _run();
}

class _Bench extends StatefulWidget {
  const _Bench({super.key});

  @override
  State<_Bench> createState() => _BenchState();
}

class _BenchState extends State<_Bench> {
  int count = 0;
  bool loading = false;
  bool showSpinner = false;

  void change({bool? loading, bool? showSpinner}) => setState(() {
    if (loading != null) this.loading = loading;
    if (showSpinner != null) this.showSpinner = showSpinner;
  });

  @override
  Widget build(BuildContext context) => shadcn.Scaffold(
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          UiButton(
            label: 'Save',
            isLoading: loading,
            onPressed: () => setState(() => count++),
          ),
          UiIconButton(
            icon: const Icon(IconData(0xe145, fontFamily: 'MaterialIcons')),
            semanticLabel: 'Add',
            onPressed: () => setState(() => count++),
          ),
          if (showSpinner) const UiSpinner(semanticLabel: 'Loading'),
        ],
      ),
    ),
  );
}

Element? _find(Element root, bool Function(Widget) test) {
  if (test(root.widget)) return root;
  Element? result;
  root.visitChildren((child) => result ??= _find(child, test));
  return result;
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

Future<void> _measure(
  String name,
  int iteration,
  Future<void> Function() action,
) async {
  await Future<void>.delayed(const Duration(milliseconds: 120));
  _timings.clear();
  final watch = Stopwatch()..start();
  await action();
  watch.stop();
  await Future<void>.delayed(const Duration(milliseconds: 120));
  final frames = List<ui.FrameTiming>.of(_timings);
  // ignore: avoid_print
  print(
    'BENCH case=$name iteration=$iteration wall_us=${watch.elapsedMicroseconds} '
    'frames=${frames.length} build_us=${frames.map((e) => e.buildDuration.inMicroseconds).join(',')} '
    'raster_us=${frames.map((e) => e.rasterDuration.inMicroseconds).join(',')}',
  );
}

Future<void> _run() async {
  final state = _key.currentState!;
  for (var i = 1; i <= 10; i++) {
    await _measure('button_build', i, () async {
      state.change(loading: false);
      await WidgetsBinding.instance.endOfFrame;
    });
    await _measure('button_pointer', i, () => _tap(UiButton));
    await _measure('icon_pointer', i, () => _tap(UiIconButton));
    await _measure('button_loading', i, () async {
      state.change(loading: true);
      await WidgetsBinding.instance.endOfFrame;
    });
    await _measure('spinner_build', i, () async {
      state.change(showSpinner: true);
      await WidgetsBinding.instance.endOfFrame;
    });
    state.change(showSpinner: false);
    await WidgetsBinding.instance.endOfFrame;
  }
  // ignore: avoid_print
  print('BENCH complete');
}
