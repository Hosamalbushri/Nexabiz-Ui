/// Composition decisions independent of application branding.
abstract final class UiTokens {
  /// Separation of a field's label, control and supporting content.
  static const double fieldGap = 8;

  /// Separation of independent content blocks and default content inset.
  static const double contentGap = 24;

  /// Readable maximum width for a small multi-column form.
  static const double formMaxWidth = 960;

  /// Useful column width before text scaling is considered.
  static const double formColumnMinWidth = 280;

  /// Minimum interactive control height; never a total field height.
  static const double controlMinHeight = 48;
}
class UiButton {}
