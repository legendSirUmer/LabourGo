import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class SectionTitle extends StatelessWidget {
  final String title;
  final Widget? action;
  const SectionTitle(this.title, {super.key, this.action});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(children: [
        Text(title, style: const TextStyle(
            fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
        const Spacer(),
        if (action != null) action!,
      ]),
    );
  }
}