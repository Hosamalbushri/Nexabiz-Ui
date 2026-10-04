import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget host(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
  double scale = 1,
  double width = 280,
}) => shadcn.ShadcnApp(
  home: Directionality(
    textDirection: direction,
    child: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(scale)),
      child: shadcn.Scaffold(
        child: SingleChildScrollView(
          child: Center(
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets(
    'visuals fit 320/420/960 hosts at 1.5x and 2x in both directions',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      for (final width in [320.0, 420.0, 960.0]) {
        tester.view.physicalSize = Size(width, 900);
        for (final scale in [1.5, 2.0]) {
          for (final direction in TextDirection.values) {
            await tester.pumpWidget(
              host(
                const UiCard(
                  title: 'سجل طويل نسبياً',
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UiBadge(
                        label: 'قيد المراجعة',
                        variant: UiBadgeVariant.destructive,
                      ),
                      UiDivider(),
                      UiAvatar(name: 'محمد علي', size: UiAvatarSize.lg),
                      UiChip(label: Text('وسم')),
                      UiTooltip(message: 'تفاصيل', child: Text('مساعدة')),
                    ],
                  ),
                ),
                direction: direction,
                scale: scale,
                width: width - 40,
              ),
            );
            expect(
              tester.takeException(),
              isNull,
              reason: 'width=$width scale=$scale direction=$direction',
            );
          }
        }
      }
    },
  );

  testWidgets('UiCard composes approved slots and updates without overflow', (
    tester,
  ) async {
    for (final direction in TextDirection.values) {
      await tester.pumpWidget(
        host(
          const UiCard(
            title: 'العنوان',
            description: 'الوصف',
            header: Text('Header'),
            actions: Text('Action'),
            footer: Text('Footer'),
            child: Text('Record A'),
          ),
          direction: direction,
          scale: 2,
        ),
      );
      expect(find.text('العنوان'), findsOneWidget);
      expect(find.text('الوصف'), findsOneWidget);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Footer'), findsOneWidget);
      expect(find.text('Record A'), findsOneWidget);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(host(const UiCard(child: Text('Record B'))));
    expect(find.text('Record A'), findsNothing);
    expect(find.text('Record B'), findsOneWidget);
  });

  testWidgets('UiBadge maps four variants and has one caller-owned name', (
    tester,
  ) async {
    for (final variant in UiBadgeVariant.values) {
      await tester.pumpWidget(host(UiBadge(label: 'نشط', variant: variant)));
      expect(find.text('نشط'), findsOneWidget);
      expect(tester.getSemantics(find.byType(UiBadge)).label, 'نشط');
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('UiDivider is decorative unless labeled, both orientations', (
    tester,
  ) async {
    await tester.pumpWidget(host(const UiDivider()));
    expect(tester.getSemantics(find.byType(UiDivider)).label, isEmpty);
    await tester.pumpWidget(
      host(
        const SizedBox(
          height: 80,
          child: UiDivider(
            orientation: UiDividerOrientation.vertical,
            margin: EdgeInsetsDirectional.only(start: 8),
            thickness: 2,
            semanticLabel: 'مجموعات',
          ),
        ),
        direction: TextDirection.rtl,
      ),
    );
    expect(tester.getSemantics(find.byType(UiDivider)).label, 'مجموعات');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'UiAvatar handles sizes, Arabic, combining marks and empty names',
    (tester) async {
      for (final size in UiAvatarSize.values) {
        await tester.pumpWidget(host(UiAvatar(name: 'محمد علي', size: size)));
        expect(find.text('مع'), findsOneWidget);
        expect(tester.getSemantics(find.byType(UiAvatar)).label, 'محمد علي');
        expect(tester.takeException(), isNull);
      }
      await tester.pumpWidget(
        host(
          const UiAvatar(name: 'e\u0301mile Smith', semanticLabel: 'Person'),
        ),
      );
      expect(find.text('E\u0301S'), findsOneWidget);
      expect(tester.getSemantics(find.byType(UiAvatar)).label, 'Person');
      await tester.pumpWidget(host(const UiAvatar(name: '')));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(host(const UiAvatar(name: 'John Doe')));
      expect(find.text('JD'), findsOneWidget);
    },
  );
}
