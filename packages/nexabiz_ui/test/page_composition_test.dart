import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

Widget _buildTestHost(
  Widget child, {
  TextDirection textDirection = TextDirection.ltr,
  double textScaleFactor = 1.0,
}) {
  return shadcn.ShadcnApp(
    home: Directionality(
      textDirection: textDirection,
      child: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(textScaleFactor)),
        child: shadcn.ToastLayer(
          child: shadcn.Scaffold(child: SingleChildScrollView(child: child)),
        ),
      ),
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase 08 — Page Composition & Application Boundary Tests', () {
    testWidgets(
      'Form-Style Composition Recipe executes cleanly with application-owned host',
      (tester) async {
        final controller = TextEditingController();

        await tester.pumpWidget(
          _buildTestHost(
            UiContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UiSection(
                    title: 'User Profile Setup',
                    description: 'Configure initial account credentials.',
                    trailing: shadcn.OutlineButton(
                      onPressed: () {},
                      child: const Text('Cancel'),
                    ),
                    child: UiFormLayout(
                      children: [
                        UiFormSpan(
                          span: UiFormSpanType.full,
                          child: UiTextField(
                            label: 'Username',
                            controller: controller,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  UiActionGroup(
                    children: [
                      shadcn.PrimaryButton(
                        onPressed: () {},
                        child: const Text('Save Form'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('User Profile Setup'), findsOneWidget);
        expect(find.text('Username'), findsOneWidget);

        await tester.enterText(find.byType(shadcn.TextField), 'hosam_arch');
        await tester.tap(find.text('Save Form'));
        await tester.pumpAndSettle();

        expect(controller.text, equals('hosam_arch'));
      },
    );

    testWidgets(
      'Details-Style Composition Recipe renders read-only information layout',
      (tester) async {
        await tester.pumpWidget(
          _buildTestHost(
            UiContent(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UiSection(
                    title: 'System Information',
                    description: 'Read-only tenant metrics and status.',
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Tenant ID: TN-9042'),
                        Text('Environment: Production'),
                        Text('Status: Active'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('System Information'), findsOneWidget);
        expect(find.text('Tenant ID: TN-9042'), findsOneWidget);
        expect(find.text('Environment: Production'), findsOneWidget);
      },
    );

    testWidgets(
      'Settings-Style Composition Recipe composes direct shadcn controls',
      (tester) async {
        bool notificationsEnabled = true;

        await tester.pumpWidget(
          _buildTestHost(
            StatefulBuilder(
              builder: (context, setState) {
                return UiContent(
                  child: UiSection(
                    title: 'Notification Preferences',
                    description: 'Manage email and push notification channels.',
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Enable Push Notifications'),
                        shadcn.Switch(
                          value: notificationsEnabled,
                          onChanged: (val) {
                            setState(() {
                              notificationsEnabled = val;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Notification Preferences'), findsOneWidget);
        expect(find.byType(shadcn.Switch), findsOneWidget);

        await tester.tap(find.byType(shadcn.Switch));
        await tester.pumpAndSettle();

        expect(notificationsEnabled, isFalse);
      },
    );

    testWidgets(
      'State Composition Recipe seamlessly switches between loading, error, empty, and content',
      (tester) async {
        String state = 'loading';

        await tester.pumpWidget(
          _buildTestHost(
            StatefulBuilder(
              builder: (context, setState) {
                return UiContent(
                  child: Column(
                    children: [
                      UiActionGroup(
                        children: [
                          shadcn.OutlineButton(
                            onPressed: () => setState(() => state = 'loading'),
                            child: const Text('Show Loading'),
                          ),
                          shadcn.OutlineButton(
                            onPressed: () => setState(() => state = 'error'),
                            child: const Text('Show Error'),
                          ),
                          shadcn.OutlineButton(
                            onPressed: () => setState(() => state = 'empty'),
                            child: const Text('Show Empty'),
                          ),
                          shadcn.OutlineButton(
                            onPressed: () => setState(() => state = 'content'),
                            child: const Text('Show Content'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state == 'loading')
                        const Center(child: shadcn.CircularProgressIndicator())
                      else if (state == 'error')
                        UiErrorState(
                          title: 'Connection Failed',
                          description:
                              'Unable to sync record batch with server.',
                          action: shadcn.OutlineButton(
                            onPressed: () {},
                            child: const Text('Retry Sync'),
                          ),
                        )
                      else if (state == 'empty')
                        const UiEmptyState(
                          title: 'No Data Records',
                          description: 'Create a new item to get started.',
                        )
                      else
                        const UiSection(
                          title: 'Active Content Surface',
                          child: Text('Content loaded successfully.'),
                        ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.byType(shadcn.CircularProgressIndicator), findsOneWidget);

        await tester.tap(find.text('Show Error'));
        await tester.pumpAndSettle();
        expect(find.text('Connection Failed'), findsOneWidget);

        await tester.tap(find.text('Show Empty'));
        await tester.pumpAndSettle();
        expect(find.text('No Data Records'), findsOneWidget);

        await tester.tap(find.text('Show Content'));
        await tester.pumpAndSettle();
        expect(find.text('Active Content Surface'), findsOneWidget);
      },
    );

    testWidgets(
      'Embedded Composition adapts cleanly to local constraints (420px vs 800px host)',
      (tester) async {
        await tester.pumpWidget(
          _buildTestHost(
            Column(
              children: [
                SizedBox(
                  width: 420,
                  child: UiContent(
                    child: UiSection(
                      title: 'Narrow Host Section',
                      description: 'Testing responsive layout at 420px width.',
                      child: const Text('Content within 420px container.'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 800,
                  child: UiContent(
                    child: UiSection(
                      title: 'Wide Host Section',
                      description: 'Testing responsive layout at 800px width.',
                      child: const Text('Content within 800px container.'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Narrow Host Section'), findsOneWidget);
        expect(find.text('Wide Host Section'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Same composition primitives function identically when embedded in dialog host',
      (tester) async {
        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.PrimaryButton(
                  onPressed: () {
                    showUiConfirmationDialog(
                      context: context,
                      title: 'Embedded Dialog Title',
                      message: 'Dialog embedding test message.',
                      confirmLabel: 'Confirm Embed',
                      cancelLabel: 'Cancel Embed',
                    );
                  },
                  child: const Text('Launch Dialog'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Launch Dialog'));
        await tester.pumpAndSettle();

        expect(find.text('Embedded Dialog Title'), findsOneWidget);
        expect(find.text('Confirm Embed'), findsOneWidget);
      },
    );

    testWidgets(
      'Same composition primitives function identically when embedded in drawer overlay host',
      (tester) async {
        await tester.pumpWidget(
          _buildTestHost(
            Builder(
              builder: (context) {
                return shadcn.PrimaryButton(
                  onPressed: () {
                    shadcn.openDrawerOverlay(
                      context: context,
                      position: shadcn.OverlayPosition.right,
                      builder: (drawerCtx) {
                        return SizedBox(
                          width: 360,
                          child: UiContent(
                            child: UiSection(
                              title: 'Drawer Panel Content',
                              description:
                                  'Embedded inside right drawer overlay.',
                              child: const Text('Drawer child content.'),
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Launch Drawer'),
                );
              },
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.text('Launch Drawer'));
        await tester.pumpAndSettle();

        expect(find.text('Drawer Panel Content'), findsOneWidget);
      },
    );

    testWidgets(
      'Composition handles Arabic RTL and TextScaler 2.0 without visual overflow or clipping',
      (tester) async {
        await tester.pumpWidget(
          _buildTestHost(
            UiContent(
              child: UiSection(
                title: 'إعدادات الحساب والصلاحيات التفصيلية للنظام',
                description:
                    'تخصيص الخيارات المتقدمة وإدارة الوصول للمستخدمين المعينين.',
                trailing: shadcn.PrimaryButton(
                  onPressed: () {},
                  child: const Text('حفظ التغييرات'),
                ),
                child: const Text('محتوى القسم العربي المتقدم'),
              ),
            ),
            textDirection: TextDirection.rtl,
            textScaleFactor: 2.0,
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('إعدادات الحساب والصلاحيات التفصيلية للنظام'),
          findsOneWidget,
        );
        expect(find.text('حفظ التغييرات'), findsOneWidget);
        expect(tester.takeException(), isNull);
      },
    );
  });
}
