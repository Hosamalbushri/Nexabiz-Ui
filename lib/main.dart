import 'package:flutter/services.dart';
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
  final _controllers = List.generate(3, (_) => TextEditingController());
  bool _rtl = false;
  bool _long = false;
  bool _narrow = true;
  bool _submitted = false;
  double _scale = 1;

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  String? get _error => !_submitted || _controllers[1].text.trim().isNotEmpty
      ? null
      : (_long
            ? 'Enter a display name before continuing. This long validation message must remain fully readable in a narrow container, with large text and in either writing direction.'
            : 'Enter a display name.');

  @override
  Widget build(BuildContext context) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(_scale)),
    child: Directionality(
      textDirection: _rtl ? TextDirection.rtl : TextDirection.ltr,
      child: shadcn.Scaffold(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(UiTokens.contentGap),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Foundation Workbench',
                  style: UiTextRole.heading.resolve(context),
                ),
                const SizedBox(height: UiTokens.contentGap),
                Wrap(
                  spacing: UiTokens.fieldGap,
                  runSpacing: UiTokens.fieldGap,
                  children: [
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
                      'content',
                      _long ? 'Long content' : 'Normal content',
                      () => setState(() => _long = !_long),
                    ),
                    _control(
                      'width',
                      _narrow ? 'Narrow: 420' : 'Wide: 960',
                      () => setState(() => _narrow = !_narrow),
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
                          UiFormLayout(
                            children: [
                              UiTextField(
                                label: 'Optional title',
                                controller: _controllers[0],
                                placeholder: 'Type here',
                              ),
                              UiTextField(
                                label: _long
                                    ? 'Display name with a deliberately long label that is allowed to wrap naturally'
                                    : 'Display name',
                                requiredIndicator: 'Required',
                                description: _long
                                    ? 'Use any descriptive text. Directionality is a layout choice independent of the language of this example.'
                                    : 'Shown in this preview.',
                                helper: 'Required for this demonstration.',
                                controller: _controllers[1],
                                error: _error,
                                onChanged: (_) => setState(() {}),
                              ),
                              UiTextField(
                                label: 'Short note',
                                controller: _controllers[2],
                                helper: _long
                                    ? 'Supporting text can take as many lines as it needs without imposing a fixed height on the complete field.'
                                    : 'An optional single-line input.',
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) =>
                                    setState(() => _submitted = true),
                              ),
                            ],
                          ),
                          const SizedBox(height: UiTokens.contentGap),
                          Wrap(
                            spacing: UiTokens.fieldGap,
                            runSpacing: UiTokens.fieldGap,
                            children: [
                              _control(
                                'validate',
                                'Validate',
                                () => setState(() => _submitted = true),
                              ),
                              _control(
                                'reset',
                                'Reset',
                                () => setState(() {
                                  for (final controller in _controllers) {
                                    controller.clear();
                                  }
                                  _submitted = false;
                                }),
                              ),
                            ],
                          ),
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
