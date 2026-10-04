import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Caller-localized contextual help for hover, keyboard focus and long-press.
class UiTooltip extends StatefulWidget {
  const UiTooltip({
    super.key,
    required this.child,
    required this.message,
    this.waitDuration = const Duration(milliseconds: 500),
  });

  final Widget child;
  final String message;
  final Duration waitDuration;

  @override
  State<UiTooltip> createState() => _UiTooltipState();
}

class _UiTooltipState extends State<UiTooltip> {
  final shadcn.OverlayController _controller = shadcn.OverlayController();
  Timer? _hoverTimer;
  bool _hovered = false;
  bool _focused = false;
  bool _longPressed = false;

  void _show({bool update = false}) {
    if (!mounted || (_controller.hasOpenOverlay && !update)) return;
    _controller.show<void>(
      context,
      shadcn.PopoverConfiguration<void>(
        modal: false,
        alignment: Alignment.topCenter,
        anchorAlignment: Alignment.bottomCenter,
        dismissBackdropFocus: false,
        overlayBarrier: const shadcn.OverlayBarrier(
          barrierColor: Color(0x00000000),
        ),
        handler: shadcn.OverlayHandler.popover,
        builder: (context) => shadcn.TooltipContainer(
          child: ExcludeSemantics(child: Text(widget.message)),
        ),
      ),
      adaptive: false,
    );
  }

  void _hideIfInactive() {
    if (!_hovered && !_focused && !_longPressed) _controller.close();
  }

  @override
  void didUpdateWidget(covariant UiTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.message != widget.message) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_hovered || _focused || _longPressed) {
          _show(update: true);
        }
      });
    }
    if (oldWidget.waitDuration != widget.waitDuration && _hoverTimer != null) {
      _hoverTimer?.cancel();
      _hoverTimer = Timer(widget.waitDuration, () {
        _hoverTimer = null;
        if (_hovered) _show();
      });
    }
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      tooltip: widget.message,
      child: TapRegion(
        onTapOutside: (_) {
          _hoverTimer?.cancel();
          _hovered = false;
          _focused = false;
          _longPressed = false;
          _controller.close();
        },
        child: Focus(
          canRequestFocus: false,
          onFocusChange: (focused) {
            _focused = focused;
            if (focused) {
              _show();
            } else {
              _hideIfInactive();
            }
          },
          onKeyEvent: (_, event) {
            if (event is KeyDownEvent &&
                event.logicalKey == LogicalKeyboardKey.escape &&
                _controller.hasOpenOverlay) {
              _controller.close();
              _hovered = false;
              return KeyEventResult.handled;
            }
            return KeyEventResult.ignored;
          },
          child: MouseRegion(
            onEnter: (_) {
              _hovered = true;
              _hoverTimer?.cancel();
              _hoverTimer = Timer(widget.waitDuration, () {
                _hoverTimer = null;
                if (_hovered) _show();
              });
            },
            onExit: (_) {
              _hovered = false;
              _hoverTimer?.cancel();
              _hoverTimer = null;
              _hideIfInactive();
            },
            child: GestureDetector(
              onLongPress: () {
                _longPressed = true;
                _show();
              },
              onLongPressEnd: (_) {
                _longPressed = false;
                _hideIfInactive();
              },
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }
}
