import 'package:flutter/widgets.dart';

/// Requested column span for field composition inside [UiFormLayout].
enum UiFormSpanType {
  /// Occupies 1 column slot.
  normal,

  /// Occupies 2 column slots (or full width if available columns <= 2).
  wide,

  /// Spans across all available columns in the row.
  full,
}

/// Decorator widget specifying field span metadata inside a [UiFormLayout].
///
/// In multi-column form layouts (e.g. 2 or 3 columns), multiline text fields,
/// address lines, or wide descriptors can be wrapped with [UiFormSpan] to take
/// wider or full-width column slots without breaking responsive layout or
/// focus traversal order.
class UiFormSpan extends StatelessWidget {
  const UiFormSpan({
    super.key,
    required this.child,
    this.span = UiFormSpanType.normal,
  });

  const UiFormSpan.normal({super.key, required this.child})
    : span = UiFormSpanType.normal;

  const UiFormSpan.wide({super.key, required this.child})
    : span = UiFormSpanType.wide;

  const UiFormSpan.full({super.key, required this.child})
    : span = UiFormSpanType.full;

  final Widget child;
  final UiFormSpanType span;

  @override
  Widget build(BuildContext context) => child;
}
