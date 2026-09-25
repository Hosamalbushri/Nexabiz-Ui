import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

const longLabel =
    'A descriptive label that must wrap onto several lines inside a narrow field';
const longError =
    'Please provide a value with enough detail to continue. This complete validation message must remain visible even when the field is narrow and the user has enlarged the text.';
const longHelper =
    'Supporting information can extend over several lines and must remain readable without a fixed total field height.';

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
  testWidgets('1920 window gives nested responsive host exactly 420 compact', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1920, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    double? actualWidth;
    UiLayoutTier? actualTier;
    await tester.pumpWidget(
      host(
        UiResponsive(
          builder: (context, width, tier) {
            actualWidth = width;
            actualTier = tier;
            return const SizedBox(height: 10);
          },
        ),
      ),
    );
    expect(actualWidth, 420);
    expect(actualTier, UiLayoutTier.compact);
    expect(tester.takeException(), isNull);
  });

  test('structural tiers include exact boundaries', () {
    for (final entry in <double, UiLayoutTier>{
      0: UiLayoutTier.compact,
      599.9: UiLayoutTier.compact,
      600: UiLayoutTier.medium,
      999.9: UiLayoutTier.medium,
      1000: UiLayoutTier.expanded,
      1439.9: UiLayoutTier.expanded,
      1440: UiLayoutTier.wide,
    }.entries) {
      expect(UiLayoutTier.forWidth(entry.key), entry.value);
    }
  });

  for (final direction in TextDirection.values) {
    for (final scale in [1.0, 1.5, 2.0]) {
      for (final width in [280.0, 420.0, 960.0]) {
        testWidgets('field growth $direction scale $scale width $width', (
          tester,
        ) async {
          tester.view.physicalSize = const Size(1920, 1200);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);
          final controllers = List.generate(3, (_) => TextEditingController());
          addTearDown(() {
            for (final c in controllers) {
              c.dispose();
            }
          });
          await tester.pumpWidget(
            host(
              UiFormLayout(
                children: [
                  UiTextField(
                    key: const ValueKey('first'),
                    label: longLabel,
                    requiredIndicator: 'Required',
                    controller: controllers[0],
                    description: longHelper,
                    error: longError,
                  ),
                  UiTextField(
                    key: const ValueKey('second'),
                    label: 'Second field',
                    controller: controllers[1],
                    helper: longHelper,
                  ),
                  UiTextField(label: 'Third field', controller: controllers[2]),
                ],
              ),
              width: width,
              scale: scale,
              direction: direction,
            ),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);
          final first = tester.getRect(find.byKey(const ValueKey('first')));
          final second = tester.getRect(find.byKey(const ValueKey('second')));
          if (width == 960 && scale <= 1.5) {
            expect(first.top, second.top);
            expect(first.width, closeTo((960 - UiTokens.contentGap) / 2, 0.01));
            expect(
              direction == TextDirection.ltr
                  ? first.left < second.left
                  : first.left > second.left,
              isTrue,
            );
          } else {
            expect(
              second.top,
              greaterThanOrEqualTo(first.bottom + UiTokens.contentGap),
            );
            expect(first.width, width);
          }
          for (final element
              in find
                  .descendant(
                    of: find.byType(UiFormLayout),
                    matching: find.byType(RichText),
                  )
                  .evaluate()) {
            final paragraph = element.renderObject! as RenderParagraph;
            expect(paragraph.didExceedMaxLines, isFalse);
            final painter = TextPainter(
              text: paragraph.text,
              textDirection: direction,
              textScaler: paragraph.textScaler,
            )..layout(maxWidth: paragraph.size.width);
            expect(
              paragraph.size.height,
              greaterThanOrEqualTo(painter.height - 0.1),
            );
            painter.dispose();
          }
          final errorRect = tester.getRect(find.text(longError));
          expect(errorRect.bottom, lessThanOrEqualTo(first.bottom + 0.1));
          expect(errorRect.height, greaterThan(20));
          final input = find.descendant(
            of: find.byKey(const ValueKey('first')),
            matching: find.byType(shadcn.TextField),
          );
          expect(
            tester.getSize(input).height,
            greaterThanOrEqualTo(UiTokens.controlMinHeight),
          );
          final editable = tester.widget<EditableText>(
            find.byType(EditableText).first,
          );
          expect(
            MediaQuery.textScalerOf(
              tester.element(find.byType(EditableText).first),
            ).scale(16),
            16 * scale,
          );
          expect(editable.maxLines, 1);
          await tester.pumpWidget(const SizedBox());
        });
      }
    }
  }

  testWidgets(
    'same field grows at 150 and 200 percent without shrinking fonts',
    (tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      final heights = <double>[];
      for (final scale in [1.0, 1.5, 2.0]) {
        await tester.pumpWidget(
          host(
            UiTextField(
              label: longLabel,
              controller: controller,
              error: longError,
            ),
            scale: scale,
          ),
        );
        heights.add(tester.getSize(find.byType(UiFieldShell)).height);
        expect(tester.takeException(), isNull);
      }
      expect(heights[1], greaterThan(heights[0]));
      expect(heights[2], greaterThan(heights[1]));
      await tester.pumpWidget(const SizedBox());
    },
  );

  testWidgets('caller owns edits validation and focus traversal', (
    tester,
  ) async {
    final first = TextEditingController();
    final second = TextEditingController();
    final firstFocus = FocusNode();
    final secondFocus = FocusNode();
    addTearDown(() {
      first.dispose();
      second.dispose();
      firstFocus.dispose();
      secondFocus.dispose();
    });
    String? changed;
    String? submitted;
    await tester.pumpWidget(
      host(
        UiFormLayout(
          children: [
            UiTextField(
              label: 'First',
              controller: first,
              focusNode: firstFocus,
              onChanged: (value) => changed = value,
            ),
            UiTextField(
              label: 'Second',
              controller: second,
              focusNode: secondFocus,
              onSubmitted: (value) => submitted = value,
              textInputAction: TextInputAction.done,
            ),
          ],
        ),
      ),
    );
    firstFocus.requestFocus();
    await tester.pump();
    await tester.enterText(find.byType(EditableText).first, 'typed value');
    expect(first.text, 'typed value');
    expect(changed, 'typed value');
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    expect(secondFocus.hasFocus, isTrue);
    await tester.enterText(find.byType(EditableText).last, 'done');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submitted, 'done');
    first.text = 'external update';
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(find.byType(EditableText).first)
          .controller
          .text,
      'external update',
    );
    await tester.pumpWidget(
      host(
        UiTextField(
          label: 'First',
          controller: first,
          helper: 'Helpful',
          error: longError,
        ),
      ),
    );
    expect(find.text(longError), findsOneWidget);
    expect(find.text('Helpful'), findsNothing);
    await tester.pumpWidget(
      host(UiTextField(label: 'First', controller: first, helper: 'Helpful')),
    );
    expect(find.text(longError), findsNothing);
    expect(find.text('Helpful'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('accessible label required indicator and error live region', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      host(
        UiTextField(
          label: 'Visible name',
          requiredIndicator: 'Required',
          controller: controller,
          error: longError,
        ),
      ),
    );
    expect(
      find.bySemanticsLabel(RegExp('Visible name, Required')),
      findsWidgets,
    );
    expect(
      tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.liveRegion == true && s.child is Text)
          .length,
      1,
    );
    expect(
      tester
          .getSemantics(find.byType(EditableText))
          .getSemanticsData()
          .flagsCollection
          .isTextField,
      isTrue,
    );
    handle.dispose();
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('theme roles follow caller shadcn typography and palette', (
    tester,
  ) async {
    final controller = TextEditingController();
    addTearDown(controller.dispose);
    final type = const shadcn.Typography.geist(p: TextStyle(fontSize: 21));
    final theme = shadcn.ThemeData(
      colorScheme: shadcn.ColorSchemes.darkSlate,
      typography: type,
    );
    await tester.pumpWidget(
      host(
        UiTextField(label: 'Label', controller: controller, error: longError),
        theme: theme,
      ),
    );
    expect(
      tester
          .widget<shadcn.TextField>(find.byType(shadcn.TextField))
          .style!
          .fontSize,
      21,
    );
    expect(
      tester.widget<Text>(find.text(longError)).style!.color,
      theme.colorScheme.destructive,
    );
    await tester.pumpWidget(const SizedBox());
  });
}
