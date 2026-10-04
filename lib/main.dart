import 'package:flutter/material.dart' show DateTimeRange;
import 'package:flutter/widgets.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shadcn;

void main() => runApp(const FoundationWorkbench());

class FoundationWorkbench extends StatefulWidget {
  const FoundationWorkbench({super.key});

  @override
  State<FoundationWorkbench> createState() => _FoundationWorkbenchState();
}

class _FoundationWorkbenchState extends State<FoundationWorkbench> {
  bool _dark = false;

  @override
  Widget build(BuildContext context) => shadcn.ShadcnApp(
    title: 'Foundation Workbench',
    debugShowCheckedModeBanner: false,
    scaling: const shadcn.AdaptiveScaling(1),
    theme: shadcn.ThemeData(colorScheme: shadcn.ColorSchemes.lightSlate),
    darkTheme: shadcn.ThemeData(colorScheme: shadcn.ColorSchemes.darkSlate),
    themeMode: _dark ? shadcn.ThemeMode.dark : shadcn.ThemeMode.light,
    home: WorkbenchScreen(
      dark: _dark,
      onToggleTheme: () => setState(() => _dark = !_dark),
    ),
  );
}

class WorkbenchScreen extends StatefulWidget {
  const WorkbenchScreen({
    super.key,
    required this.dark,
    required this.onToggleTheme,
  });

  final bool dark;
  final VoidCallback onToggleTheme;

  @override
  State<WorkbenchScreen> createState() => _WorkbenchScreenState();
}

class _WorkbenchScreenState extends State<WorkbenchScreen> {
  final _textController = TextEditingController();
  final _numberController = TextEditingController();
  final _autoController = TextEditingController();
  final _notesController = TextEditingController();

  // Large Form Controllers (20+ fields)
  final List<TextEditingController> _largeFormControllers = List.generate(
    20,
    (_) => TextEditingController(),
  );

  bool _rtl = false;
  bool _long = false;
  bool _narrow = true;
  bool _arabic = false;
  bool _submitted = false;
  int _actionCount = 0;
  int _chipActions = 0;
  double _scale = 1;
  String _activeTab =
      'fields'; // 'composition-lab', 'interaction-lab', 'form-lab', 'fields', 'composition', 'empty', 'error'

  String? _selectedCategory = 'Electronics';
  List<String> _selectedTags = ['Urgent', 'Review'];
  DateTime? _selectedDate = DateTime(2026, 9, 26);
  DateTimeRange? _selectedDateRange = DateTimeRange(
    start: DateTime(2026, 9, 1),
    end: DateTime(2026, 9, 30),
  );

  bool _agreeTerms = false;
  bool _notifications = true;
  int _radioValue = 1;
  double _sliderValue = 0.5;

  @override
  void dispose() {
    _textController.dispose();
    _numberController.dispose();
    _autoController.dispose();
    _notesController.dispose();
    for (final c in _largeFormControllers) {
      c.dispose();
    }
    super.dispose();
  }

