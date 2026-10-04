import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

import '../foundation/tokens.dart';
import '../foundation/typography.dart';
import 'field_shell.dart';

/// One caller-labeled option in a controlled radio group.
class UiRadioOption<T> {
  const UiRadioOption({
    required this.value,
    required this.label,
    this.description,
    this.enabled = true,
  });

  final T value;
  final String label;
  final String? description;
  final bool enabled;
}

/// A controlled, vertically composed radio choice group.
class UiRadioGroup<T> extends StatelessWidget {
  const UiRadioGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.semanticLabel,
  });

  final List<UiRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool enabled;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => _RadioBridge<T>(
    options: options,
    value: value,
    onChanged: onChanged,
    enabled: enabled,
    semanticLabel: semanticLabel,
  );
}

class _RadioBridge<T> extends StatefulWidget {
  const _RadioBridge({
    required this.options,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.semanticLabel,
  });

  final List<UiRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final bool enabled;
  final String? semanticLabel;

  @override
  State<_RadioBridge<T>> createState() => _RadioBridgeState<T>();
}

class _RadioBridgeState<T> extends State<_RadioBridge<T>> {
  final List<FocusNode> _nodes = [];
  T? _pendingValue;
  bool _hasPending = false;

  @override
  void initState() {
    super.initState();
    _ensureNodes();
  }

  void _ensureNodes() {
    while (_nodes.length < widget.options.length) {
      _nodes.add(FocusNode());
    }
  }

  @override
  void didUpdateWidget(_RadioBridge<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    _ensureNodes();
    if (widget.value != oldWidget.value) _hasPending = false;
    if (widget.options.length < _nodes.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.options.length >= _nodes.length) return;
        final removed = _nodes.sublist(widget.options.length);
        _nodes.removeRange(widget.options.length, _nodes.length);
        for (final node in removed) {
          node.dispose();
        }
      });
    }
  }

  @override
  void dispose() {
    for (final node in _nodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _notify(T next) {
    if (!widget.enabled || widget.onChanged == null || next == widget.value) {
      return;
    }
    if (_hasPending && next == _pendingValue) return;
    _hasPending = true;
    _pendingValue = next;
    widget.onChanged!(next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _hasPending = false;
    });
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent || !widget.enabled || widget.onChanged == null) {
      return KeyEventResult.ignored;
    }
    final key = event.logicalKey;
    final rtl = Directionality.of(context) == TextDirection.rtl;
    final forward =
        key == LogicalKeyboardKey.arrowDown ||
        (rtl
            ? key == LogicalKeyboardKey.arrowLeft
            : key == LogicalKeyboardKey.arrowRight);
    final backward =
        key == LogicalKeyboardKey.arrowUp ||
        (rtl
            ? key == LogicalKeyboardKey.arrowRight
            : key == LogicalKeyboardKey.arrowLeft);
    if (!forward && !backward) return KeyEventResult.ignored;
    if (widget.options.isEmpty) return KeyEventResult.handled;
    var index = _nodes.indexWhere((focus) => focus.hasFocus);
    if (index < 0) {
      index = widget.options.indexWhere(
        (option) => option.value == widget.value,
      );
    }
    for (var offset = 1; offset <= widget.options.length; offset++) {
      final candidate =
          (index + (forward ? offset : -offset)) % widget.options.length;
      final target = candidate < 0
          ? candidate + widget.options.length
          : candidate;
      if (!widget.options[target].enabled) continue;
      _nodes[target].requestFocus();
      _notify(widget.options[target].value);
      break;
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    final interactive = widget.enabled && widget.onChanged != null;
    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: widget.semanticLabel,
      enabled: interactive,
      child: Focus(
        canRequestFocus: false,
        onKeyEvent: _onKeyEvent,
        child: shadcn.RadioGroup<T>(
          value: widget.value,
          enabled: interactive,
          onChanged: interactive ? _notify : null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var index = 0; index < widget.options.length; index++)
                Padding(
                  padding: const EdgeInsets.only(bottom: UiTokens.fieldGap),
                  child: Semantics(
                    container: true,
                    label: widget.options[index].label,
                    hint: widget.options[index].description,
                    checked: widget.options[index].value == widget.value,
                    inMutuallyExclusiveGroup: true,
                    enabled: interactive && widget.options[index].enabled,
                    onTap:
                        interactive &&
                            widget.options[index].enabled &&
                            widget.options[index].value != widget.value
                        ? () => _notify(widget.options[index].value)
                        : null,
                    excludeSemantics: true,
                    child: ExcludeFocus(
                      excluding: !interactive || !widget.options[index].enabled,
                      child: shadcn.RadioItem<T>(
                        focusNode: _nodes[index],
                        value: widget.options[index].value,
                        enabled: widget.options[index].enabled,
                        trailing: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.options[index].label,
                              style: UiTextRole.body.resolve(context),
                            ),
                            if (widget.options[index].description != null)
                              Text(
                                widget.options[index].description!,
                                style: UiTextRole.supporting.resolve(context),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A labeled radio choice group with caller-owned value.
class UiRadioGroupField<T> extends StatelessWidget {
  const UiRadioGroupField({
    super.key,
    required this.label,
    required this.options,
    required this.value,
    required this.onChanged,
    this.description,
    this.helper,
    this.error,
    this.requiredIndicator = false,
    this.enabled = true,
    this.readOnly = false,
  });

  final String label;
  final List<UiRadioOption<T>> options;
  final T? value;
  final ValueChanged<T>? onChanged;
  final String? description;
  final String? helper;
  final String? error;
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
      child: UiRadioGroup<T>(
        options: options,
        value: value,
        onChanged: enabled && !readOnly ? onChanged : null,
        enabled: enabled && !readOnly,
      ),
    ),
  );
}
