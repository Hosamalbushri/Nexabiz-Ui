import 'dart:io';

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
  group('UiAutocompleteField Certification Tests', () {
    testWidgets(
      'UiAutocompleteField displays label, placeholder, and controller text',
      (tester) async {
        final controller = TextEditingController(text: 'Ap');
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _wrap(
            UiAutocompleteField(
              label: 'Fruit',
              requiredIndicator: 'Required',
              controller: controller,
              placeholder: 'Search fruit...',
              suggestions: const ['Apple', 'Apricot', 'Banana', 'Cherry'],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Fruit · Required'), findsOneWidget);
        expect(find.text('Ap'), findsOneWidget);
        expect(find.byType(shadcn.AutoComplete), findsOneWidget);
      },
    );

    test(
      'verifies zero Future.delayed or Timer focus timing hacks in autocomplete_field.dart',
      () {
        final file = File('lib/src/fields/autocomplete_field.dart');
        final content = file.readAsStringSync();

        expect(
          content.contains('Future.delayed'),
          isFalse,
          reason:
              'UiAutocompleteField must not use Future.delayed timing hacks',
        );
        expect(
          content.contains('Timer('),
          isFalse,
          reason: 'UiAutocompleteField must not use Timer focus timing hacks',
        );
      },
    );

    testWidgets(
      'filters dataset scale performance synchronously (10, 100, 1000 items) without throwing',
      (tester) async {
        final thousandSuggestions = List.generate(
          1000,
          (i) => 'Option Item #$i',
        );
        final controller = TextEditingController(text: 'Option Item #9');
        addTearDown(controller.dispose);

        await tester.pumpWidget(
          _wrap(
            UiAutocompleteField(
              label: 'Large Dataset Search',
              controller: controller,
              suggestions: thousandSuggestions,
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Large Dataset Search'), findsOneWidget);
        expect(find.text('Option Item #9'), findsOneWidget);
      },
    );
  });
}
