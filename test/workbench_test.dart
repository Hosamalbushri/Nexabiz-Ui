import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:nexabiz_ui_foundation/main.dart';

void main() {
  testWidgets(
    'Workbench remains usable on a 320 pixel viewport at 200 percent',
    (tester) async {
      tester.view.physicalSize = const Size(320, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const FoundationWorkbench());
      await tester.pumpAndSettle();
      for (final key in ['content', 'direction', 'scale-2.0', 'validate']) {
        await tester.ensureVisible(find.byKey(ValueKey(key)));
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      final error = find.textContaining(
        'Enter a display name before continuing.',
      );
      await tester.ensureVisible(error);
      await tester.pumpAndSettle();
      expect(error.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'external workbench exercises theme direction scale and validation',
    (tester) async {
      tester.view.physicalSize = const Size(1920, 1800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const FoundationWorkbench());
      await tester.pumpAndSettle();
      expect(find.text('Local host: 420 • compact'), findsOneWidget);
      for (final key in [
        'theme',
        'direction',
        'content',
        'scale-1.5',
        'scale-2.0',
        'validate',
      ]) {
        await tester.ensureVisible(find.byKey(ValueKey(key)));
        await tester.tap(find.byKey(ValueKey(key)));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      expect(find.text('Dark theme'), findsOneWidget);
      final fieldContext = tester.element(find.byType(UiTextField).first);
      expect(Directionality.of(fieldContext), TextDirection.rtl);
      expect(MediaQuery.textScalerOf(fieldContext).scale(16), 32);
      expect(
        find.textContaining('Enter a display name before continuing.'),
        findsOneWidget,
      );
      await tester.ensureVisible(find.byKey(const ValueKey('width')));
      await tester.tap(find.byKey(const ValueKey('width')));
      await tester.pumpAndSettle();
      expect(find.text('Local host: 960 • medium'), findsOneWidget);
      await tester.ensureVisible(find.byKey(const ValueKey('reset')));
      await tester.tap(find.byKey(const ValueKey('reset')));
      await tester.pumpAndSettle();
      expect(
        find.textContaining('Enter a display name before continuing.'),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
