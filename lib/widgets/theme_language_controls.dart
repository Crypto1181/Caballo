import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import 'language_toggle.dart';

class ThemeLanguageControls extends StatelessWidget {
  final double spacing;

  const ThemeLanguageControls({super.key, this.spacing = 8});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final iconColor = isDark ? Colors.white : Colors.black;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(
            isDark ? Icons.light_mode : Icons.dark_mode,
            color: iconColor,
          ),
          onPressed: () => themeProvider.toggleTheme(),
          tooltip: isDark ? 'Light mode' : 'Dark mode',
        ),
        SizedBox(width: spacing),
        const LanguageToggle(),
      ],
    );
  }
}

