import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nexabiz_ui/nexabiz_ui.dart';

void main() {
  test('action controls compile using Flutter and public barrel only', () {
    final Widget spinner = const UiSpinner(semanticLabel: 'جارٍ التحميل');
    final Widget button = const UiButton(
      label: 'حفظ',
      loadingSemanticLabel: 'جارٍ الحفظ',
      isLoading: true,
      variant: UiButtonVariant.primary,
      size: UiButtonSize.md,
    );
    final Widget outline = const UiButton.outline(
      label: 'معاينة',
      loadingSemanticLabel: 'جارٍ المعاينة',
    );
    final Widget ghost = const UiButton.ghost(
      label: 'مزيد',
      loadingSemanticLabel: 'جارٍ التحميل',
    );
    final Widget destructive = const UiButton.destructive(
      label: 'حذف',
      loadingSemanticLabel: 'جارٍ الحذف',
    );
    final Widget icon = const UiIconButton(
      icon: Icon(IconData(0xe145, fontFamily: 'MaterialIcons')),
      semanticLabel: 'إضافة',
    );
    expect([spinner, button, outline, ghost, destructive, icon], hasLength(6));
  });
}
