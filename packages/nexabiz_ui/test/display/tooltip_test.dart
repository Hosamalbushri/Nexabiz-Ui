import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget host(Widget child, {TextDirection direction = TextDirection.ltr}) =>
    shadcn.ShadcnApp(
      home: Directionality(
        textDirection: direction,
        child: shadcn.Scaffold(child: Center(child: child)),
      ),
    );

void main() {
  testWidgets('UiTooltip hover waits, opens once, and dismisses', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await tester.pumpWidget(
        host(
          const UiTooltip(
            message: 'تفاصيل',
            waitDuration: Duration(milliseconds: 100),
            child: SizedBox(width: 80, height: 40, child: Text('Target')),
          ),
          direction: direction,
        ),
      );
      await mouse.moveTo(tester.getCenter(find.text('Target')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 90));
      expect(find.text('تفاصيل'), findsNothing);
      await tester.pump(const Duration(milliseconds: 20));
      await tester.pump(const Duration(milliseconds: 250));
      expect(find.text('تفاصيل'), findsOneWidget);
      await mouse.moveTo(const Offset(0, 0));
      await tester.pumpAndSettle();
      expect(find.text('تفاصيل'), findsNothing);
      await mouse.removePointer();
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('UiTooltip keyboard focus, Escape, parent update and dispose', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        UiTooltip(
          message: 'Help A',
          child: shadcn.PrimaryButton(
            onPressed: () {},
            child: const Text('Button'),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Help A'), findsOneWidget);
    expect(tester.getSemantics(find.byType(UiTooltip)).tooltip, 'Help A');
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.text('Help A'), findsNothing);
    await tester.pumpWidget(
      host(
        UiTooltip(
          message: 'Help B',
          child: shadcn.PrimaryButton(
            onPressed: () {},
            child: const Text('Button'),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Help A'), findsNothing);
    expect(find.text('Help B'), findsOneWidget);
    await tester.pumpWidget(host(const Text('Gone')));
    await tester.pumpAndSettle();
    expect(find.text('Help B'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('UiTooltip outside tap dismisses and announces message once', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        UiTooltip(
          message: 'تفاصيل',
          child: shadcn.PrimaryButton(
            onPressed: () {},
            child: const Text('Target'),
          ),
        ),
      ),
    );
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('تفاصيل'), findsOneWidget);
    expect(tester.getSemantics(find.byType(UiTooltip)).tooltip, 'تفاصيل');
    await tester.tapAt(const Offset(8, 8));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('UiTooltip touch long-press opens and releases cleanly', (
    tester,
  ) async {
    await tester.pumpWidget(
      host(
        const UiTooltip(
          message: 'Details',
          child: SizedBox(width: 100, height: 50, child: Text('Target')),
        ),
      ),
    );
    final gesture = await tester.startGesture(
      tester.getCenter(find.text('Target')),
    );
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('Details'), findsOneWidget);
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.text('Details'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
