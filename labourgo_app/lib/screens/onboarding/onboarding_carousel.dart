import 'package:flutter/material.dart';
import '../../theme/app_theme.dart'; // 👈 make sure this file has AppColors

// ─────────────────────────────────────────────
// DATA MODEL for each onboarding page
// ─────────────────────────────────────────────
class _PageData {
  final String title;
  final String subtitle;
  final IconData icon;

  const _PageData({
    required this.title,
    required this.subtitle,
    required this.icon,
  });
}

const List<_PageData> _pages = [
  _PageData(
    title: 'Find Trusted Workers',
    subtitle:
        'Connect with verified, skilled workers in your area. Available on-demand.',
    icon: Icons.construction_rounded,
  ),
  _PageData(
    title: 'Verified Professionals',
    subtitle:
        'Every worker on LabourGo is background-verified. No more guesswork — just reliable service from trusted experts.',
    icon: Icons.verified_user_rounded,
  ),
  _PageData(
    title: 'Real-Time Booking',
    subtitle:
        'Book a worker instantly with live availability and smart scheduling. Get updates on your booking status in real-time.',
    icon: Icons.schedule_rounded,
  ),
  _PageData(
    title: 'Secure Payments',
    subtitle:
        'Pay seamlessly through the app with full transaction transparency. No cash hassles — just secure, digital payments.',
    icon: Icons.credit_card_rounded,
  ),
];

// ─────────────────────────────────────────────
// MAIN CAROUSEL SCREEN
// ─────────────────────────────────────────────
class OnboardingCarousel extends StatefulWidget {
  const OnboardingCarousel({super.key});

  @override
  State<OnboardingCarousel> createState() => _OnboardingCarouselState();
}

class _OnboardingCarouselState extends State<OnboardingCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _goNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _goToLogin();
    }
  }

  void _goToLogin() {
    Navigator.pushReplacementNamed(context, '/login');
  }

  String get _buttonLabel {
    if (_currentPage == 0) return 'Get Started';
    if (_currentPage == _pages.length - 1) return 'Login';
    return 'Next';
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── Page content ──
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return _OnboardingPageView(
                page: _pages[index],
                showProviderButton: index == _pages.length - 1,
              );
            },
          ),

          // ── Top bar ──
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (_currentPage > 0) {
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_currentPage + 1) / _pages.length,
                        backgroundColor:
                            AppColors.accent.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 5,
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  GestureDetector(
                    onTap: _goToLogin,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom button ──
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 20,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _goNext,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      _buttonLabel,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// SINGLE PAGE WIDGET
// ─────────────────────────────────────────────
class _OnboardingPageView extends StatelessWidget {
  final _PageData page;
  final bool showProviderButton;

  const _OnboardingPageView({
    required this.page,
    required this.showProviderButton,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Column(
      children: [
        SizedBox(
          height: size.height * 0.50,
          child: Stack(
            children: [
              ClipPath(
                clipper: _WaveClipper(),
                child: Container(
                  width: double.infinity,
                  height: size.height * 0.50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                  ),
                ),
              ),

              Positioned(
                top: size.height * 0.12,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.25),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.6),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      page.icon,
                      size: 70,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            child: Column(
              children: [
                Text(
                  page.title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 14),

                Text(
                  page.subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary,
                    fontFamily: 'Poppins',
                    height: 1.7,
                  ),
                ),

                if (showProviderButton) ...[
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    child: const Text('Service Provider? Start here'),
                  ),
                ],
              ],
            ),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// WAVE CLIPPER
// ─────────────────────────────────────────────
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height - 60);
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 20,
      size.width,
      size.height - 60,
    );
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper old) => false;
}