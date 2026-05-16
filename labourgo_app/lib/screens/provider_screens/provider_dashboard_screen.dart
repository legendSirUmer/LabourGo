import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/provider_bottom_navigation.dart';

const _kBg = Color(0xFFF4F8FD);

class ProviderDashboardScreen extends StatefulWidget {
  const ProviderDashboardScreen({super.key});

  @override
  State<ProviderDashboardScreen> createState() =>
      _ProviderDashboardScreenState();
}

class _ProviderDashboardScreenState extends State<ProviderDashboardScreen> {

  bool _loading = true;
  String? _error;
  Map<String, dynamic>? _provider;

  @override
  void initState() {
    super.initState();
    _loadProvider();
  }

  Future<void> _loadProvider() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final storedId = prefs.getInt('provider_id');
      Map<String, dynamic>? provider;

      if (storedId != null) {
        provider = await ApiService.getProviderById(storedId);
      } else {
        final email = prefs.getString('user_email') ?? '';
        final phone = prefs.getString('user_phone') ?? '';

        if (email.isEmpty || phone.isEmpty) {
          setState(() {
            _error = 'Missing account details. Please sign in again.';
          });
          return;
        }

        provider = await ApiService.findProviderByEmailPhone(
          email,
          phone,
        );
      }

      if (provider == null) {
        setState(() {
          _error = 'Provider profile not found.';
        });
        return;
      }

      setState(() {
        _provider = provider;
      });

