import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isPrimary;
  final bool isFullWidth;
  final IconData? icon;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isPrimary = true,
    this.isFullWidth = true,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    Widget buttonContent = icon == null
        ? Text(text)
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(text),
            ],
          );

    Widget button;
    if (isPrimary) {
      button = ElevatedButton(
        onPressed: onPressed,
        style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
          elevation: MaterialStateProperty.resolveWith<double>(
            (Set<MaterialState> states) {
              if (states.contains(MaterialState.pressed)) return 4;
              return 0; // flat by default
            },
          ),
          shadowColor: MaterialStateProperty.all(AppTheme.primaryBlue),
        ),
        child: buttonContent,
      );
    } else {
      button = OutlinedButton(
        onPressed: onPressed,
        child: buttonContent,
      );
    }

    if (isFullWidth) {
      return SizedBox(
        width: double.infinity,
        child: button,
      );
    }
    return button;
  }
}
