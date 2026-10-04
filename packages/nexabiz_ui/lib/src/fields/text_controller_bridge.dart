import 'package:flutter/widgets.dart';

/// Keeps an upstream text field off a caller-owned controller.
///
/// The pinned upstream TextField does not detach its controller listener on
/// disposal. Its listener can remain on this disposable proxy instead of on
/// the caller's controller.
class FieldTextControllerBridge {
  FieldTextControllerBridge(TextEditingController source)
    : _source = source,
      proxy = TextEditingController.fromValue(source.value) {
    _source.addListener(_fromSource);
    proxy.addListener(_fromProxy);
  }

  TextEditingController _source;
  final TextEditingController proxy;
  bool _syncing = false;

  void replaceSource(TextEditingController source) {
    if (identical(_source, source)) return;
    _source.removeListener(_fromSource);
    _source = source;
    _source.addListener(_fromSource);
    _fromSource();
  }

  void _fromSource() {
    if (_syncing || proxy.value == _source.value) return;
    _syncing = true;
    proxy.value = _source.value;
    _syncing = false;
  }

  void _fromProxy() {
    if (_syncing || proxy.value == _source.value) return;
    _syncing = true;
    _source.value = proxy.value;
    _syncing = false;
  }

  void dispose() {
    _source.removeListener(_fromSource);
    proxy.removeListener(_fromProxy);
    proxy.dispose();
  }
}
