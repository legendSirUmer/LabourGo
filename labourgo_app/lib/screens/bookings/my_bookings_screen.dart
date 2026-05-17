import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../payments/payment_screen.dart';
import '../reviews/review_screen.dart';

class MyBookingsScreen extends StatefulWidget {
  final bool embedded;
  final int refreshToken;
  const MyBookingsScreen({
    super.key,
    this.embedded = false,
    this.refreshToken = 0,
  });

  @override
  State<MyBookingsScreen> createState() => _MyBookingsScreenState();
}

class _MyBookingsScreenState extends State<MyBookingsScreen> {
  List<dynamic> _bookings = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBookings();
  }

  @override
  void didUpdateWidget(covariant MyBookingsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _loadBookings();
    }
  }

  Future<void> _loadBookings() async {
    if (mounted) {
      setState(() {
        if (_bookings.isEmpty) _loading = true;
        _error = null;
      });
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final bookings = await ApiService.getMyBookings();
      final isProvider = prefs.getBool('is_provider_signed_in') ?? false;
      final providerId = prefs.getInt('provider_id');
      final userEmail = prefs.getString('user_email') ?? '';
      final userPhone = prefs.getString('user_phone') ?? '';
      final visibleBookings = isProvider
          ? bookings
                .where(
                  (booking) => !_isOwnProviderBooking(
                    booking,
                    providerId,
                    userEmail,
                    userPhone,
                  ),
                )
                .toList(growable: false)
          : bookings;
      if (!mounted) return;
      setState(() {
        _bookings = visibleBookings;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load bookings. Pull to refresh.';
      });
    }
  }

  bool _isOwnProviderBooking(
    dynamic booking,
    int? providerId,
    String userEmail,
    String userPhone,
  ) {
    if (booking is! Map) return false;

    final provider = booking['provider'];
    if (provider is! Map) return false;

    final bookingProviderId = int.tryParse(provider['id']?.toString() ?? '');
    if (providerId != null && bookingProviderId == providerId) {
      return true;
    }

    final normalizedUserEmail = userEmail.trim().toLowerCase();
    final normalizedProviderEmail = (provider['email'] ?? '')
        .toString()
        .trim()
        .toLowerCase();
    if (normalizedUserEmail.isNotEmpty &&
        normalizedProviderEmail == normalizedUserEmail) {
      return true;
    }

    final normalizedUserPhone = userPhone.replaceAll(RegExp(r'[^0-9]'), '');
    final normalizedProviderPhone = (provider['phone'] ?? '')
        .toString()
        .replaceAll(RegExp(r'[^0-9]'), '');
    return normalizedUserPhone.isNotEmpty &&
        normalizedProviderPhone == normalizedUserPhone;
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':     return Colors.orange;
      case 'accepted':    return Colors.blue;
      case 'in_progress': return Colors.purple;
      case 'completed':   return Colors.green;
      case 'cancelled':   return Colors.red;
      default:            return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: widget.embedded ? null : AppBar(
        title: const Text('My Bookings'),
        backgroundColor: const Color(0xFF4682B4),
        foregroundColor: Colors.white,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadBookings,
              child: _bookings.isEmpty
                  ? ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.18,
                        ),
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _error == null
                                    ? Icons.calendar_today
                                    : Icons.wifi_off_rounded,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                _error ?? 'No bookings yet',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: _bookings.length,
                      itemBuilder: (context, index) {
                        final b = _bookings[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header row
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      b['category']?['name'] ?? 'Service',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: _statusColor(b['status'])
                                            .withValues(alpha: 0.1),
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        b['status'].toString().toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(b['status']),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // Provider
                                Row(
                                  children: [
                                    const Icon(Icons.person_outline,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      b['provider']?['full_name'] ??
                                          'Provider',
                                      style: const TextStyle(
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Date
                                Row(
                                  children: [
                                    const Icon(Icons.calendar_today,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${b['scheduled_date']} at ${b['scheduled_time']}',
                                      style: const TextStyle(
                                          color: Colors.grey),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                // Location
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_outlined,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        b['location_address'] ?? '',
                                        style: const TextStyle(
                                            color: Colors.grey),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                // ── In Progress: Customer confirms completion ──
                                if (b['status'] == 'in_progress') ...[
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 44,
                                    child: ElevatedButton.icon(
                                      onPressed: () async {
                                        final confirm =
                                            await showDialog<bool>(
                                          context: context,
                                          builder: (_) => AlertDialog(
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(16),
                                            ),
                                            title: const Text(
                                                'Confirm Completion'),
                                            content: const Text(
                                              'Are you sure the job has been completed?',
                                            ),
                                            actions: [
                                              TextButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, false),
                                                child: const Text('Cancel'),
                                              ),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    Navigator.pop(
                                                        context, true),
                                                style:
                                                    ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      const Color(0xFF4682B4),
                                                ),
                                                child: const Text(
                                                  'Yes, Completed',
                                                  style: TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            ],
                                          ),
                                        );

                                        if (confirm == true) {
                                          try {
                                            await ApiService
                                                .updateBookingStatus(
                                              b['id'],
                                              'completed',
                                            );
                                            _loadBookings();
                                          } catch (e) {
                                            if (!mounted) return;
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content:
                                                    Text('Failed: $e'),
                                              ),
                                            );
                                          }
                                        }
                                      },
                                      icon: const Icon(
                                          Icons.done_all_rounded,
                                          size: 16),
                                      label: const Text('Job Completed'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor:
                                            const Color(0xFF4682B4),
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],

                                // ── Completed: Pay + Review ──
                                if (b['status'] == 'completed') ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => PaymentScreen(
                                                bookingId: b['id'],
                                                amount: b['price_offered']
                                                        ?.toString() ??
                                                    '0',
                                                providerName:
                                                    b['provider']?[
                                                            'full_name'] ??
                                                        'Provider',
                                                serviceName:
                                                    b['category']?['name'] ??
                                                        'Service',
                                              ),
                                            ),
                                          ),
                                          icon: const Icon(Icons.payment,
                                              size: 16),
                                          label: const Text('Pay'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                const Color(0xFF4682B4),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) => ReviewScreen(
                                                bookingId: b['id'],
                                              ),
                                            ),
                                          ),
                                          icon: const Icon(Icons.star,
                                              size: 16),
                                          label: const Text('Review'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF4682B4),
                                            foregroundColor: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }
}
