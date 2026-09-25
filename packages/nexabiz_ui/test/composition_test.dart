import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget host(
  Widget child, {
  double width = 420,
  double scale = 1,
  TextDirection direction = TextDirection.ltr,
  shadcn.ThemeData? theme,
}) => shadcn.ShadcnApp(
  scaling: const shadcn.AdaptiveScaling(1),
  theme: theme ?? shadcn.ThemeData(colorScheme: shadcn.ColorSchemes.lightSlate),
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: Directionality(
        textDirection: direction,
        child: SingleChildScrollView(
          child: Align(
            alignment: AlignmentDirectional.topStart,
            child: SizedBox(width: width, child: child),
          ),
        ),
      ),
    ),
  ),
);

void main() {
  group('UiContent Tests', () {
    testWidgets(
      'enforces max width and directional padding under local constraints',
      (tester) async {
        await tester.pumpWidget(
          host(
            const UiContent(
              maxWidth: 400,
              padding: EdgeInsetsDirectional.all(16),
              child: SizedBox(
                key: ValueKey('inner'),
                width: double.infinity,
                height: 100,
              ),
            ),
            width: 960,
          ),
        );
        expect(tester.takeException(), isNull);
        final innerSize = tester.getSize(find.byKey(const ValueKey('inner')));
        expect(
          innerSize.width,
          400 - 32,
        ); // 400 max width minus 32 horizontal padding
      },
    );

    testWidgets('scales child cleanly with TextScale 2.0', (tester) async {
      await tester.pumpWidget(
        host(
          const UiContent(
            child: Text(
              'Content block inside bounded container with large text scale',
            ),
          ),
          scale: 2.0,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.textContaining('Content block'), findsOneWidget);
    });
  });

  group('UiSection Tests', () {
    testWidgets('renders heading, description, trailing and child content', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const UiSection(
            title: 'Account Settings',
            description: 'Manage your profile and security settings.',
            trailing: Text('Action'),
            child: Text('Section Body Content'),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Account Settings'), findsOneWidget);
      expect(
        find.text('Manage your profile and security settings.'),
        findsOneWidget,
      );
      expect(find.text('Action'), findsOneWidget);
      expect(find.text('Section Body Content'), findsOneWidget);
    });

    testWidgets('applies accessible header semantics on title', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const UiSection(title: 'Accessible Section Title', child: SizedBox()),
        ),
      );
      expect(find.bySemanticsLabel('Accessible Section Title'), findsOneWidget);
      final semantics = tester.getSemantics(
        find.text('Accessible Section Title'),
      );
      expect(semantics.flagsCollection.isHeader, isTrue);
      handle.dispose();
    });

    for (final direction in TextDirection.values) {
      for (final scale in [1.0, 1.5, 2.0]) {
        testWidgets('UiSection layout direction $direction scale $scale', (
          tester,
        ) async {
          const longArabic =
              'إعدادات الحساب المتقدمة مع تفاصيل إضافية تتطلب التغليف الطبيعي للنص في الواجهات المتعددة';
          await tester.pumpWidget(
            host(
              const UiSection(
                title: 'Section Title',
                description: longArabic,
                child: Text('Content'),
              ),
              direction: direction,
              scale: scale,
            ),
          );
          expect(tester.takeException(), isNull);
          expect(find.text(longArabic), findsOneWidget);
        });
      }
    }
  });

  group('UiActionGroup Tests', () {
    testWidgets('wraps action buttons responsively based on available width', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          UiActionGroup(
            children: [
              shadcn.OutlineButton(
                key: const ValueKey('btn1'),
                onPressed: () {},
                child: const Text('Save Draft'),
              ),
              shadcn.PrimaryButton(
                key: const ValueKey('btn2'),
                onPressed: () {},
                child: const Text('Publish Document'),
              ),
            ],
          ),
          width: 320,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('btn1')), findsOneWidget);
      expect(find.byKey(const ValueKey('btn2')), findsOneWidget);
    });

    testWidgets('handles LTR and RTL directionality in action group', (
      tester,
    ) async {
      for (final dir in TextDirection.values) {
        await tester.pumpWidget(
          host(
            UiActionGroup(
              children: [
                shadcn.OutlineButton(
                  onPressed: () {},
                  child: const Text('Cancel'),
                ),
                shadcn.PrimaryButton(
                  onPressed: () {},
                  child: const Text('Submit'),
                ),
              ],
            ),
            direction: dir,
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Cancel'), findsOneWidget);
        expect(find.text('Submit'), findsOneWidget);
      }
    });
  });

  group('UiEmptyState Tests', () {
    testWidgets(
      'renders centered empty state with title, description and action',
      (tester) async {
        await tester.pumpWidget(
          host(
            UiEmptyState(
              title: 'No Data Found',
              description: 'Try refining your search parameters.',
              action: shadcn.OutlineButton(
                onPressed: () {},
                child: const Text('Refresh'),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('No Data Found'), findsOneWidget);
        expect(
          find.text('Try refining your search parameters.'),
          findsOneWidget,
        );
        expect(find.text('Refresh'), findsOneWidget);
      },
    );

    testWidgets('has accessible container semantics', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        host(
          const UiEmptyState(
            title: 'Empty List',
            description: 'Nothing to display.',
          ),
        ),
      );
      expect(find.byType(UiEmptyState), findsOneWidget);
      handle.dispose();
    });
  });

  group('UiErrorState Tests', () {
    testWidgets(
      'renders error state with theme destructive title and live region semantics',
      (tester) async {
        final handle = tester.ensureSemantics();
        await tester.pumpWidget(
          host(
            UiErrorState(
              title: 'Connection Failed',
              description:
                  'Unable to reach the server. Please check your network.',
              action: shadcn.PrimaryButton(
                onPressed: () {},
                child: const Text('Retry Connection'),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
        expect(find.text('Connection Failed'), findsOneWidget);
        expect(
          find.text('Unable to reach the server. Please check your network.'),
          findsOneWidget,
        );
        expect(find.text('Retry Connection'), findsOneWidget);

        final liveRegionSemantics = tester
            .widgetList<Semantics>(find.byType(Semantics))
            .where((s) => s.properties.liveRegion == true)
            .toList();
        expect(liveRegionSemantics.length, greaterThanOrEqualTo(1));

        handle.dispose();
      },
    );

    testWidgets('supports text scaling up to 2.0 without overflow', (
      tester,
    ) async {
      await tester.pumpWidget(
        host(
          const UiErrorState(
            title: 'Critical Error',
            description:
                'An error occurred while processing the requested operation. This message must remain readable even when text is scaled to 200%.',
          ),
          scale: 2.0,
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('Critical Error'), findsOneWidget);
    });
  });
}
