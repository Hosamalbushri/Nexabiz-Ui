import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

class _TestOption {
  final String id;
  final String label;
  const _TestOption(this.id, this.label);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is _TestOption &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

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
  group('UiSelectField & UiMultiSelectField Certification Tests', () {
    testWidgets(
      'UiSelectField renders label, placeholder, and selected value',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            UiSelectField<String>(
              label: 'Country',
              value: 'Jordan',
              items: const ['Egypt', 'Jordan', 'UAE'],
              itemLabelBuilder: (val) => val,
              placeholder: 'Select country...',
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Country'), findsOneWidget);
        expect(find.text('Jordan'), findsOneWidget);
      },
    );

    testWidgets(
      'UiSelectField handles equal value objects with different instances',
      (tester) async {
        const opt1 = _TestOption('1', 'Alpha');
        const opt1Duplicate = _TestOption('1', 'Alpha Duplicate');
        const opt2 = _TestOption('2', 'Beta');

        await tester.pumpWidget(
          _wrap(
            UiSelectField<_TestOption>(
              label: 'Option',
              value: opt1Duplicate,
              items: const [opt1, opt2],
              itemLabelBuilder: (opt) => opt.label,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Option'), findsOneWidget);
        expect(
          find.byType(shadcn.ControlledSelect<_TestOption>),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'UiMultiSelectField renders chips for selected items without mutating caller list',
      (tester) async {
        final callerOriginalList = ['Flutter', 'Dart'];
        List<String>? emittedList;

        await tester.pumpWidget(
          _wrap(
            UiMultiSelectField<String>(
              label: 'Technologies',
              value: callerOriginalList,
              items: const ['Flutter', 'Dart', 'Go', 'Rust'],
              onChanged: (newSelection) {
                emittedList = newSelection;
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Technologies'), findsOneWidget);
        expect(find.text('Flutter'), findsOneWidget);
        expect(find.text('Dart'), findsOneWidget);

        // Verify caller's original list instance was not mutated
        expect(callerOriginalList, equals(['Flutter', 'Dart']));
        expect(emittedList, isNull);
      },
    );

    testWidgets(
      'UiMultiSelectField wraps 10 selected chips without horizontal clipping at 320, 420, 960 widths',
      (tester) async {
        final tenItems = List.generate(10, (i) => 'Item #$i');

        for (final width in [320.0, 420.0, 960.0]) {
          await tester.pumpWidget(
            _wrap(
              SizedBox(
                width: width,
                child: UiMultiSelectField<String>(
                  label: 'Tag List',
                  value: tenItems,
                  items: tenItems,
                  itemLabelBuilder: (val) => val,
                ),
              ),
              scaler: const TextScaler.linear(1.5),
            ),
          );
          await tester.pumpAndSettle();

          expect(tester.takeException(), isNull);
          expect(find.text('Tag List'), findsOneWidget);
          expect(find.text('Item #0'), findsOneWidget);
        }
      },
    );

    testWidgets('UiSelectField handles disabled and error states cleanly', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          UiSelectField<String>(
            label: 'Status',
            items: const ['Active', 'Inactive'],
            itemLabelBuilder: (val) => val,
            enabled: false,
            error: 'Select status error message',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Status'), findsOneWidget);
      expect(find.text('Select status error message'), findsOneWidget);
    });
  });
}
