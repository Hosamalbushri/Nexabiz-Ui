import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'field_shell.dart';

/// A controlled single-value slider over the upstream slider primitive.
class UiSlider extends StatelessWidget {
  const UiSlider({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.enabled = true,
    this.semanticLabel,
    this.semanticValue,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final bool enabled;
  final String? semanticLabel;
  final String? semanticValue;

  @override
  Widget build(BuildContext context) {
    if (!min.isFinite || !max.isFinite || min >= max) {
      throw ArgumentError.value(
        [min, max],
        'min/max',
        'Must be finite and min < max',
      );
    }
    if (!value.isFinite || value < min || value > max) {
      throw ArgumentError.value(
        value,
        'value',
        'Must be finite and within min/max',
      );
    }
    if (divisions != null && divisions! <= 0) {
      throw ArgumentError.value(divisions, 'divisions', 'Must be positive');
    }
    final interactive = enabled && onChanged != null;

    return Semantics(
      label: semanticLabel,
      value: semanticValue,
      slider: true,
      enabled: interactive,
      excludeSemantics: true,
      child: shadcn.Slider(
        value: shadcn.SliderValue.single(value),
        min: min,
        max: max,
        divisions: divisions,
        enabled: interactive,
        onChanged: interactive ? (next) => onChanged!(next.value) : null,
      ),
    );
  }
}

/// A labeled slider with caller-owned value and optional localized value text.
class UiSliderField extends StatelessWidget {
  const UiSliderField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.description,
    this.helper,
    this.error,
    this.valueLabel,
    this.semanticValue,
    this.requiredIndicator = false,
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final double value;
  final ValueChanged<double>? onChanged;
  final double min;
  final double max;
  final int? divisions;
  final String? description;
  final String? helper;
  final String? error;
  final String? valueLabel;
  final String? semanticValue;
  final bool requiredIndicator;
  final bool enabled;
  final bool readOnly;

  @override
  Widget build(BuildContext context) => UiFieldShell(
    label: label,
    description: description,
    helper: helper,
    error: error,
    enabled: enabled,
    readOnly: readOnly,
    control: Semantics(
      isRequired: requiredIndicator,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          UiSlider(
            value: value,
            min: min,
            max: max,
            divisions: divisions,
            semanticValue: semanticValue,
            onChanged: enabled && !readOnly ? onChanged : null,
            enabled: enabled && !readOnly,
          ),
          if (valueLabel != null) ...[
            const SizedBox(height: UiTokens.fieldGap),
            ExcludeSemantics(
              child: Text(
                valueLabel!,
                style: UiTextRole.supporting.resolve(context),
              ),
            ),
          ],
        ],
      ),
    ),
  );
}
