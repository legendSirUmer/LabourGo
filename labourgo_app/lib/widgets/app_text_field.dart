import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class AppTextField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscure;
  final TextEditingController? controller;
  final TextInputType keyboard;
  final int maxLines;
  final String? error;

  const AppTextField({
    super.key,
    required this.label,
    required this.hint,
    this.prefixIcon,
    this.suffix,
    this.obscure = false,
    this.controller,
    this.keyboard = TextInputType.text,
    this.maxLines = 1,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.primary, size: 20)
                : null,
            suffixIcon: suffix,
            errorText: error,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}