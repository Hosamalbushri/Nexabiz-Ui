import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

// Canonical invocation is from the workspace root. No legacy tree is scanned.
final root = Directory.current;
final package = Directory('${root.path}/packages/nexabiz_ui');

Iterable<File> dartFiles(Directory directory) => directory
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'));

final directive = RegExp(r'''(?:import|export)\s+['"]([^'"]+)['"]''');

Set<String> productionDependencies(File file) {
  final lines = file.readAsLinesSync();
  var inDependencies = false;
  final names = <String>{};
  for (final line in lines) {
    if (line == 'dependencies:') {
      inDependencies = true;
      continue;
    }
    if (inDependencies && RegExp(r'^\S').hasMatch(line)) break;
    if (inDependencies) {
      final match = RegExp(r'^  ([a-zA-Z0-9_]+):').firstMatch(line);
      if (match != null) names.add(match[1]!);
    }
  }
  return names;
}

void main() {
  test('G1 production imports remain inside generic foundation', () {
    final violations = <String>[];
    final lib = Directory('${package.path}/lib').absolute.path;
    for (final file in dartFiles(Directory(lib))) {
      for (final match in directive.allMatches(file.readAsStringSync())) {
        final uri = match[1]!;
        if (uri.startsWith('dart:')) continue;
        if (uri.startsWith('package:flutter/') ||
            uri.startsWith('package:shadcn_flutter/')) {
          continue;
        }
        if (uri.startsWith('package:')) {
          violations.add('${file.path}: forbidden package import $uri');
        } else {
          final target = file.uri.resolve(uri).toFilePath();
          if (!target.startsWith('$lib/')) {
            violations.add('${file.path}: import escapes package lib: $uri');
          }
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'G1 domain/application imports are forbidden',
    );
  });

  test('G2 Workbench consumes only the canonical package entrypoint', () {
    final violations = <String>[];
    for (final file in dartFiles(Directory('${root.path}/lib'))) {
      for (final match in directive.allMatches(file.readAsStringSync())) {
        final uri = match[1]!;
        if ((uri.contains('nexabiz_ui') &&
                uri != 'package:nexabiz_ui/nexabiz_ui.dart') ||
            (uri.contains('packages/') && uri.contains('/lib/'))) {
          violations.add('${file.path}: $uri');
        }
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'G2 direct src/legacy imports are forbidden',
    );
  });

  test('G3 production barrel exports only reviewed stable contracts', () {
    const expected = <String>{
      "export 'src/foundation/tokens.dart' show UiTokens;",
      "export 'src/foundation/typography.dart' show UiTextRole;",
      "export 'src/foundation/responsive.dart' show UiLayoutTier, UiResponsive;",
      "export 'src/composition/content.dart' show UiContent;",
      "export 'src/composition/section.dart' show UiSection;",
      "export 'src/composition/action_group.dart' show UiActionGroup;",
      "export 'src/composition/empty_state.dart' show UiEmptyState;",
      "export 'src/composition/error_state.dart' show UiErrorState;",
      "export 'src/fields/field_shell.dart' show UiFieldShell;",
      "export 'src/fields/text_field.dart' show UiTextField;",
      "export 'src/fields/number_field.dart' show UiNumberField;",
      "export 'src/fields/select_field.dart' show UiSelectField;",
      "export 'src/fields/multi_select_field.dart' show UiMultiSelectField;",
      "export 'src/fields/autocomplete_field.dart' show UiAutocompleteField;",
      "export 'src/fields/date_field.dart' show UiDateField;",
      "export 'src/fields/date_range_field.dart' show UiDateRangeField;",
      "export 'src/forms/form_layout.dart' show UiFormLayout;",
      "export 'src/forms/form_span.dart' show UiFormSpan, UiFormSpanType;",
      "export 'src/interaction/confirmation_dialog.dart' show showUiConfirmationDialog;",
    };
    final text = File('${package.path}/lib/nexabiz_ui.dart').readAsStringSync();
    final actual = RegExp(r'export\s+[^;]+;')
        .allMatches(text)
        .map((m) => m[0]!.replaceAll(RegExp(r'\s+'), ' '))
        .toSet();
    expect(
      actual,
      expected,
      reason: 'G3 public API must not expose internal/dev helpers',
    );
  });

  test(
    'G4 state management and router dependencies stay outside production',
    () {
      const banned = {
        'flutter_riverpod',
        'riverpod',
        'go_router',
        'provider',
        'bloc',
        'flutter_bloc',
      };
      expect(
        productionDependencies(
          File('${package.path}/pubspec.yaml'),
        ).intersection(banned),
        isEmpty,
        reason: 'G4 prohibited state/router dependency',
      );
    },
  );

  test('G5 responsive scaling dependencies stay absent', () {
    const banned = {
      'flutter_screenutil',
      'sizer',
      'responsive_sizer',
      'responsive_framework',
    };
    expect(
      productionDependencies(
        File('${package.path}/pubspec.yaml'),
      ).intersection(banned),
      isEmpty,
      reason: 'G5 prohibited responsive scaling dependency',
    );
  });

  test('G6 dependency graph is minimal and shadcn version stays approved', () {
    final pubspec = File('${package.path}/pubspec.yaml');
    expect(
      productionDependencies(pubspec),
      {'flutter', 'shadcn_flutter'},
      reason: 'G6 unapproved production dependency',
    );
    expect(
      pubspec.readAsStringSync(),
      contains('shadcn_flutter: 0.0.53'),
      reason: 'G6 approved shadcn pin',
    );
    final workbench = File('${root.path}/pubspec.yaml').readAsStringSync();
    expect(workbench, contains('path: packages/nexabiz_ui'));
    expect(workbench, isNot(contains('nexabiz_ui_legacy')));
  });

  test('G7 visual authority and text scaling remain intact', () {
    final violations = <String>[];
    for (final file in dartFiles(Directory('${package.path}/lib'))) {
      final source = file.readAsStringSync();
      final materialLines = source
          .split('\n')
          .where((line) => line.contains('package:flutter/material.dart'));
      final allowedRangeImport = file.path.endsWith(
        '/lib/src/fields/date_range_field.dart',
      );
      final forbiddenMaterial = materialLines.any(
        (line) =>
            !allowedRangeImport ||
            line.trim() !=
                "import 'package:flutter/material.dart' show DateTimeRange;",
      );
      if (forbiddenMaterial ||
          source.contains('FittedBox(') ||
          source.contains('MediaQuery.sizeOf') ||
          source.contains('MediaQuery.of(context).size')) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'G7 competing visual authority or viewport/text scaling bypass',
    );
  });

  test('G15 exported contracts do not expose upstream shadcn types', () {
    final barrel = File(
      '${package.path}/lib/nexabiz_ui.dart',
    ).readAsStringSync();
    final exports = RegExp(
      r"export '([^']+)' show ([^;]+);",
    ).allMatches(barrel);
    final violations = <String>[];
    for (final export in exports) {
      final file = File('${package.path}/lib/${export[1]}');
      final symbols = export[2]!.split(',').map((s) => s.trim()).toSet();
      final lines = file.readAsLinesSync();
      var depth = 0;
      var exportedClassDepth = -1;
      for (var index = 0; index < lines.length; index++) {
        final line = lines[index];
        if (depth == 0 &&
            symbols.any(
              (symbol) =>
                  RegExp('(?:class|enum|typedef) $symbol\\b').hasMatch(line),
            )) {
          exportedClassDepth = 1;
        }
        final inContract = depth == 0 || depth == exportedClassDepth;
        if (inContract &&
            line.contains('shadcn.') &&
            (line.trimLeft().startsWith('typedef ') ||
                !RegExp(r'[:=]').hasMatch(line.split('shadcn.').first)) &&
            !line.trimLeft().startsWith('import ') &&
            !line.trimLeft().startsWith('//')) {
          violations.add('${file.path}:${index + 1}: ${line.trim()}');
        }
        depth += '{'.allMatches(line).length - '}'.allMatches(line).length;
        if (depth == 0) exportedClassDepth = -1;
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'G15 exported declarations must use independent types',
    );
  });

  test(
    'G8 rename-only visual wrappers and application page templates prohibited',
    () {
      final violations = <String>[];
      for (final file in dartFiles(Directory('${package.path}/lib'))) {
        final source = file.readAsStringSync();
        // Check for forbidden page template signatures or rename-only wrappers
        if (source.contains('class UiPage') ||
            source.contains('class UiScaffold') ||
            source.contains('class UiScreen')) {
          violations.add(file.path);
        }
      }
      expect(
        violations,
        isEmpty,
        reason:
            'G8 prohibited application page templates or rename-only wrappers',
      );
    },
  );

  test('G9 IntrinsicWidth and IntrinsicHeight prohibited in package lib', () {
    final violations = <String>[];
    for (final file in dartFiles(Directory('${package.path}/lib'))) {
      final source = file.readAsStringSync();
      if (source.contains('IntrinsicWidth') ||
          source.contains('IntrinsicHeight')) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason: 'G9 prohibited IntrinsicWidth/IntrinsicHeight layout passes',
    );
  });

  test(
    'G10 FormState ownership and GlobalKey<FormState> prohibited in lib',
    () {
      final violations = <String>[];
      for (final file in dartFiles(Directory('${package.path}/lib'))) {
        final source = file.readAsStringSync();
        if (source.contains('FormState') ||
            source.contains('GlobalKey<FormState>') ||
            source.contains('UiValidationEngine')) {
          violations.add(file.path);
        }
      }
      expect(
        violations,
        isEmpty,
        reason: 'G10 foundation must not own FormState or validation engines',
      );
    },
  );

  test(
    'G11 scroll widgets prohibited inside form primitives (lib/src/forms)',
    () {
      final violations = <String>[];
      final formsDir = Directory('${package.path}/lib/src/forms');
      for (final file in dartFiles(formsDir)) {
        final source = file.readAsStringSync();
        if (source.contains('SingleChildScrollView') ||
            source.contains('ListView') ||
            source.contains('CustomScrollView') ||
            source.contains('ScrollController')) {
          violations.add(file.path);
        }
      }
      expect(
        violations,
        isEmpty,
        reason: 'G11 form layout primitives must not own scrolling',
      );
    },
  );

  test('G12 top-level Expanded prohibited in form layout primitives', () {
    final violations = <String>[];
    final formsDir = Directory('${package.path}/lib/src/forms');
    for (final file in dartFiles(formsDir)) {
      final source = file.readAsStringSync();
      if (source.contains('Expanded(')) {
        violations.add(file.path);
      }
    }
    expect(
      violations,
      isEmpty,
      reason:
          'G12 top-level Expanded breaks unconstrained/scrollable form hosts',
    );
  });

  test(
    'G13 source-level guard: global focus hacks, stored context, and global singletons prohibited in lib/src',
    () {
      final violations = <String>[];
      for (final file in dartFiles(Directory('${package.path}/lib/src'))) {
        final source = file.readAsStringSync();
        if (source.contains('FocusManager.instance.primaryFocus') ||
            source.contains('GlobalKey<NavigatorState>') ||
            source.contains('static BuildContext') ||
            source.contains('static late BuildContext')) {
          violations.add(file.path);
        }
      }
      expect(
        violations,
        isEmpty,
        reason:
            'G13 prohibits global focus hacks, stored static contexts, or static navigator singletons',
      );
    },
  );

  test(
    'G14 source-level guard: generic page framework symbols prohibited in lib/src',
    () {
      final violations = <String>[];
      final forbiddenSymbols = [
        'class UiPage',
        'class UiFormPage',
        'class UiListPage',
        'class UiDetailsPage',
        'class UiTablePage',
        'class UiDashboardPage',
        'class UiSettingsPage',
        'class UiMasterDetailPage',
        'class UiPageHeader',
        'class UiPageBody',
        'class UiPageActions',
      ];
      for (final file in dartFiles(Directory('${package.path}/lib/src'))) {
        final source = file.readAsStringSync();
        for (final symbol in forbiddenSymbols) {
          if (source.contains(symbol)) {
            violations.add('${file.path}: $symbol');
          }
        }
      }
      expect(
        violations,
        isEmpty,
        reason:
            'G14 prohibits declaring generic page template wrappers in generic ui package',
      );
    },
  );
}
