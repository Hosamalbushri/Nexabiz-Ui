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
  testWidgets('UiChip pointer activates body and delete exactly once', (
    tester,
  ) async {
    var pressed = 0;
    var deleted = 0;
    for (final (index, direction) in TextDirection.values.indexed) {
      await tester.pumpWidget(
        host(
          UiChip(
            label: const Text('Filter'),
            deleteSemanticLabel: 'Remove filter',
            onPressed: () => pressed++,
            onDeleted: () => deleted++,
          ),
          direction: direction,
        ),
      );
      // Diagnostic geometry guards against a nested delete target covering
      // the chip label.
      expect(
        tester
            .getRect(find.text('Filter'))
            .overlaps(tester.getRect(find.byType(shadcn.ChipButton))),
        isFalse,
      );
      await tester.tapAt(tester.getCenter(find.text('Filter')));
      await tester.pump();
      expect(pressed, index + 1);
      expect(deleted, index);
      await tester.tap(find.byType(shadcn.ChipButton));
      await tester.pump();
      expect(deleted, index + 1);
      expect(pressed, index + 1);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'UiChip delete control is keyboard-operable and disabled suppresses all',
    (tester) async {
      var pressed = 0;
      var deleted = 0;
      await tester.pumpWidget(
        host(
          UiChip(
            label: const Text('Filter'),
            deleteSemanticLabel: 'Remove filter',
            onPressed: () => pressed++,
            onDeleted: () => deleted++,
          ),
        ),
      );
      await tester.tap(find.byType(shadcn.ChipButton));
      await tester.pump();
      expect(find.bySemanticsLabel('Remove filter'), findsOneWidget);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pump();
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(deleted, 2);
      expect(pressed, 0);
      await tester.pumpWidget(
        host(
          UiChip(
            label: const Text('Filter'),
            deleteSemanticLabel: 'Remove filter',
            onPressed: () => pressed++,
            onDeleted: () => deleted++,
            enabled: false,
          ),
        ),
      );
      await tester.tapAt(tester.getCenter(find.text('Filter')));
      await tester.tap(find.byType(shadcn.ChipButton));
      await tester.sendKeyEvent(LogicalKeyboardKey.enter);
      await tester.pump();
      expect(pressed, 0);
      expect(deleted, 2);
    },
  );

  testWidgets('UiChip rejects missing or blank delete label', (tester) async {
    expect(
      () => UiChip(label: const Text('A'), onDeleted: () {}),
      throwsAssertionError,
    );
    await tester.pumpWidget(
      host(
        UiChip(
          label: const Text('A'),
          onDeleted: () {},
          deleteSemanticLabel: '   ',
        ),
      ),
    );
    expect(tester.takeException(), isArgumentError);
  });
}
