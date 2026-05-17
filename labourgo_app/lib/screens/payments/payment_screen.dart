import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class PaymentScreen extends StatefulWidget {
  final int bookingId;
  final String amount;
  final String providerName;
  final String serviceName;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
    this.providerName = 'Provider',
    this.serviceName = 'Service',
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'easypaisa';
  bool _loading = false;
  bool _paid = false;
  String? _transactionId;
  bool _initializing = true;

  @override
  void initState() {
    super.initState();
    _checkPaymentStatus();
  }

  Future<void> _checkPaymentStatus() async {
    try {
      final payment = await ApiService.getPaymentByBooking(widget.bookingId);
      if (!mounted) return;

      // Check if payment exists and is already paid
      if (payment.isNotEmpty && payment['status'] == 'paid') {
        setState(() {
          _paid = true;
          _transactionId = payment['transaction_id'];
        });
      }
    } catch (e) {
      // Silently handle error - payment screen can still be used
    } finally {
      if (mounted) {
        setState(() => _initializing = false);
      }
    }
  }

  final List<Map<String, dynamic>> _methods = [
    {
      'id': 'easypaisa',
      'name': 'Easypaisa',
      'subtitle': 'Mobile wallet',
      'iconColor': const Color(0xFF5CE1E6),
    },
    {
      'id': 'jazzcash',
      'name': 'JazzCash',
      'subtitle': 'Mobile wallet',
      'iconColor': Colors.orange,
    },
    {
      'id': 'card',
      'name': 'Credit Card',
      'subtitle': 'Visa / Mastercard',
      'iconColor': const Color(0xFF4682B4),
    },
    {
      'id': 'cash',
      'name': 'Cash',
      'subtitle': 'Pay on delivery',
      'iconColor': Colors.green,
    },
  ];

  Future<void> _pay() async {
    setState(() => _loading = true);
    try {
      final result = await ApiService.makePayment(
        bookingId: widget.bookingId,
        amount: widget.amount,
        method: _selectedMethod,
      );
      if (!mounted) return;
      if (result.containsKey('transaction_id')) {
        setState(() {
          _paid = true;
          _transactionId = result['transaction_id'];
        });
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.toString())));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Try again.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Payment',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF4682B4),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 14,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: _initializing
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(20),
                child: _paid ? _successView() : _paymentForm(),
              ),
      ),
    );
  }

  Widget _paymentForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount card
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          decoration: BoxDecoration(
            color: const Color(0xFF4682B4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Text(
                'Total Amount',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Text(
                'PKR ${widget.amount}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${widget.serviceName} Service · ${widget.providerName}',
                style: const TextStyle(color: Color(0xFF5CE1E6), fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 24),
        const Text(
          'Choose Payment Method',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 16),

        // Payment methods
        Expanded(
          child: ListView(
            children: _methods
                .map(
                  (method) => GestureDetector(
                    onTap: () => setState(() => _selectedMethod = method['id']),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _selectedMethod == method['id']
                              ? const Color(0xFF4682B4)
                              : Colors.grey.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: (method['iconColor'] as Color).withValues(
                                alpha: 0.1,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: method['iconColor'],
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                method['name'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                method['subtitle'],
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: _selectedMethod == method['id']
                                    ? const Color(0xFF4682B4)
                                    : Colors.grey.withValues(alpha: 0.3),
                                width: _selectedMethod == method['id']
                                    ? 6
                                    : 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _loading ? null : _pay,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4682B4),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _loading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : Text(
                    'Pay PKR ${widget.amount}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }

  Widget _successView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 80),
          const SizedBox(height: 16),
          const Text(
            'Payment Successful!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Transaction ID: $_transactionId',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4682B4),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Back to Bookings'),
            ),
          ),
        ],
      ),
    );
  }
}
