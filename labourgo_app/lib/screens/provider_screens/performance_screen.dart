import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

// ─────────────────────────────────────────────
//  App Colors
// ─────────────────────────────────────────────
class AppColors {
  static const primary = Color(0xFF4682B4);
  static const accent = Color(0xFF5CE1E6);
  static const white = Colors.white;
  static const background = Color(0xFFF0F4F8);

  static const primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// ─────────────────────────────────────────────
//  PerformanceScreen — same logic, new UI
// ─────────────────────────────────────────────
class PerformanceScreen extends StatefulWidget {
  const PerformanceScreen({super.key});

  @override
  State<PerformanceScreen> createState() => _PerformanceScreenState();
}

class _PerformanceScreenState extends State<PerformanceScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _performance;

  AnimationController? _fadeCtrl;
  Animation<double>? _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
    _loadPerformance();
  }

  @override
  void dispose() {
    _fadeCtrl?.dispose();
    super.dispose();
  }

  // ── ORIGINAL LOGIC (unchanged) ─────────────

  Future<int?> _resolveProviderId() async {
    final prefs = await SharedPreferences.getInstance();
    final storedId = prefs.getInt('provider_id');
    if (storedId != null) return storedId;

    final email = prefs.getString('user_email') ?? '';
    final phone = prefs.getString('user_phone') ?? '';
    if (email.isEmpty || phone.isEmpty) return null;

    final provider = await ApiService.findProviderByEmailPhone(email, phone);
    final providerId = provider?['id'];
    if (providerId is int) {
      await prefs.setInt('provider_id', providerId);
      return providerId;
    }
    if (providerId is String) {
      final parsed = int.tryParse(providerId);
      if (parsed != null) {
        await prefs.setInt('provider_id', parsed);
        return parsed;
      }
    }
    return null;
  }

  Future<void> _loadPerformance() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final providerId = await _resolveProviderId();
      if (!mounted) return;
      if (providerId == null) {
        setState(() => _error = 'Provider not found');
        _fadeCtrl?.forward(from: 0);
        return;
      }
      final data = await ApiService.getProviderPerformance(providerId);
      if (!mounted) return;
      setState(() => _performance = data);
      _fadeCtrl?.forward(from: 0);
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Failed to load performance');
        _fadeCtrl?.forward(from: 0);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // ── Parsed values (from original build logic) ──

  double? get _ratingNumber {
    final v = _performance?['rating'];
    return v is num ? v.toDouble() : double.tryParse(v?.toString() ?? '');
  }

  int? get _jobsCount {
    final v = _performance?['jobs_completed'];
    return v is num ? v.toInt() : int.tryParse(v?.toString() ?? '');
  }

  String get _ratingText =>
      _ratingNumber != null ? _ratingNumber!.toStringAsFixed(1) : 'N/A';

  String get _jobsText => _jobsCount?.toString() ?? '0';

  List<dynamic> get _reviews =>
      (_performance?['reviews'] as List<dynamic>?) ?? [];

  // ── BUILD ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading ? _buildLoader() : _buildContent(),
    );
  }

  // ── Loader ─────────────────────────────────

  Widget _buildLoader() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(
                  strokeWidth: 2.5, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Loading performance…',
              style: TextStyle(color: AppColors.primary, fontSize: 13)),
        ],
      ),
    );
  }

  // ── Main content ───────────────────────────

  Widget _buildContent() {
    final fadeAnim = _fadeAnim ?? const AlwaysStoppedAnimation(1.0);

    return FadeTransition(
      opacity: fadeAnim,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(child: _buildHeroHeader()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) _buildErrorBanner(),
                  _buildStatCards(),
                  const SizedBox(height: 20),
                  _buildRatingBreakdown(),
                  const SizedBox(height: 20),
                  _buildReviewsSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Header ────────────────────────────

  Widget _buildHeroHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.07)),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.05)),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                children: [
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const Text('Performance Overview',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600)),
                      _HeaderBtn(
                        icon: Icons.refresh_rounded,
                        onTap: _loadPerformance,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Big rating display
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Colors.white.withOpacity(0.4), width: 2.5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          _ratingText,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w800),
                        ),
                        const Text('/ 5.0',
                            style: TextStyle(
                                color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Star row
                  _buildStarRow(_ratingNumber ?? 0),
                  const SizedBox(height: 6),
                  const Text('Average Rating',
                      style:
                          TextStyle(color: Colors.white70, fontSize: 12)),
                  const SizedBox(height: 16),

                  // Pills row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatPill(
                        icon: Icons.work_outline_rounded,
                        iconColor: Colors.white70,
                        label: '$_jobsText Jobs Completed',
                      ),
                      const SizedBox(width: 10),
                      _StatPill(
                        icon: Icons.rate_review_outlined,
                        iconColor: Colors.white70,
                        label:
                            '${_reviews.length} Review${_reviews.length != 1 ? 's' : ''}',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Star row helper ────────────────────────

  Widget _buildStarRow(double rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < rating.floor();
        final half = !filled && (i < rating);
        return Icon(
          filled
              ? Icons.star_rounded
              : half
                  ? Icons.star_half_rounded
                  : Icons.star_outline_rounded,
          color: const Color(0xFFFFD700),
          size: 20,
        );
      }),
    );
  }

  // ── Stat Cards ─────────────────────────────

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFE8F2FB),
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFFFAA00),
            label: 'Avg Rating',
            value: _ratingText,
            sub: 'out of 5.0',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFE0F8F9),
            icon: Icons.check_circle_outline_rounded,
            iconColor: const Color(0xFF2AB0BC),
            label: 'Jobs Done',
            value: _jobsText,
            sub: 'completed',
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            iconBg: const Color(0xFFEEF2FF),
            icon: Icons.rate_review_outlined,
            iconColor: const Color(0xFF6366F1),
            label: 'Reviews',
            value: '${_reviews.length}',
            sub: 'received',
          ),
        ),
      ],
    );
  }

  // ── Rating Breakdown ───────────────────────

  Widget _buildRatingBreakdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('RATING BREAKDOWN',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.08)),
          const SizedBox(height: 16),
          ...List.generate(5, (i) {
            final star = 5 - i;
            // Count reviews with this star from API data
            final count = _reviews
                .where((r) {
                  final rv = r['rating'];
                  final rn = rv is num
                      ? rv.toInt()
                      : int.tryParse(rv?.toString() ?? '') ?? 0;
                  return rn == star;
                })
                .length;
            final total = _reviews.isEmpty ? 1 : _reviews.length;
            final frac = count / total;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                children: [
                  Icon(Icons.star_rounded,
                      color: const Color(0xFFFFAA00), size: 14),
                  const SizedBox(width: 4),
                  Text('$star',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E3A5F))),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: frac,
                        minHeight: 7,
                        backgroundColor: const Color(0xFFEDF3F9),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  SizedBox(
                    width: 20,
                    child: Text('$count',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF8FA8C0),
                            fontWeight: FontWeight.w500)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Reviews Section ────────────────────────

  Widget _buildReviewsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('CUSTOMER REVIEWS',
                style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.08)),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text('${_reviews.length} total',
                  style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary)),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _reviews.isEmpty
            ? _buildEmptyReviews()
            : Column(
                children: _reviews
                    .map<Widget>((r) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _buildReviewCard(r),
                        ))
                    .toList(),
              ),
      ],
    );
  }

  Widget _buildEmptyReviews() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FB),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(Icons.reviews_outlined,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('No reviews yet',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F))),
          const SizedBox(height: 4),
          const Text('Reviews from customers will appear here',
              style: TextStyle(fontSize: 12, color: Color(0xFF8FA8C0))),
        ],
      ),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final rv = review['rating'];
    final rn = rv is num
        ? rv.toDouble()
        : double.tryParse(rv?.toString() ?? '') ?? 0;
    final name = review['customer_name']?.toString() ?? 'Customer';
    final comment = review['comment']?.toString() ?? '';
    final date = review['date']?.toString() ?? '';

    // Initials from name
    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Avatar
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(initials,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A5F))),
                    if (date.isNotEmpty)
                      Text(date,
                          style: const TextStyle(
                              fontSize: 11, color: Color(0xFF8FA8C0))),
                  ],
                ),
              ),
              // Star badge
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.star_rounded,
                        color: Color(0xFFFFAA00), size: 13),
                    const SizedBox(width: 3),
                    Text(rn.toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF996600))),
                  ],
                ),
              ),
            ],
          ),
          if (comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Divider(height: 1, color: Color(0xFFEDF3F9)),
            const SizedBox(height: 10),
            Text(comment,
                style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF5A7A9A),
                    height: 1.5)),
          ],
        ],
      ),
    );
  }

  // ── Error Banner ───────────────────────────

  Widget _buildErrorBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFCEBEB),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFF09595), width: 0.5),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFE24B4A), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(_error!,
                style: const TextStyle(
                    color: Color(0xFFA32D2D),
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable Widgets
// ─────────────────────────────────────────────

class _HeaderBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  const _StatPill(
      {required this.icon, required this.iconColor, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: iconColor, size: 13),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String sub;

  const _StatCard({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
                color: iconBg, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E3A5F))),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary),
              textAlign: TextAlign.center),
          Text(sub,
              style: const TextStyle(
                  fontSize: 10, color: Color(0xFF8FA8C0)),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