      final providerId = provider['id'];
      if (providerId is int && storedId != providerId) {
        await prefs.setInt('provider_id', providerId);
      } else if (providerId is String) {
        final parsed = int.tryParse(providerId);
        if (parsed != null && storedId != parsed) {
          await prefs.setInt('provider_id', parsed);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load provider data.';
      });
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _handleLogout() async {
    await ApiService.clearToken();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    final providerName =
        (_provider?['name'] ?? 'Provider').toString().trim();
    final ratingValue = _provider?['rating'];
    final jobsValue = _provider?['jobs_completed'];
    final priceValue = _provider?['price_per_hour'];
    final availabilityValue = _provider?['availability'];
    final skillsValue = _provider?['skills'];
    final verificationStatus = _provider?['verification_status'];
    final profileImageUrl = ApiService.resolveImageUrl(
      _provider?['image']?.toString(),
    );
    final ratingNumber = ratingValue is num
      ? ratingValue.toDouble()
      : double.tryParse(ratingValue?.toString() ?? '');
    final ratingText = ratingNumber != null
      ? 'Rating ${ratingNumber.toStringAsFixed(1)}'
      : 'Rating -';
    final jobsCount = jobsValue is num
      ? jobsValue.toInt()
      : int.tryParse(jobsValue?.toString() ?? '');
    final jobsText = jobsCount != null
      ? '$jobsCount Job${jobsCount == 1 ? '' : 's'}'
      : 'Jobs -';
    final pricePerHour = priceValue is num
      ? priceValue.toDouble()
      : double.tryParse(priceValue?.toString() ?? '');
    final earnings = (pricePerHour != null && jobsCount != null)
      ? pricePerHour * jobsCount
      : null;
    final earningsText = earnings != null
      ? 'PKR ${earnings.toStringAsFixed(0)}'
      : 'PKR -';
    final availabilityText = availabilityValue == true
      ? 'Available'
      : availabilityValue == false
        ? 'Unavailable'
        : 'Availability -';
    final skillsText = (skillsValue ?? '').toString().trim().isNotEmpty
      ? (skillsValue ?? '').toString().trim()
      : 'Skills not set';
    final statusText = _formatStatus(verificationStatus?.toString());

    final activities = _buildActivities(
      jobsCount: jobsCount,
      ratingValue: ratingValue,
      statusText: statusText,
      pricePerHour: pricePerHour,
    );

    return Scaffold(
      backgroundColor: _kBg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            children: [
              _DashboardHeader(
                providerName: providerName,
                profileImageUrl: profileImageUrl,
                onLogout: _handleLogout,
              ),

              const SizedBox(height: 18),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_loading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 24),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          _error!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    _ProviderSummaryCard(
                      skillsText: skillsText,
                      availabilityText: availabilityText,
                      experienceYears: _provider?['experience'],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.account_balance_wallet_rounded,
                            title: 'Total Earnings',
                            value: earningsText,
                            iconColor: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.trending_up_rounded,
                            title: 'Performance',
                            value: ratingText,
                            iconColor: Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      children: [
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.work_rounded,
                            title: 'Jobs Completed',
                            value: jobsText,
                            iconColor: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _InfoCard(
                            icon: Icons.verified_rounded,
                            title: 'Verification',
                            value: statusText,
                            iconColor: Colors.purple,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 12),

                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.35,
                      children: [
                        _ActionTile(
                          icon: Icons.person_rounded,
                          title: 'Profile',
                          subtitle: 'View details',
                          onTap: () {
                            Navigator.pushNamed(context, '/profile');
                          },
                        ),
                        _ActionTile(
                          icon: Icons.calendar_month_rounded,
                          title: 'Availability',
                          subtitle: 'Update time',
                          onTap: () {
                            Navigator.pushNamed(context, '/availability');
                          },
                        ),
                        _ActionTile(
                          icon: Icons.price_change_rounded,
                          title: 'Pricing',
                          subtitle: 'Set charges',
                          onTap: () {
                            Navigator.pushNamed(context, '/pricing');
                          },
                        ),
                        _ActionTile(
                          icon: Icons.bar_chart_rounded,
                          title: 'Performance',
                          subtitle: 'View stats',
                          onTap: () {
                            Navigator.pushNamed(context, '/performance');
                          },
                        ),
                        _ActionTile(
                          icon: Icons.workspace_premium_rounded,
                          title: 'Certificates',
                          subtitle: 'Upload proof',
                          onTap: () {
                            Navigator.pushNamed(context, '/certificates');
                          },
                        ),
                        _ActionTile(
                          icon: Icons.book_online_rounded,
                          title: 'Bookings',
                          subtitle: 'View jobs',
                          onTap: () {
                            Navigator.pushNamed(context, '/view-bookings');
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    const Text(
                      'Recent Activity',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        fontFamily: 'Poppins',
                      ),
                    ),

                    const SizedBox(height: 12),

                    if (activities.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No recent activity yet.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                            fontFamily: 'Poppins',
                          ),
                        ),
                      )
                    else
                      ...activities
                          .map(
                            (item) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _ActivityCard(
                                icon: item.icon,
                                title: item.title,
                                subtitle: item.subtitle,
                              ),
                            ),
                          )
                          .toList(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatStatus(String? status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return 'Status -';
    }
  }

  List<_ActivityData> _buildActivities({
    required int? jobsCount,
    required dynamic ratingValue,
    required String statusText,
    required double? pricePerHour,
  }) {
    final items = <_ActivityData>[];

    if (jobsCount != null) {
      items.add(
        _ActivityData(
          icon: Icons.check_circle_rounded,
          title: 'Jobs completed',
          subtitle: 'You have completed $jobsCount job(s).',
        ),
      );
    }

    final ratingNumber = ratingValue is num
        ? ratingValue.toDouble()
        : double.tryParse(ratingValue?.toString() ?? '');

    if (ratingNumber != null) {
      items.add(
        _ActivityData(
          icon: Icons.star_rounded,
          title: 'Current rating',
          subtitle: 'Your rating is ${ratingNumber.toStringAsFixed(1)}.',
        ),
      );
    }

    if (statusText != 'Status -') {
      items.add(
        _ActivityData(
          icon: Icons.verified_rounded,
          title: 'Verification status',
          subtitle: 'Status: $statusText',
        ),
      );
    }

    if (pricePerHour != null) {
      items.add(
        _ActivityData(
          icon: Icons.payments_rounded,
          title: 'Hourly rate',
          subtitle: 'You charge PKR ${pricePerHour.toStringAsFixed(0)} per hour.',
        ),
      );
    }

    return items;
  }
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.providerName,
    required this.profileImageUrl,
    required this.onLogout,
  });

  final String providerName;
  final String? profileImageUrl;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'LabourGo',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: onLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  color: AppColors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: AppColors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 34,
                  backgroundColor: AppColors.white,
                  backgroundImage: profileImageUrl != null &&
                          profileImageUrl!.isNotEmpty
                      ? NetworkImage(profileImageUrl!)
                      : null,
                  child: profileImageUrl == null || profileImageUrl!.isEmpty
                      ? const Icon(
                          Icons.person_rounded,
                          size: 38,
                          color: AppColors.primary,
                        )
                      : null,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome back,',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      providerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: const Text(
                        'Provider Dashboard',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProviderSummaryCard extends StatelessWidget {
  const _ProviderSummaryCard({
    required this.skillsText,
    required this.availabilityText,
    required this.experienceYears,
  });

  final String skillsText;
  final String availabilityText;
  final dynamic experienceYears;

  @override
  Widget build(BuildContext context) {
    final expValue = experienceYears is num
        ? (experienceYears as num).toInt()
        : null;
    final expText = expValue != null ? '$expValue years experience' : 'Experience -';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.today_rounded,
              color: AppColors.white,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Provider Snapshot',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  skillsText,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$availabilityText • $expText',
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Poppins',
                  ),
                ),
              ],
            ),
          ),

          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.black38,
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.iconColor,
  });

  final IconData icon;
  final String title;
  final String value;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 128,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.09),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: iconColor,
            size: 28,
          ),
          const Spacer(),
          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(20),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.07),
                blurRadius: 14,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: AppColors.white,
                  size: 21,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.black45,
                  fontSize: 11,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ActivityCard extends StatelessWidget {
  const _ActivityCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.primary.withOpacity(0.08),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: AppColors.accent.withOpacity(0.22),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 24,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Poppins',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    fontFamily: 'Poppins',
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

class _ActivityData {
  const _ActivityData({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;
}
