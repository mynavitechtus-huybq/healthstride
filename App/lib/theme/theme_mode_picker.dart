import 'package:flutter/material.dart';

class ThemeModePickerButton extends StatelessWidget {
  const ThemeModePickerButton({
    required this.themeMode,
    required this.onThemeModeChanged,
    this.style,
    super.key,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onThemeModeChanged;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () => _showPicker(context),
      tooltip: 'Change theme',
      style: style,
      icon: Icon(_iconFor(themeMode)),
    );
  }

  Future<void> _showPicker(BuildContext context) async {
    final selected = await showModalBottomSheet<ThemeMode>(
      context: context,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Theme',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            for (final option in _themeOptions)
              ListTile(
                leading: Icon(option.icon),
                title: Text(option.label),
                trailing: themeMode == option.mode
                    ? Icon(
                        Icons.check_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    : null,
                onTap: () => Navigator.of(context).pop(option.mode),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (selected != null) onThemeModeChanged(selected);
  }
}

IconData _iconFor(ThemeMode themeMode) {
  return switch (themeMode) {
    ThemeMode.light => Icons.light_mode_rounded,
    ThemeMode.dark => Icons.dark_mode_rounded,
    ThemeMode.system => Icons.brightness_6_rounded,
  };
}

class _ThemeOption {
  const _ThemeOption(this.mode, this.label, this.icon);

  final ThemeMode mode;
  final String label;
  final IconData icon;
}

const _themeOptions = [
  _ThemeOption(ThemeMode.light, 'Light', Icons.light_mode_rounded),
  _ThemeOption(ThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
  _ThemeOption(ThemeMode.system, 'System', Icons.brightness_6_rounded),
];
