import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

/// Displays a standardized, accessible modal confirmation dialog.
///
/// Returns a [Future<bool?>]:
/// - `true` if user confirmed the action
/// - `false` if user explicitly cancelled the action
/// - `null` if the dialog was dismissed via barrier tap or Escape key
Future<bool?> showUiConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool isDestructive = false,
  bool barrierDismissible = true,
}) {
  final completer = const shadcn.DialogOverlayHandler().show<bool?>(
    context: context,
    alignment: Alignment.center,
    barrierDismissable: barrierDismissible,
    builder: (dialogContext) {
      return shadcn.AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          shadcn.Button.ghost(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(cancelLabel),
          ),
          if (isDestructive)
            shadcn.Button.destructive(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            )
          else
            shadcn.Button.primary(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
        ],
      );
    },
  );

  return completer.future;
}
