import 'package:flutter/material.dart';

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

class BookingCheckingScreen extends StatefulWidget {
  const BookingCheckingScreen({super.key});

  @override
  State<BookingCheckingScreen> createState() => _BookingCheckingScreenState();
}

class _BookingCheckingScreenState extends State<BookingCheckingScreen>
    with SingleTickerProviderStateMixin {
  bool _loading = true;
  String? _error;
  final List<Map<String, dynamic>> _bookings = [];

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
    _loadBookings();
  }

  @override
  void dispose() {
    _fadeCtrl?.dispose();
    super.dispose();
  }

  Future<void> _loadBookings() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await ApiService.getMyBookings();
      if (!mounted) return;
      setState(() {
        _bookings
          ..clear()
          ..addAll(data);
      });
      _fadeCtrl?.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load bookings');
      _fadeCtrl?.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

 Future<void> _acceptBooking(int bookingId) async {
    try {
      await ApiService.updateBookingStatus(bookingId, 'accepted');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Booking accepted!'),
          backgroundColor: Color(0xFF1FA971),
        ),
      );
      _loadBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to accept: $e')),
      );
    }
  }

  // ADD THIS RIGHT AFTER ↑
  Future<void> _updateStatus(int bookingId, String newStatus) async {
    try {
      await ApiService.updateBookingStatus(bookingId, newStatus);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Status updated to $newStatus!'),
          backgroundColor: const Color(0xFF1FA971),
        ),
      );
      _loadBookings();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return const Color(0xFF1FA971);
      case 'in_progress':
        return const Color(0xFF2AB0BC);
      case 'completed':
        return const Color(0xFF4682B4);
      case 'cancelled':
        return const Color(0xFFE24B4A);
      default:
        return const Color(0xFFFFAA00);
    }
  }

  String _formatStatus(String status) {
    final words = status.split('_');
    return words
        .map((word) => word.isEmpty
            ? word
            : '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading ? _buildLoader() : _buildContent(),
      bottomNavigationBar: ProviderBottomNavigation(
        currentIndex: 2,
        onTap: (index) {
          if (index == 2) return;
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/provider_dashboard');
              break;
            case 1:
              Navigator.pushReplacementNamed(context, '/profile');
              break;
            case 3:
              Navigator.pushReplacementNamed(context, '/home');
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
            'Loading bookings...',
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
                  _buildSummaryCard(),
                  const SizedBox(height: 20),
                  _buildBookingsSection(),
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
                        'Bookings',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _HeaderBtn(
                        icon: Icons.refresh_rounded,
                        onTap: _loadBookings,
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
                      Icons.book_online_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Customer Bookings',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Review job requests with customer name, phone, and address',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.list_alt_rounded,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${_bookings.length} booking${_bookings.length == 1 ? '' : 's'}',
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

  Widget _buildSummaryCard() {
    final pendingCount = _bookings
        .where((item) =>
            (item['status'] ?? '').toString().toLowerCase() == 'pending')
        .length;

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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FB),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.people_alt_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'BOOKING OVERVIEW',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$pendingCount pending request${pendingCount == 1 ? '' : 's'}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Open each booking to review customer details and job location.',
                  style: TextStyle(
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

  Widget _buildBookingsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'ALL BOOKINGS',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.08,
              ),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_bookings.length} total',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_bookings.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(
            _bookings.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildBookingCard(_bookings[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(
              Icons.book_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No bookings yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Customer booking requests will appear here',
            style: TextStyle(fontSize: 12, color: Color(0xFF8FA8C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingCard(Map<String, dynamic> booking) {
    final customer = booking['customer'] as Map<String, dynamic>?;
    final customerName = (customer?['full_name'] ?? 'Customer').toString();
    final customerPhone = (customer?['phone'] ?? 'N/A').toString();
    final address =
        (booking['location_address'] ?? 'Address not available').toString();
    final status = (booking['status'] ?? 'pending').toString();
    final category = booking['category'] as Map<String, dynamic>?;
    final serviceName = (category?['name'] ?? 'Service').toString();
    final scheduledDate = (booking['scheduled_date'] ?? '').toString();
    final scheduledTime = (booking['scheduled_time'] ?? '').toString();
    final price = booking['price_offered']?.toString();
    final bookingId = booking['id'];
    final statusColor = _statusColor(status);
    final isPending = status.toLowerCase() == 'pending';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // ── Status bar ──
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  _formatStatus(status).toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (price != null && price.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'PKR $price',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Card body ──
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Customer row
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            customerName,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1E3A5F),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            serviceName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.primary.withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFEEF3F8)),
                const SizedBox(height: 14),

                // Details
                _BookingDetailRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: customerPhone,
                ),
                const SizedBox(height: 8),
                _BookingDetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Address',
                  value: address,
                ),
                if (scheduledDate.isNotEmpty ||
                    scheduledTime.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  _BookingDetailRow(
                    icon: Icons.schedule_outlined,
                    label: 'Schedule',
                    value:
                        '$scheduledDate${scheduledTime.isNotEmpty ? ' at $scheduledTime' : ''}'
                            .trim(),
                  ),
                ],

               // ── Accept button ──
                if (isPending && bookingId != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _acceptBooking(
                        bookingId is int
                            ? bookingId
                            : int.tryParse(bookingId.toString()) ?? 0,
                      ),
                      icon: const Icon(Icons.check_circle_rounded, size: 18),
                      label: const Text(
                        'Accept Request',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1FA971),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── Start Job button ──
                if (status.toLowerCase() == 'accepted' && bookingId != null) ...[
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton.icon(
                      onPressed: () => _updateStatus(
                        bookingId is int
                            ? bookingId
                            : int.tryParse(bookingId.toString()) ?? 0,
                        'in_progress',
                      ),
                      icon: const Icon(Icons.play_circle_rounded, size: 18),
                      label: const Text(
                        'Start Job',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2AB0BC),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],

                // ── In Progress label ──
                if (status.toLowerCase() == 'in_progress') ...[
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2AB0BC).withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF2AB0BC).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.hourglass_top_rounded,
                            size: 16, color: Color(0xFF2AB0BC)),
                        SizedBox(width: 8),
                        Text(
                          'Waiting for customer to confirm completion',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2AB0BC),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
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
        border: Border.all(
            color: const Color(0xFFF09595), width: 0.5),
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

class _BookingDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _BookingDetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF7A9BB8), size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E3A5F),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF5A7A9A),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}