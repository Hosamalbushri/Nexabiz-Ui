import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _buildTestHost(
  Widget child, {
  TextDirection direction = TextDirection.ltr,
}) {
  return Directionality(
    textDirection: direction,
    child: shadcn.ShadcnApp(
      home: shadcn.Scaffold(child: Center(child: child)),
    ),
  );
}

void main() {
  group('Phase 07 — Overlay & Interaction Contract Tests', () {
    testWidgets(
      'showUiConfirmationDialog returns true when confirmed (standard)',
      (tester) async {
        bool? result;

        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.PrimaryButton(
                  onPressed: () async {
                    result = await showUiConfirmationDialog(
                      context: context,
                      title: 'Confirm Save',
                      message: 'Do you want to save changes?',
                      confirmLabel: 'Confirm',
                      cancelLabel: 'Cancel',
                    );
                  },
                  child: const Text('Open Dialog'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Confirm Save'), findsOneWidget);
        expect(find.text('Do you want to save changes?'), findsOneWidget);
        expect(find.text('Confirm'), findsOneWidget);
        expect(find.text('Cancel'), findsOneWidget);

        await tester.tap(find.text('Confirm'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
        expect(find.text('Confirm Save'), findsNothing);
      },
    );

    testWidgets(
      'showUiConfirmationDialog returns true when confirmed (destructive)',
      (tester) async {
        bool? result;

        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.DestructiveButton(
                  onPressed: () async {
                    result = await showUiConfirmationDialog(
                      context: context,
                      title: 'Delete Item',
                      message: 'This action cannot be undone.',
                      confirmLabel: 'Delete Permanently',
                      cancelLabel: 'Cancel',
                      isDestructive: true,
                    );
                  },
                  child: const Text('Delete'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Delete'));
        await tester.pumpAndSettle();

        expect(find.text('Delete Item'), findsOneWidget);
        expect(find.text('Delete Permanently'), findsOneWidget);

        await tester.tap(find.text('Delete Permanently'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
        expect(find.text('Delete Item'), findsNothing);
      },
    );

    testWidgets(
      'showUiConfirmationDialog returns false when cancel button is tapped',
      (tester) async {
        bool? result;

        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.OutlineButton(
                  onPressed: () async {
                    result = await showUiConfirmationDialog(
                      context: context,
                      title: 'Discard Changes?',
                      message:
                          'Are you sure you want to discard unsaved edits?',
                      confirmLabel: 'Discard',
                      cancelLabel: 'Cancel',
                    );
                  },
                  child: const Text('Discard'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Discard'));
        await tester.pumpAndSettle();

        expect(find.text('Discard Changes?'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(result, isFalse);
        expect(find.text('Discard Changes?'), findsNothing);
      },
    );

    testWidgets(
      'showUiConfirmationDialog returns null on barrier tap when dismissible',
      (tester) async {
        bool? result;

        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.GhostButton(
                  onPressed: () async {
                    result = await showUiConfirmationDialog(
                      context: context,
                      title: 'Optional Prompt',
                      message: 'Tap outside to dismiss.',
                      confirmLabel: 'OK',
                      cancelLabel: 'Cancel',
                      barrierDismissible: true,
                    );
                  },
                  child: const Text('Open Optional'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Optional'));
        await tester.pumpAndSettle();

        expect(find.text('Optional Prompt'), findsOneWidget);

        // Tap top-left corner on modal backdrop barrier
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        expect(result, isNull);
        expect(find.text('Optional Prompt'), findsNothing);
      },
    );

    testWidgets(
      'showUiConfirmationDialog does NOT dismiss on barrier tap when barrierDismissible is false',
      (tester) async {
        bool? result;

        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.PrimaryButton(
                  onPressed: () async {
                    result = await showUiConfirmationDialog(
                      context: context,
                      title: 'Mandatory Modal',
                      message: 'You must make an explicit choice.',
                      confirmLabel: 'Agree',
                      cancelLabel: 'Decline',
                      barrierDismissible: false,
                    );
                  },
                  child: const Text('Open Mandatory'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Mandatory'));
        await tester.pumpAndSettle();

        expect(find.text('Mandatory Modal'), findsOneWidget);

        // Tap barrier corner
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        // Dialog must remain open, result must remain unassigned
        expect(find.text('Mandatory Modal'), findsOneWidget);
        expect(result, isNull);

        // Close explicitly
        await tester.tap(find.text('Agree'));
        await tester.pumpAndSettle();
        expect(result, isTrue);
      },
    );

    testWidgets(
      'showUiConfirmationDialog dismisses and returns null when Escape key is pressed',
      (tester) async {
        bool? result;
        final launchFocusNode = FocusNode();

        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.PrimaryButton(
                  focusNode: launchFocusNode,
                  onPressed: () async {
                    result = await showUiConfirmationDialog(
                      context: context,
                      title: 'Escape Key Test',
                      message: 'Press Escape key to dismiss.',
                      confirmLabel: 'Confirm',
                      cancelLabel: 'Cancel',
                    );
                  },
                  child: const Text('Open Keyboard Dialog'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        launchFocusNode.requestFocus();
        await tester.pumpAndSettle();
        expect(launchFocusNode.hasFocus, isTrue);

        await tester.tap(find.text('Open Keyboard Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Escape Key Test'), findsOneWidget);

        // Send LogicalKeyboardKey.escape key event
        await tester.sendKeyEvent(LogicalKeyboardKey.escape);
        await tester.pumpAndSettle();

        expect(find.text('Escape Key Test'), findsNothing);
        expect(result, isNull);
        expect(launchFocusNode.hasFocus, isTrue);

        launchFocusNode.dispose();
      },
    );

    testWidgets(
      'Modal dialog traps focus inside and restores focus on closure',
      (tester) async {
        final launchFocusNode = FocusNode();

        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.PrimaryButton(
                  focusNode: launchFocusNode,
                  onPressed: () {
                    showUiConfirmationDialog(
                      context: context,
                      title: 'Focus Test',
                      message: 'Testing focus restoration.',
                      confirmLabel: 'Proceed',
                      cancelLabel: 'Cancel',
                    );
                  },
                  child: const Text('Launch Focus Test'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        launchFocusNode.requestFocus();
        await tester.pumpAndSettle();
        expect(launchFocusNode.hasFocus, isTrue);

        await tester.tap(find.text('Launch Focus Test'));
        await tester.pumpAndSettle();

        expect(find.text('Focus Test'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(find.text('Focus Test'), findsNothing);
        expect(launchFocusNode.hasFocus, isTrue);

        launchFocusNode.dispose();
      },
    );

    testWidgets(
      'showUiConfirmationDialog supports Arabic RTL caller-owned labels cleanly without overflow',
      (tester) async {
        bool? result;

        await tester.pumpWidget(
          _buildTestHost(
            direction: TextDirection.rtl,
            Builder(
              builder: (context) {
                return shadcn.PrimaryButton(
                  onPressed: () async {
                    result = await showUiConfirmationDialog(
                      context: context,
                      title: 'حذف الحساب النهائية',
                      message: 'هل أنت متأكد من رغبتك في حذف البيانات؟',
                      confirmLabel: 'تأكيد الحذف',
                      cancelLabel: 'إلغاء الأمر',
                      isDestructive: true,
                    );
                  },
                  child: const Text('حذف'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('حذف'));
        await tester.pumpAndSettle();

        expect(find.text('حذف الحساب النهائية'), findsOneWidget);
        expect(
          find.text('هل أنت متأكد من رغبتك في حذف البيانات؟'),
          findsOneWidget,
        );
        expect(find.text('تأكيد الحذف'), findsOneWidget);
        expect(find.text('إلغاء الأمر'), findsOneWidget);

        await tester.tap(find.text('تأكيد الحذف'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
        expect(find.text('حذف الحساب النهائية'), findsNothing);
      },
    );

    testWidgets(
      'showUiConfirmationDialog supports long caller-owned labels under narrow container width without overflow',
      (tester) async {
        bool? result;

        await tester.pumpWidget(
          _buildTestHost(
            SizedBox(
              width: 320,
              child: Builder(
                builder: (context) {
                  return shadcn.PrimaryButton(
                    onPressed: () async {
                      result = await showUiConfirmationDialog(
                        context: context,
                        title: 'Long Labels Modal',
                        message: 'Testing layout under narrow host constraint.',
                        confirmLabel: 'Permanently Delete Record',
                        cancelLabel: 'Cancel Operation',
                        isDestructive: true,
                      );
                    },
                    child: const Text('Open Long Labels'),
                  );
                },
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Open Long Labels'));
        await tester.pumpAndSettle();

        expect(find.text('Long Labels Modal'), findsOneWidget);
        expect(find.text('Permanently Delete Record'), findsOneWidget);
        expect(find.text('Cancel Operation'), findsOneWidget);

        await tester.tap(find.text('Permanently Delete Record'));
        await tester.pumpAndSettle();

        expect(result, isTrue);
        expect(find.text('Long Labels Modal'), findsNothing);
      },
    );

    testWidgets(
      'shadcn.showToast functions cleanly inside ToastLayer context',
      (tester) async {
        await tester.pumpWidget(
          shadcn.ShadcnApp(
            home: shadcn.ToastLayer(
              child: shadcn.Scaffold(
                child: Center(
                  child: Builder(
                    builder: (context) {
                      return shadcn.PrimaryButton(
                        onPressed: () {
                          shadcn.showToast(
                            context: context,
                            builder: (toastContext, overlay) {
                              return const Text('Operation Successful');
                            },
                          );
                        },
                        child: const Text('Show Toast'),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Show Toast'));
        await tester.pump(); // trigger toast entry
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Operation Successful'), findsOneWidget);

        // Advance timer so auto-dismiss timer clears pending queue
        await tester.pump(const Duration(seconds: 10));
      },
    );
  });
}
