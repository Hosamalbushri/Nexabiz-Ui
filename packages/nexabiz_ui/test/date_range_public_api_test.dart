import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

// This consumer intentionally has no shadcn_flutter import.
void main() {
  test('exported date range field uses only Flutter range values', () {
    final range = DateTimeRange(
      start: DateTime.utc(2026, 9, 1, 12, 30),
      end: DateTime.utc(2026, 9, 30, 18, 45),
    );
    DateTimeRange? received;
    final field = UiDateRangeField(
      label: 'Period',
      value: range,
      onChanged: (DateTimeRange? value) => received = value,
    );
    final DateTimeRange? publicValue = field.value;
    final ValueChanged<DateTimeRange?>? publicCallback = field.onChanged;

    expect(publicValue, range);
    publicCallback?.call(null);
    expect(received, isNull);
    publicCallback?.call(range);
    expect(received, range);
  });
}
