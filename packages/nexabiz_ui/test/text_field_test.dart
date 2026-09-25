import 'package:flutter/services.dart';
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
        child: shadcn.Scaffold(
          child: Padding(padding: const EdgeInsets.all(16.0), child: child),
        ),
      ),
    ),
  );
}

void main() {
  group('UiTextField Multiline & Parameter Certification Tests', () {
    testWidgets('supports single line input by default', (tester) async {
      final controller = TextEditingController(text: 'Single line');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(UiTextField(label: 'Name', controller: controller)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Single line'), findsOneWidget);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.maxLines, 1);
    });

    testWidgets('supports multiline input with minLines and maxLines', (
      tester,
    ) async {
      final controller = TextEditingController(text: 'Line 1\nLine 2\nLine 3');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          UiTextField(
            label: 'Description',
            controller: controller,
            minLines: 3,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Line 1\nLine 2\nLine 3'), findsOneWidget);
      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.minLines, 3);
      expect(editable.maxLines, 5);
    });

    testWidgets('supports obscureText for password inputs', (tester) async {
      final controller = TextEditingController(text: 'secret123');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          UiTextField(
            label: 'Password',
            controller: controller,
            obscureText: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final editable = tester.widget<EditableText>(find.byType(EditableText));
      expect(editable.obscureText, isTrue);
    });

    testWidgets('applies caller-owned inputFormatters and textInputAction', (
      tester,
    ) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          UiTextField(
            label: 'Code',
            controller: controller,
            inputFormatters: [LengthLimitingTextInputFormatter(4)],
            textInputAction: TextInputAction.send,
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(EditableText), '123456');
      await tester.pumpAndSettle();

      expect(controller.text, '1234');
    });

    testWidgets('grows dynamically under TextScaler 2.0 without clipping', (
      tester,
    ) async {
      final controller = TextEditingController(
        text: 'Large text scale content',
      );
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        _wrap(
          UiTextField(
            label: 'Scaled Field',
            controller: controller,
            description: 'Description text scaling to 200%',
          ),
          scaler: const TextScaler.linear(2.0),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Scaled Field'), findsOneWidget);
    });
  });
}
