import 'package:flutter/material.dart';
import 'onboarding_carousel.dart';
import '../../theme/app_theme.dart'; // 👈 make sure this file has AppColors


class OnboardingLanguage extends StatefulWidget {
  const OnboardingLanguage({super.key});

  @override
  State<OnboardingLanguage> createState() => _OnboardingLanguageState();
}

class _OnboardingLanguageState extends State<OnboardingLanguage> {
  String _selected = 'English';

  final List<String> _languages = [
    'English',
    'اردو (Urdu)',
    'پنجابی (Punjabi)',
    'سندھی (Sindhi)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Spacer(flex: 2),

              // Globe icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFB8D8F5).withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.language_rounded,
                  color: Color(0xFF4A90D9),
                  size: 28,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Select language',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A2A3A),
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Choose your preferred language',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primary,
                  fontFamily: 'Poppins',
                ),
              ),

              const SizedBox(height: 32),

              // Language dropdown
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFB8D8F5),
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  color: const Color(0xFFF5F9FF),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selected,
                    isExpanded: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF4A90D9),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF1A2A3A),
                      fontFamily: 'Poppins',
                    ),
                    items: _languages
                        .map(
                          (lang) => DropdownMenuItem(
                            value: lang,
                            child: Text(lang),
                          ),
                        )
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selected = val);
                    },
                  ),
                ),
              ),

              const Spacer(flex: 3),

              // Continue button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const OnboardingCarousel(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4A90D9),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Continue',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}