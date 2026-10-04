import 'dart:ui' show Tristate;

import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
}) => shadcn.ShadcnApp(
  home: Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: shadcn.Scaffold(child: Center(child: child)),
    ),
  ),
);

void main() {
  testWidgets('button pointer and keyboard activation occur once each', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(UiButton(label: 'حفظ', onPressed: () => calls++)),
    );
    await tester.tap(find.byType(UiButton));
    await tester.pump();
    expect(calls, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(calls, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(calls, 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'disabled and loading button suppress activation and have caller semantics',
    (tester) async {
      var calls = 0;
      for (final button in <UiButton>[
        UiButton(label: 'حفظ', enabled: false, onPressed: () => calls++),
        UiButton(
          label: 'حفظ',
          isLoading: true,
          loadingSemanticLabel: 'جارٍ الحفظ',
          onPressed: () => calls++,
        ),
      ]) {
        await tester.pumpWidget(host(button));
        await tester.tap(find.byType(UiButton));
        await tester.sendKeyEvent(LogicalKeyboardKey.enter);
        await tester.pump();
        expect(calls, 0);
        final semantics = tester.getSemantics(find.byType(UiButton));
        expect(semantics.label, button.isLoading ? 'جارٍ الحفظ' : 'حفظ');
        expect(semantics.flagsCollection.isEnabled, Tristate.isFalse);
      }
    },
  );

  testWidgets(
    'loading defaults to original localized name and preserves size',
    (tester) async {
      await tester.pumpWidget(host(const UiButton(label: 'حفظ')));
      final normal = tester.getSize(find.byType(UiButton));
      await tester.pumpWidget(
        host(const UiButton(label: 'حفظ', isLoading: true)),
      );
      final busy = tester.getSize(find.byType(UiButton));
      expect(busy, normal);
      expect(tester.getSemantics(find.byType(UiButton)).label, 'حفظ');
      expect(find.byType(UiSpinner), findsOneWidget);
    },
  );

  testWidgets('all named constructors accept loading label and variants', (
    tester,
  ) async {
    final buttons = <UiButton>[
      const UiButton.outline(
        label: 'أ',
        isLoading: true,
        loadingSemanticLabel: 'جاري أ',
      ),
      const UiButton.ghost(
        label: 'ب',
        isLoading: true,
        loadingSemanticLabel: 'جاري ب',
      ),
      const UiButton.destructive(
        label: 'ج',
        isLoading: true,
        loadingSemanticLabel: 'جاري ج',
      ),
    ];
    for (final button in buttons) {
      await tester.pumpWidget(host(button));
      expect(
        tester.getSemantics(find.byType(UiButton)).label,
        button.loadingSemanticLabel,
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'loading button exposes one accessible name without nested progress',
    (tester) async {
      await tester.pumpWidget(
        host(
          const UiButton(
            label: 'حفظ',
            isLoading: true,
            loadingSemanticLabel: 'جارٍ الحفظ',
          ),
        ),
      );
      final buttonNode = tester.getSemantics(find.byType(UiButton));
      expect(buttonNode.label, 'جارٍ الحفظ');
      expect(buttonNode.childrenCountInTraversalOrder, 0);
    },
  );

  testWidgets('RTL and LTR at large text scale render without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final direction in TextDirection.values) {
      await tester.pumpWidget(
        host(
          const UiButton(
            label: 'حفظ',
            leadingIcon: Icon(IconData(0xe145, fontFamily: 'MaterialIcons')),
          ),
          direction: direction,
          scale: 2,
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('icon button pointer, keyboard, disabled, and semantics', (
    tester,
  ) async {
    var calls = 0;
    await tester.pumpWidget(
      host(
        UiIconButton(
          icon: const Icon(IconData(0xe145, fontFamily: 'MaterialIcons')),
          semanticLabel: 'إضافة',
          tooltip: 'إضافة سجل',
          onPressed: () => calls++,
        ),
      ),
    );
    expect(tester.getSemantics(find.byType(UiIconButton)).label, 'إضافة');
    expect(tester.getSemantics(find.byType(UiIconButton)).tooltip, 'إضافة سجل');
    expect(find.byType(shadcn.Tooltip), findsOneWidget);
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(find.byType(UiIconButton)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.text('إضافة سجل'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.byType(UiIconButton));
    await tester.pump();
    expect(calls, 1);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(calls, 2);
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pump();
    expect(calls, 3);
    await tester.pumpWidget(
      host(
        UiIconButton(
          icon: const Icon(IconData(0xe145, fontFamily: 'MaterialIcons')),
          semanticLabel: 'إضافة',
          enabled: false,
          onPressed: () => calls++,
        ),
      ),
    );
    await tester.tap(find.byType(UiIconButton));
    expect(calls, 3);
  });
}