  String? get _error => !_submitted || _textController.text.trim().isNotEmpty
      ? null
      : (_arabic
            ? 'يرجى إدخال اسم العرض قبل المتابعة.'
            : (_long
                  ? 'Enter a display name before continuing. This long validation message must remain fully readable in narrow containers.'
                  : 'Enter a display name.'));

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(_scale)),
    child: Directionality(
      textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
      child: shadcn.ToastLayer(
        child: shadcn.Scaffold(
          child: SafeArea(
            child: SingleChildScrollView(
              child: UiContent(
                maxWidth: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Foundation Workbench',
                      style: UiTextRole.heading.resolve(context),
                    ),
                    const SizedBox(height: UiTokens.contentGap),
                    if (_activeTab == 'actions')
                      UiActionGroup(
                        children: [
                          UiButton(
                            label: _arabic ? 'حفظ' : 'Save',
                            loadingSemanticLabel: _arabic
                                ? 'جارٍ الحفظ'
                                : 'Saving',
                            onPressed: () => setState(() => _actionCount++),
                          ),
                          UiButton.outline(
                            label: _arabic ? 'معاينة' : 'Preview',
                            onPressed: () => setState(() => _actionCount++),
                          ),
                          UiIconButton(
                            icon: const Icon(
                              IconData(0xe145, fontFamily: 'MaterialIcons'),
                            ),
                            semanticLabel: _arabic ? 'إضافة' : 'Add',
                            tooltip: _arabic ? 'إضافة سجل' : 'Add record',
                            onPressed: () => setState(() => _actionCount++),
                          ),
                          UiSpinner(
                            semanticLabel: _arabic ? 'جارٍ التحميل' : 'Loading',
                          ),
                          Text('$_actionCount'),
                        ],
                      ),
                    const SizedBox(height: UiTokens.contentGap),
                    UiActionGroup(
                      children: [
                        _control(
                          'tab-actions',
                          _arabic ? 'عناصر الإجراءات' : 'Action Controls',
                          () => setState(() => _activeTab = 'actions'),
                        ),
                        _control(
                          'tab-visuals',
                          _arabic ? 'العناصر المرئية' : 'Visual Components',
                          () => setState(() => _activeTab = 'visuals'),
                        ),
                        _control(
                          'theme',
                          widget.dark ? 'Dark theme' : 'Light theme',
                          widget.onToggleTheme,
                        ),
                        _control(
                          'direction',
                          _rtl ? 'RTL' : 'LTR',
                          () => setState(() => _rtl = !_rtl),
                        ),
                        _control(
                          'lang',
                          _arabic ? 'Arabic' : 'English',
                          () => setState(() {
                            _arabic = !_arabic;
                            if (_arabic) _rtl = true;
                          }),
                        ),
                        _control(
                          'content',
                          _long ? 'Long content' : 'Normal content',
                          () => setState(() => _long = !_long),
                        ),
                        _control(
                          'width',
                          _narrow ? 'Narrow: 420' : 'Wide: 960',
                          () => setState(() {
                            _narrow = !_narrow;
                          }),
                        ),
                        for (final scale in [1.0, 1.5, 2.0])
                          _control(
                            'scale-$scale',
                            'Text ${(scale * 100).round()}%',
                            () => setState(() => _scale = scale),
                          ),
                      ],
                    ),
                    const SizedBox(height: UiTokens.contentGap),
                    UiActionGroup(
                      children: [
                        _control(
                          'tab-composition-lab',
                          'Composition Lab (Phase 08)',
                          () => setState(() => _activeTab = 'composition-lab'),
                        ),
                        _control(
                          'tab-interaction-lab',
                          'Interaction Lab (Phase 07)',
                          () => setState(() => _activeTab = 'interaction-lab'),
                        ),
                        _control(
                          'tab-form-lab',
                          'Form Lab (Phase 06)',
                          () => setState(() => _activeTab = 'form-lab'),
                        ),
                        _control(
                          'tab-fields',
                          'Field System (Phase 05)',
                          () => setState(() => _activeTab = 'fields'),
                        ),
                        _control(
                          'tab-composition',
                          'Composition (Phase 04)',
                          () => setState(() => _activeTab = 'composition'),
                        ),
                        _control(
                          'tab-empty',
                          'Empty State',
                          () => setState(() => _activeTab = 'empty'),
                        ),
                        _control(
                          'tab-error',
                          'Error State',
                          () => setState(() => _activeTab = 'error'),
                        ),
                      ],
                    ),
                    const SizedBox(height: UiTokens.contentGap),
                    Align(
                      alignment: AlignmentDirectional.topStart,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: _narrow ? 420 : UiTokens.formMaxWidth,
                        ),
                        child: UiResponsive(
                          builder: (context, width, tier) => Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Local host: ${width.round()} • ${tier.name}',
                                key: const ValueKey('local-width'),
                                style: UiTextRole.supporting.resolve(context),
                              ),
                              const SizedBox(height: UiTokens.contentGap),
                              if (_activeTab == 'composition-lab' ||
                                  _activeTab == 'interaction-lab')
                                if (_activeTab == 'composition-lab')
                                  _buildCompositionLabSection(context)
                                else
                                  _buildInteractionLabSection(context),
                              if (_activeTab == 'form-lab')
                                _buildFormLabSection(context),
                              if (_activeTab == 'fields')
                                _buildFieldsSection(context),
                              if (_activeTab == 'visuals')
                                _buildVisualSection(context),
                              if (_activeTab == 'composition')
                                _buildCompositionSection(context),
                              if (_activeTab == 'empty')
                                _buildEmptySection(context),
                              if (_activeTab == 'error')
                                _buildErrorSection(context),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _buildInteractionLabSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      UiSection(
        title: _arabic
            ? 'مختبر التفاعل والتراكيب: حوارات التأكيد والأغلفة'
            : 'Interaction Lab: Confirmations & Overlay Contracts',
        description: _arabic
            ? 'عرض حوارات التأكيد، الأغلفة، النوافذ الجانبية، الإشعارات، والاحتفاظ بالتركيز.'
            : 'Demonstrating confirmation dialogs, drawer overlays, popovers, and transient toast feedback.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiActionGroup(
              children: [
                shadcn.PrimaryButton(
                  onPressed: () async {
                    final res = await showUiConfirmationDialog(
                      context: context,
                      title: _arabic
                          ? 'حفظ التغييرات؟'
                          : 'Save Unsaved Changes?',
                      message: _arabic
                          ? 'هل ترغب في حفظ التغييرات الحالية قبل إغلاق النموذج؟'
                          : 'Would you like to persist current form changes before navigating away?',
                      confirmLabel: _arabic ? 'حفظ' : 'Save',
                      cancelLabel: _arabic ? 'إلغاء' : 'Cancel',
                    );
                    if (context.mounted && res != null) {
                      shadcn.showToast(
                        context: context,
                        builder: (ctx, overlay) =>
                            Text(res ? 'Confirmed Save' : 'Cancelled Save'),
                      );
                    }
                  },
                  child: Text(_arabic ? 'حوار تأكيد عادي' : 'Standard Dialog'),
                ),
                shadcn.DestructiveButton(
                  onPressed: () async {
                    final res = await showUiConfirmationDialog(
                      context: context,
                      title: _arabic
                          ? 'حذف السجل بشكل نهائي؟'
                          : 'Permanently Delete Record?',
                      message: _arabic
                          ? 'لا يمكن التراجع عن هذا الإجراء بعد التنفيذ.'
                          : 'This operation cannot be reverted once performed.',
                      confirmLabel: _arabic ? 'حذف نهائي' : 'Delete Record',
                      cancelLabel: _arabic ? 'إلغاء' : 'Cancel',
                      isDestructive: true,
                    );
                    if (context.mounted && res != null) {
                      shadcn.showToast(
                        context: context,
                        builder: (ctx, overlay) =>
                            Text(res ? 'Record Deleted' : 'Deletion Aborted'),
                      );
                    }
                  },
                  child: Text(
                    _arabic ? 'حوار تأكيد خطير' : 'Destructive Dialog',
                  ),
                ),
                shadcn.OutlineButton(
                  onPressed: () {
                    shadcn.openDrawerOverlay(
                      context: context,
                      position: _rtl
                          ? shadcn.OverlayPosition.left
                          : shadcn.OverlayPosition.right,
                      builder: (drawerCtx) => Container(
                        width: 320,
                        padding: const EdgeInsets.all(UiTokens.contentGap),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              _arabic ? 'درج جانبي' : 'Drawer Overlay',
                              style: UiTextRole.heading.resolve(context),
                            ),
                            const SizedBox(height: UiTokens.contentGap),
                            Text(
                              _arabic
                                  ? 'محتوى درج جانبي تفاعلي مع خلفية غائمة.'
                                  : 'Slide-in drawer layer with backdrop dismiss.',
                              style: UiTextRole.body.resolve(context),
                            ),
                            const Spacer(),
                            shadcn.PrimaryButton(
                              onPressed: () => Navigator.of(drawerCtx).pop(),
                              child: Text(_arabic ? 'إغلاق' : 'Close Drawer'),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Text(_arabic ? 'فتح درج جانبي' : 'Open Drawer'),
                ),
                shadcn.GhostButton(
                  onPressed: () {
                    shadcn.showToast(
                      context: context,
                      builder: (toastCtx, overlay) => Text(
                        _arabic
                            ? 'تم تنفيذ العملية بنجاح'
                            : 'Action completed successfully.',
                      ),
                    );
                  },
                  child: Text(_arabic ? 'إشعار سريع' : 'Show Toast'),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildFormLabSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      UiSection(
        title: _arabic
            ? 'نموذج متوسط: بيانات المستخدم والتفضيلات'
            : 'Medium Form: User Profile & Controls',
        description: _arabic
            ? 'عرض حقول الإدخال وعناصر الاختيار المتكاملة.'
            : 'Demonstrating form fields, choice controls, and UiFormSpan.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiFormLayout(
              maxColumns: 2,
              children: [
                UiTextField(
                  label: _arabic ? 'الاسم الكامل' : 'Full Name',
                  requiredIndicator: _arabic ? 'مطلوب' : 'Required',
                  controller: _textController,
                  placeholder: _arabic ? 'أدخل اسمك...' : 'Enter full name...',
                  error: _error,
                  onChanged: (_) => setState(() {}),
                ),
                UiSelectField<String>(
                  label: _arabic ? 'الدور الوظيفي' : 'Role',
                  value: _selectedCategory,
                  items: const [
                    'Administrator',
                    'Manager',
                    'Developer',
                    'Auditor',
                  ],
                  itemLabelBuilder: (v) => v,
                  onChanged: (v) => setState(() => _selectedCategory = v),
                ),
                UiFormSpan.full(
                  child: UiTextField(
                    label: _arabic ? 'ملاحظات إضافية' : 'Additional Notes',
                    controller: _notesController,
                    placeholder: 'Enter notes...',
                    minLines: 2,
                    maxLines: 4,
                  ),
                ),
                UiCheckboxField(
                  label: _arabic ? 'الموافقة على الشروط' : 'Agree to Terms',
                  value: _agreeTerms,
                  onChanged: (next) =>
                      setState(() => _agreeTerms = next ?? false),
                ),
                UiSwitchField(
                  label: _arabic
                      ? 'تفعيل الإشعارات'
                      : 'Enable System Notifications',
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                UiRadioGroupField<int>(
                  label: _arabic ? 'تقييم الأداء' : 'Custom Rating Control',
                  options: [
                    for (int i = 1; i <= 3; i++)
                      UiRadioOption(
                        value: i,
                        label: _arabic ? 'الأولوية $i' : 'Priority $i',
                      ),
                  ],
                  value: _radioValue,
                  onChanged: (v) => setState(() => _radioValue = v),
                ),
                UiSliderField(
                  label: _arabic ? 'النسبة' : 'Percentage',
                  value: _sliderValue,
                  divisions: 10,
                  semanticValue: _arabic
                      ? '${(_sliderValue * 100).round()} بالمئة'
                      : '${(_sliderValue * 100).round()} percent',
                  valueLabel: '${(_sliderValue * 100).round()}%',
                  onChanged: (v) => setState(() => _sliderValue = v),
                ),
              ],
            ),
            const SizedBox(height: UiTokens.contentGap),
            UiActionGroup(
              children: [
                shadcn.PrimaryButton(
                  onPressed: () => setState(() => _submitted = true),
                  child: Text(_arabic ? 'حفظ البيانات' : 'Save Changes'),
                ),
                shadcn.OutlineButton(
                  onPressed: () => setState(() {
                    _textController.clear();
                    _notesController.clear();
                    _submitted = false;
                  }),
                  child: Text(_arabic ? 'إلغاء' : 'Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: UiTokens.contentGap * 2),
      UiSection(
        title: _arabic ? 'نموذج كبير (20 حقل)' : 'Large Form (20 Fields)',
        description: _arabic
            ? 'اختبار أداء التركيب ونظام العرض للهياكل الكبيرة.'
            : 'Stress testing multi-section responsive composition.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            UiFormLayout(
              maxColumns: 3,
              children: [
                for (int i = 0; i < 20; i++)
                  if (i == 5)
                    UiFormSpan.wide(
                      child: UiTextField(
                        label: 'Wide Field #$i',
                        controller: _largeFormControllers[i],
                      ),
                    )
                  else if (i == 10)
                    UiFormSpan.full(
                      child: UiTextField(
                        label: 'Full Span Field #$i',
                        controller: _largeFormControllers[i],
                      ),
                    )
                  else
                    UiTextField(
                      label: 'Standard Field #$i',
                      controller: _largeFormControllers[i],
                    ),
              ],
            ),
            const SizedBox(height: UiTokens.contentGap),
            UiActionGroup(
              children: [
                shadcn.PrimaryButton(
                  onPressed: () {},
                  child: const Text('Submit Large Form'),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildFieldsSection(BuildContext context) => UiSection(
    title: _arabic ? 'أنظمة الإدخال والاختيار' : 'Field System & Selection',
    description: _arabic
        ? 'مكونات الإدخال الأساسية المعيارية القابلة لإعادة الاستخدام.'
        : 'Canonical presentation fields integrated with UiFieldShell.',
    trailing: shadcn.OutlineButton(
      onPressed: () {},
      child: Text(_arabic ? 'تعديل' : 'Edit'),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        UiFormLayout(
          children: [
            UiTextField(
              label: _arabic ? 'الاسم الشخصي' : 'Item Name',
              requiredIndicator: _arabic ? 'مطلوب' : 'Required',
              controller: _textController,
              placeholder: _arabic ? 'أدخل الاسم...' : 'Enter name...',
              error: _error,
              onChanged: (_) => setState(() {}),
            ),
            UiNumberField(
              label: _arabic ? 'الكمية أو التقييم' : 'Quantity / Rating',
              controller: _numberController,
              placeholder: _arabic ? 'أدخل رقماً...' : 'Enter number...',
              allowDecimals: true,
              allowNegative: true,
            ),
            UiSelectField<String>(
              label: _arabic ? 'التصنيف الرئيسي' : 'Category',
              value: _selectedCategory,
              items: const ['Electronics', 'Books', 'Clothing', 'Home'],
              itemLabelBuilder: (item) => item,
              onChanged: (val) => setState(() => _selectedCategory = val),
              placeholder: 'Select category...',
            ),
            UiMultiSelectField<String>(
              label: _arabic ? 'الوسومات' : 'Tags',
              value: _selectedTags,
              items: const ['Urgent', 'Review', 'Approved', 'Archived'],
              itemLabelBuilder: (item) => item,
              onChanged: (val) => setState(() => _selectedTags = val),
              placeholder: 'Select tags...',
            ),
            UiAutocompleteField(
              label: _arabic ? 'البحث المحلي' : 'Local Search',
              controller: _autoController,
              placeholder: 'Search items...',
              suggestions: const [
                'Apple',
                'Apricot',
                'Banana',
                'Cherry',
                'Date',
              ],
            ),
            UiDateField(
              label: _arabic ? 'تاريخ التوثيق' : 'Document Date',
              value: _selectedDate,
              onChanged: (val) => setState(() => _selectedDate = val),
            ),
            UiDateRangeField(
              label: _arabic ? 'نطاق التاريخ' : 'Date Range',
              value: _selectedDateRange,
              onChanged: (val) => setState(() => _selectedDateRange = val),
            ),
          ],
        ),
        const SizedBox(height: UiTokens.contentGap),
        UiActionGroup(
          children: [
            shadcn.OutlineButton(
              key: const ValueKey('validate'),
              onPressed: () => setState(() => _submitted = true),
              child: Text(_arabic ? 'تأكيد البيانات' : 'Validate'),
            ),
            shadcn.OutlineButton(
              key: const ValueKey('reset'),
              onPressed: () => setState(() {
                _textController.clear();
                _numberController.clear();
                _autoController.clear();
                _submitted = false;
              }),
              child: Text(_arabic ? 'إعادة ضبط' : 'Reset'),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _buildCompositionLabSection(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      UiSection(
        title: _arabic
            ? 'مختبر تركيب الصفحات والمواصفات المعمارية (المرحلة 08)'
            : 'Page Composition Lab & Boundary Certification (Phase 08)',
        description: _arabic
            ? 'إثبات كفاية العناوين، المحتوى، والمجموعات الإجرائية لجميع احتياجات تركيبة الصفحات دون وسائط صفحة خاصة.'
            : 'Proving that composition primitives (UiContent, UiSection, UiActionGroup) fulfill all page requirements without generic page wrappers.',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form-Style Composition
            UiSection(
              title: _arabic
                  ? '1. تركيب صفحة النماذج'
                  : '1. Form-Style Page Composition',
              description: _arabic
                  ? 'تركيب Scaffold + UiContent + UiSection + UiFormLayout + UiActionGroup'
                  : 'Composed of Scaffold host + UiContent + UiSection + Form + UiFormLayout + UiActionGroup.',
              trailing: shadcn.OutlineButton(
                onPressed: () {},
                child: Text(_arabic ? 'إلغاء' : 'Cancel'),
              ),
              child: UiFormLayout(
                children: [
                  UiFormSpan(
                    span: UiFormSpanType.full,
                    child: UiTextField(
                      label: _arabic ? 'اسم الحساب' : 'Account Name',
                      controller: _textController,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.contentGap),
            UiActionGroup(
              children: [
                shadcn.PrimaryButton(
                  onPressed: () {},
                  child: Text(_arabic ? 'حفظ النموذج' : 'Save Form'),
                ),
              ],
            ),
            const SizedBox(height: UiTokens.contentGap * 1.5),

            // Details-Style Composition
            UiSection(
              title: _arabic
                  ? '2. تركيب صفحة التفاصيل'
                  : '2. Details-Style Page Composition',
              description: _arabic
                  ? 'عرض بيانات القراءة فقط باستخدام البنية الأساسية ذاتها.'
                  : 'Read-only information surface composed with standard primitives.',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _arabic ? 'معرف المستأجر: TN-9042' : 'Tenant ID: TN-9042',
                    style: UiTextRole.body.resolve(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _arabic ? 'البيئة: الإنتاج' : 'Environment: Production',
                    style: UiTextRole.body.resolve(context),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _arabic ? 'الحالة: نشط' : 'Status: Active',
                    style: UiTextRole.body.resolve(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.contentGap * 1.5),

            // Settings-Style Composition
            UiSection(
              title: _arabic
                  ? '3. تركيب صفحة الإعدادات'
                  : '3. Settings-Style Page Composition',
              description: _arabic
                  ? 'استخدام عناصر التبديل المباشرة من shadcn_flutter داخل الأقسام التركيبية.'
                  : 'Direct shadcn_flutter controls (Switch, Checkbox) embedded in generic sections.',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _arabic
                        ? 'تفعيل الإشعارات الفورية'
                        : 'Enable Push Notifications',
                    style: UiTextRole.body.resolve(context),
                  ),
                  UiSwitch(
                    value: _notifications,
                    semanticLabel: _arabic
                        ? 'تفعيل الإشعارات الفورية'
                        : 'Enable Push Notifications',
                    onChanged: (val) => setState(() => _notifications = val),
                  ),
                ],
              ),
            ),
            const SizedBox(height: UiTokens.contentGap * 1.5),

            // Overlay Embedding Demonstration
            UiSection(
              title: _arabic
                  ? '4. إعادة استخدام التركيب داخل التراكب'
                  : '4. Embedded Overlay Host Reuse',
              description: _arabic
                  ? 'إعادة استخدام نفس المكونات داخل حوارات التأكيد والنوافذ الجانبية.'
                  : 'Demonstrating identical composition primitives embedded inside dialogs and drawer overlays.',
              child: UiActionGroup(
                children: [
                  shadcn.OutlineButton(
                    onPressed: () {
                      showUiConfirmationDialog(
                        context: context,
                        title: _arabic ? 'تأكيد الحفظ' : 'Confirm Save',
                        message: _arabic
                            ? 'هل أنت تأكد من حفظ التغييرات المعروضة؟'
                            : 'Are you sure you want to persist changes?',
                        confirmLabel: _arabic ? 'حفظ' : 'Confirm',
                        cancelLabel: _arabic ? 'إلغاء' : 'Cancel',
                      );
                    },
                    child: Text(_arabic ? 'تأكيد بالتراكب' : 'Launch Dialog'),
                  ),
                  shadcn.OutlineButton(
                    onPressed: () {
                      shadcn.openDrawerOverlay(
                        context: context,
                        position: shadcn.OverlayPosition.right,
                        builder: (drawerCtx) {
                          return SizedBox(
                            width: 360,
                            child: UiContent(
                              child: UiSection(
                                title: _arabic
                                    ? 'لوحة الجانب'
                                    : 'Drawer Panel Content',
                                description: _arabic
                                    ? 'محتوى معروض داخل تراكب النافذة الجانبية.'
                                    : 'Embedded inside right drawer overlay.',
                                child: Text(
                                  _arabic
                                      ? 'نفس العناصر التركيبية'
                                      : 'Identical composition primitives.',
                                  style: UiTextRole.body.resolve(context),
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                    child: Text(_arabic ? 'نافذة جانبية' : 'Launch Drawer'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );

  Widget _buildVisualSection(BuildContext context) => UiCard(
    title: _arabic ? 'ملخص السجل' : 'Record summary',
    description: _arabic ? 'مثال للعناصر المرئية' : 'Visual component examples',
    actions: UiBadge(
      label: _arabic ? 'نشط' : 'Active',
      variant: UiBadgeVariant.secondary,
    ),
    footer: Text(
      _arabic ? 'إجراءات الوسم: $_chipActions' : 'Chip actions: $_chipActions',
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            UiAvatar(name: _arabic ? 'محمد علي' : 'Jane Doe'),
            const SizedBox(width: UiTokens.fieldGap),
            Expanded(child: Text(_arabic ? 'محمد علي' : 'Jane Doe')),
          ],
        ),
        const SizedBox(height: UiTokens.fieldGap),
        const UiDivider(),
        const SizedBox(height: UiTokens.fieldGap),
        UiChip(
          label: Text(_arabic ? 'مرشح' : 'Filter'),
          deleteSemanticLabel: _arabic ? 'إزالة المرشح' : 'Remove filter',
          onPressed: () => setState(() => _chipActions++),
          onDeleted: () => setState(() => _chipActions++),
        ),
        const SizedBox(height: UiTokens.fieldGap),
        UiTooltip(
          message: _arabic ? 'تفاصيل السجل' : 'Record details',
          child: UiButton.ghost(
            label: _arabic ? 'مساعدة' : 'Help',
            onPressed: () {},
          ),
        ),
      ],
    ),
  );

  Widget _buildCompositionSection(BuildContext context) => UiSection(
    title: _arabic ? 'مكونات التركيب' : 'Composition Primitives',
    description: _arabic
        ? 'عناصر التركيب الهيكلية'
        : 'Structural composition widgets.',
    child: Text(
      'Composition components demonstrated in Phase 04.',
      style: UiTextRole.body.resolve(context),
    ),
  );

  Widget _buildEmptySection(BuildContext context) => UiSection(
    title: _arabic ? 'سجل البيانات' : 'Data Log',
    description: _arabic ? 'عرض السجلات' : 'Log view.',
    child: UiEmptyState(
      title: _arabic ? 'لا توجد بيانات' : 'No Items Found',
      description: _arabic
          ? 'لم يتم العثور على عناصر.'
          : 'No entries exist for the selected filter.',
      action: shadcn.OutlineButton(
        onPressed: () {},
        child: Text(_arabic ? 'إضافة' : 'Create Item'),
      ),
    ),
  );

  Widget _buildErrorSection(BuildContext context) => UiSection(
    title: _arabic ? 'حالة النظام' : 'System Health',
    description: _arabic ? 'مراقبة الاتصال' : 'Connection status.',
    child: UiErrorState(
      title: _arabic ? 'فشل الاتصال' : 'Connection Failure',
      description: _arabic
          ? 'تعذر الاتصال بقاعدة البيانات. يرجى إعادة المحاولة.'
          : 'Unable to connect to service endpoint.',
      action: shadcn.OutlineButton(
        onPressed: () {},
        child: Text(_arabic ? 'إعادة المحاولة' : 'Retry Request'),
      ),
    ),
  );

  Widget _control(String id, String label, VoidCallback action) =>
      ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: UiTokens.controlMinHeight,
          minWidth: UiTokens.controlMinHeight,
        ),
        child: shadcn.OutlineButton(
          key: ValueKey(id),
          onPressed: action,
          child: Text(label),
        ),
      );
}
