import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _host(Widget child) => shadcn.ShadcnApp(
  home: shadcn.Scaffold(
    child: Center(child: SizedBox(width: 320, child: child)),
  ),
);

void main() {
  final items = List<String>.generate(1000, (index) => 'Option $index');

  testWidgets('single select only builds visible popup items', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      _host(
        UiSelectField<String>(
          label: 'Choice',
          items: items,
          value: items.first,
          onChanged: (_) {},
          itemBuilder: (context, item) {
            builds++;
            return Text(item);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    builds = 0;
    await tester.tap(find.byType(shadcn.Select<String>));
    await tester.pumpAndSettle();
    expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);
    expect(builds, lessThan(100));
    expect(tester.takeException(), isNull);
  });

  testWidgets('multi select only builds visible popup items', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      _host(
        UiMultiSelectField<String>(
          label: 'Tags',
          items: items,
          value: [items.first],
          onChanged: (_) {},
          itemBuilder: (context, item) {
            builds++;
            return Text(item);
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
    builds = 0;
    await tester.tap(find.byType(shadcn.SelectExpandIcon));
    await tester.pumpAndSettle();
    expect(find.byType(shadcn.SelectPopup<String>), findsOneWidget);
    expect(builds, lessThan(100));
    expect(tester.takeException(), isNull);
  });
}
