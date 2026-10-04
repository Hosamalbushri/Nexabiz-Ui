import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

enum UiAvatarSize { sm, md, lg }

/// A person image with Unicode-safe initials fallback.
class UiAvatar extends StatelessWidget {
  const UiAvatar({
    super.key,
    required this.name,
    this.image,
    this.size = UiAvatarSize.md,
    this.semanticLabel,
  });

  final String name;
  final ImageProvider? image;
  final UiAvatarSize size;
  final String? semanticLabel;

  static bool _extendsGrapheme(int rune) =>
      (rune >= 0x0300 && rune <= 0x036f) ||
      (rune >= 0x0483 && rune <= 0x0489) ||
      (rune >= 0x0591 && rune <= 0x05bd) ||
      (rune >= 0x064b && rune <= 0x065f) ||
      (rune >= 0x0670 && rune <= 0x0670) ||
      (rune >= 0x06d6 && rune <= 0x06ed) ||
      (rune >= 0x1ab0 && rune <= 0x1aff) ||
      (rune >= 0x1dc0 && rune <= 0x1dff) ||
      (rune >= 0x20d0 && rune <= 0x20ff) ||
      (rune >= 0xfe20 && rune <= 0xfe2f) ||
      (rune >= 0xfe00 && rune <= 0xfe0f) ||
      (rune >= 0x1f3fb && rune <= 0x1f3ff);

  static List<String> _clusters(String value) {
    final clusters = <String>[];
    var joinNext = false;
    for (final rune in value.runes) {
      final part = String.fromCharCode(rune);
      if (clusters.isNotEmpty &&
          (_extendsGrapheme(rune) || joinNext || rune == 0x200d)) {
        clusters[clusters.length - 1] += part;
      } else {
        clusters.add(part);
      }
      joinNext = rune == 0x200d;
    }
    return clusters;
  }

  static String _initials(String name) {
    final words = name.trim().split(RegExp(r'\s+', unicode: true));
    if (words.isEmpty || words.first.isEmpty) return '';
    final first = _clusters(words.first);
    if (words.length > 1) {
      return (first.first + _clusters(words[1]).first).toUpperCase();
    }
    return first.take(2).join().toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = switch (size) {
      UiAvatarSize.sm => 32.0,
      UiAvatarSize.md => 40.0,
      UiAvatarSize.lg => 48.0,
    };
    return Semantics(
      label: semanticLabel ?? name,
      image: image != null,
      excludeSemantics: true,
      child: shadcn.Avatar(
        initials: _initials(name),
        provider: image,
        size: diameter,
      ),
    );
  }
}
