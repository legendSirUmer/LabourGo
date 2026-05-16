import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';
import '../../widgets/provider_bottom_navigation.dart';

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

class AvailabilityScreen extends StatefulWidget {
  const AvailabilityScreen({super.key});

  @override
  State<AvailabilityScreen> createState() => _AvailabilityScreenState();
}

class _AvailabilityScreenState extends State<AvailabilityScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  bool _saving = false;
  bool _isAvailable = false;
  String? _error;

  AnimationController? _fadeCtrl;
  Animation<double>? _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
    _loadAvailability();
  }

  @override
  void dispose() {
    _fadeCtrl?.dispose();
    super.dispose();
  }

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

  bool _parseAvailability(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) return value != 0;
    return false;
  }

  Future<void> _loadAvailability() async {
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

      final data = await ApiService.getProviderById(providerId);
      if (!mounted) return;

      setState(() {
        _isAvailable = _parseAvailability(data['availability']);
      });
      _fadeCtrl?.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load availability');
      _fadeCtrl?.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    if (_saving) return;
    final previous = _isAvailable;

    setState(() {
      _saving = true;
      _isAvailable = value;
    });

    try {
      final providerId = await _resolveProviderId();
      if (!mounted) return;
      if (providerId == null) {
        setState(() {
          _error = 'Provider not found';
          _isAvailable = previous;
        });
        return;
      }

      final data = await ApiService.toggleAvailability(providerId);
      if (!mounted) return;

      setState(() {
        _isAvailable = _parseAvailability(data['availability']);
      });

      _showSnack(
        _isAvailable
            ? 'You are now available for jobs'
            : 'You are now unavailable for jobs',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isAvailable = previous);
      _showSnack('Failed to update availability: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor:
            isError ? const Color(0xFFE24B4A) : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Color get _statusColor =>
      _isAvailable ? const Color(0xFF1FA971) : const Color(0xFFE24B4A);

  String get _statusTitle =>
      _isAvailable ? 'Available for jobs' : 'Currently unavailable';

  String get _statusSubtitle => _isAvailable
      ? 'Customers can discover and book your services now.'
      : 'Pause incoming work until you are ready again.';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading ? _buildLoader() : _buildContent(),
      bottomNavigationBar: ProviderBottomNavigation(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          switch (index) {
            case 1:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            case 2:
              Navigator.pushReplacementNamed(context, '/view-bookings');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/customer_dashboard');
              break;
          }
        },
      ),
    );
  }

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
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading availability...',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }

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
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildAvailabilityControlCard(),
                  const SizedBox(height: 20),
                  _buildInfoCard(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                color: Colors.white.withOpacity(0.07),
              ),
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
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const Text(
                        'Availability',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _HeaderBtn(
                        icon: Icons.refresh_rounded,
                        onTap: _loadAvailability,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.toggle_on_outlined,
                      color: Colors.white,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Manage Availability',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Control whether customers can book your services right now',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _isAvailable
                              ? Icons.check_circle_outline_rounded
                              : Icons.pause_circle_outline_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _isAvailable ? 'Status: Available' : 'Status: Unavailable',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
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
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: _statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              _isAvailable
                  ? Icons.check_circle_outline_rounded
                  : Icons.remove_circle_outline_rounded,
              color: _statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CURRENT STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusTitle,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _statusSubtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A7A9A),
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

  Widget _buildAvailabilityControlCard() {
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
          const Text(
            'BOOKING SWITCH',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F9FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Available for Jobs',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E3A5F),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _isAvailable
                            ? 'Customers can send new booking requests.'
                            : 'New job requests are paused for now.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5A7A9A),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Switch.adaptive(
                  value: _isAvailable,
                  onChanged: _saving ? null : _toggleAvailability,
                  activeColor: const Color(0xFF1FA971),
                ),
              ],
            ),
          ),
          if (_saving) ...[
            const SizedBox(height: 14),
            Row(
              children: const [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(width: 10),
                Text(
                  'Updating availability...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF5A7A9A),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
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
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'WHAT THIS DOES',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.visibility_outlined,
            title: 'Visible to customers',
            subtitle: 'Stay discoverable when you are ready to accept work.',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.pause_circle_outline_rounded,
            title: 'Pause requests anytime',
            subtitle: 'Turn availability off during breaks or busy hours.',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.sync_alt_rounded,
            title: 'Changes apply instantly',
            subtitle: 'Your dashboard and provider status stay in sync.',
          ),
        ],
      ),
    );
  }

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
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE24B4A),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFA32D2D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F2FB),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E3A5F),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF5A7A9A),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
