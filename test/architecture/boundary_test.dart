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
      "export 'src/fields/field_shell.dart' show UiFieldShell;",
      "export 'src/fields/text_field.dart' show UiTextField;",
      "export 'src/forms/form_layout.dart' show UiFormLayout;",
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
      if (source.contains('package:flutter/material.dart') ||
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
}
