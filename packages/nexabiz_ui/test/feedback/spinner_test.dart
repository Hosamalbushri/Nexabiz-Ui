import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _wrap(
  Widget child, {
  TextScaler scaler = TextScaler.noScaling,
  TextDirection dir = TextDirection.ltr,
}) {
  return shadcn.ShadcnApp(
    home: Directionality(
      textDirection: dir,
      child: MediaQuery(
        data: MediaQueryData(textScaler: scaler),
        child: shadcn.Scaffold(child: Center(child: child)),
      ),
    ),
  );
}

void main() {
  group('UiSpinner Primitive Tests', () {
    testWidgets('unlabeled spinner does not synthesize an English label', (
      tester,
    ) async {
      await tester.pumpWidget(_wrap(const UiSpinner()));
      expect(tester.getSemantics(find.byType(UiSpinner)).label, isEmpty);
    });
    testWidgets('renders default spinner with accessibility semantics', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(const UiSpinner(semanticLabel: 'جارٍ التحميل')),
      );
      await tester.pump();

      expect(find.byType(UiSpinner), findsOneWidget);
      expect(find.byType(shadcn.CircularProgressIndicator), findsOneWidget);

      final semantics = tester.getSemantics(find.byType(UiSpinner));
      expect(semantics.label, equals('جارٍ التحميل'));
    });

    testWidgets('respects explicit size and color overrides', (tester) async {
      const customSize = 28.0;
      const customColor = Color(0xFF00FF00);

      await tester.pumpWidget(
        _wrap(const UiSpinner(size: customSize, color: customColor)),
      );
      await tester.pump();

      final indicatorFinder = find.byType(shadcn.CircularProgressIndicator);
      expect(indicatorFinder, findsOneWidget);

      final indicator = tester.widget<shadcn.CircularProgressIndicator>(
        indicatorFinder,
      );
      expect(indicator.size, equals(customSize));
      expect(indicator.color, equals(customColor));

      final size = tester.getSize(indicatorFinder);
      expect(size.width, equals(customSize));
      expect(size.height, equals(customSize));
    });

    testWidgets(
      'rebuilds cleanly with new size and color without leak or exception',
      (tester) async {
        await tester.pumpWidget(
          _wrap(const UiSpinner(size: 16.0, color: Color(0xFFFF0000))),
        );
        await tester.pump();

        expect(tester.getSize(find.byType(UiSpinner)).width, equals(16.0));

        await tester.pumpWidget(
          _wrap(const UiSpinner(size: 32.0, color: Color(0xFF0000FF))),
        );
        await tester.pump();

        expect(tester.getSize(find.byType(UiSpinner)).width, equals(32.0));
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('renders symmetrically under LTR and RTL', (tester) async {
      for (final dir in [TextDirection.ltr, TextDirection.rtl]) {
        await tester.pumpWidget(_wrap(const UiSpinner(), dir: dir));
        await tester.pump();

        expect(find.byType(UiSpinner), findsOneWidget);
        expect(tester.takeException(), isNull);
      }
    });
  });
}
