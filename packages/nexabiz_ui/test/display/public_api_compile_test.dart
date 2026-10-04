import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  test('Step 03 public contracts compile without upstream imports', () {
    const widgets = <Widget>[
      UiCard(child: Text('Record')),
      UiBadge(label: 'Active', variant: UiBadgeVariant.outline),
      UiChip(label: Text('Filter')),
      UiDivider(
        orientation: UiDividerOrientation.vertical,
        semanticLabel: 'Groups',
      ),
      UiAvatar(name: 'Jane Doe', size: UiAvatarSize.lg),
      UiTooltip(message: 'Details', child: Text('Help')),
    ];
    expect(widgets, hasLength(6));
  });
}
