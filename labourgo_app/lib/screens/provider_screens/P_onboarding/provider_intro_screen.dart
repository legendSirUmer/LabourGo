import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';

const _kBlue = AppColors.primary;
const _kCyan = AppColors.accent;
const _kWhite = Colors.white;
const _kBg = Color(0xFFF4F8FD);
const _kBorder = Color(0xFFD0E4F5);
const _kSubText = Color(0xFF7A9ABF);

class ProviderIntroScreen extends StatefulWidget {
  const ProviderIntroScreen({super.key});

  @override
  State<ProviderIntroScreen> createState() => _ProviderIntroScreenState();
}

class _ProviderIntroScreenState extends State<ProviderIntroScreen> {
  bool _loading = true;
  String? _error;
  int? _providerCount;
  int? _verifiedCount;
  double? _avgRating;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final providers = await ApiService.fetchProviders();
      int verified = 0;
      int ratingCount = 0;
      double ratingSum = 0;

      for (final provider in providers) {
        final status = (provider['verification_status'] ?? '').toString();
        if (status == 'approved') {
          verified += 1;
        }

        final rating = provider['rating'];
        if (rating is num) {
          ratingCount += 1;
          ratingSum += rating.toDouble();
        }
      }

      setState(() {
        _providerCount = providers.length;
        _verifiedCount = verified;
        _avgRating = ratingCount > 0 ? ratingSum / ratingCount : null;
      });
    } catch (e) {
      setState(() => _error = 'Unable to load stats');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatCount(int? value) {
    if (value == null) return '--';
    return value.toString();
  }

  String _formatRating(double? value) {
    if (value == null) return '--';
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final joinLabel = 'Join ${_formatCount(_providerCount)} Workers';

    return Scaffold(
      backgroundColor: _kBg,
      // ── Use Column + Expanded so everything fits in one screen ──
      body: SafeArea(
        child: Column(
          children: [
            // ── Gradient header ──
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(28),
                  bottomRight: Radius.circular(28),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Close button row
                  if (canPop)
                    Align(
                      alignment: Alignment.topRight,
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: _kWhite.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: _kWhite, size: 16),
                        ),
                      ),
                    ),

                  // Icon + badge + title row
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _kWhite.withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.engineering_rounded,
                            color: _kWhite, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: _kCyan,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.bolt_rounded,
                                    color: _kBlue, size: 11),
                                const SizedBox(width: 3),
                                Text(
                                  joinLabel,
                                  style: const TextStyle(
                                    color: _kBlue,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'LabourGo',
                            style: TextStyle(
                              color: _kWhite,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    'Become a Verified\nService Provider',
                    style: TextStyle(
                      color: _kWhite,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Poppins',
                      height: 1.25,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    "Pakistan's fastest growing platform for skilled workers.",
                    style: TextStyle(
                      color: _kWhite.withOpacity(0.75),
                      fontSize: 12,
                      fontFamily: 'Poppins',
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Stats row
                  Row(
                    children: [
                      _StatChip(label: _formatCount(_providerCount), sub: 'Providers'),
                      const SizedBox(width: 10),
                      _StatChip(label: _formatCount(_verifiedCount), sub: 'Verified'),
                      const SizedBox(width: 10),
                      _StatChip(label: '${_formatRating(_avgRating)}★', sub: 'Avg Rating'),
                    ],
                  ),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 8),
                      child: SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_kWhite),
                        ),
                      ),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: TextStyle(
                          color: _kWhite.withOpacity(0.8),
                          fontSize: 11,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Feature cards — Expanded so they fill remaining space ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Why Join LabourGo?',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _kBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 10),
                    _FeatureCard(
                      icon: Icons.work_outline_rounded,
                      title: 'Increased Job Opportunities',
                      subtitle: 'Get matched with customers near you instantly.',
                      color: _kBlue,
                    ),
                    const SizedBox(height: 8),
                    _FeatureCard(
                      icon: Icons.verified_outlined,
                      title: 'Enhanced Professional Reputation',
                      subtitle: 'Build your profile and collect verified reviews.',
                      color: _kCyan,
                      titleColor: _kBlue,
                    ),
                    const SizedBox(height: 8),
                    _FeatureCard(
                      icon: Icons.dashboard_outlined,
                      title: 'Convenient Business Management',
                      subtitle: 'Manage bookings, schedule and earnings easily.',
                      color: _kBlue,
                    ),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ──
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pushNamed(context, '/provider_form'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kBlue,
                        foregroundColor: _kWhite,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Register Now',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Poppins',
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 17),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, '/provider_signin'),
                    child: const Text(
                      'Already a provider? Sign in',
                      style: TextStyle(
                        color: _kBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Stat chip ──
class _StatChip extends StatelessWidget {
  final String label;
  final String sub;
  const _StatChip({required this.label, required this.sub});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _kWhite.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _kWhite.withOpacity(0.25), width: 1),
      ),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  color: _kWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins')),
          Text(sub,
              style: TextStyle(
                  color: _kWhite.withOpacity(0.7),
                  fontSize: 9,
                  fontFamily: 'Poppins')),
        ],
      ),
    );
  }
}

// ── Feature card ──
class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color? titleColor;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: _kBlue.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: titleColor ?? color,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: _kSubText,
                    fontFamily: 'Poppins',
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}