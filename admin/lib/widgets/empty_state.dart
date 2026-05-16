import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class EmptyState extends StatelessWidget {
  final String message;
  final IconData icon;
  const EmptyState({super.key, required this.message, this.icon = Icons.search_off});

  @override
  Widget build(BuildContext context) {
    return Center(child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 64, color: AppTheme.textSecondary.withOpacity(0.4)),
        const SizedBox(height: 12),
        Text(message, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
      ],
    ));
  }
}