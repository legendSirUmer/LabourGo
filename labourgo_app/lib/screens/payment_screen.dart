import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool _isOnlineSelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.deepMidnight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('LabourGo', style: Theme.of(context).textTheme.displaySmall),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text('Checkout', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                Text('Review your summary and complete payment.', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle)),
                const SizedBox(height: 24),
                
                // Order Summary
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Order Summary', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(height: 12),
                      _buildSummaryRow(context, 'Plumbing Service (2 hrs)', '\$80.00'),
                      const SizedBox(height: 8),
                      _buildSummaryRow(context, 'Service Fee', '\$5.00'),
                      const SizedBox(height: 8),
                      _buildSummaryRow(context, 'Tax', '\$2.50'),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Total', style: Theme.of(context).textTheme.labelLarge),
                          Text('\$87.50', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.primaryBlue)),
                        ],
                      )
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                Text('Payment Method', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                
                // Toggle Grid
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isOnlineSelected = true),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _isOnlineSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _isOnlineSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle, width: _isOnlineSelected ? 2 : 1),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.credit_card, color: _isOnlineSelected ? AppTheme.primaryBlue : AppTheme.textSubtle),
                              const SizedBox(height: 8),
                              Text('Online', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: _isOnlineSelected ? AppTheme.primaryBlue : AppTheme.textSubtle)),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => setState(() => _isOnlineSelected = false),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: !_isOnlineSelected ? AppTheme.primaryBlue.withOpacity(0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: !_isOnlineSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle, width: !_isOnlineSelected ? 2 : 1),
                          ),
                          child: Column(
                            children: [
                              Icon(Icons.payments_outlined, color: !_isOnlineSelected ? AppTheme.primaryBlue : AppTheme.textSubtle),
                              const SizedBox(height: 8),
                              Text('Cash', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: !_isOnlineSelected ? AppTheme.primaryBlue : AppTheme.textSubtle)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                
                if (_isOnlineSelected) ...[
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        _buildPaymentOption(context, true, '•••• 4242', 'Expires 12/25', isVisa: true),
                        const Divider(height: 1),
                        _buildPaymentOption(context, false, 'Add New Card', '', icon: Icons.add_circle_outline),
                        const Divider(height: 1),
                        _buildPaymentOption(context, false, 'Digital Wallet (Apple Pay)', '', icon: Icons.account_balance_wallet_outlined),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock_outline, size: 16, color: AppTheme.textSubtle),
                      const SizedBox(width: 8),
                      Text('Payments are secure and encrypted', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  )
                ],
                const SizedBox(height: 100), // Space for sticky CTA
              ],
            ),
          ),
          
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, -4))
                ]
              ),
              child: SafeArea(
                child: CustomButton(
                  text: 'Confirm Payment • \$87.50',
                  onPressed: () {
                    // Handle payment confirmation
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Success'),
                        content: const Text('Payment successful!'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(ctx).popUntil((route) => route.isFirst), child: const Text('OK'))
                        ],
                      )
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(BuildContext context, String title, String amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle)),
        Text(amount, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildPaymentOption(BuildContext context, bool isSelected, String title, String subtitle, {IconData? icon, bool isVisa = false}) {
    return ListTile(
      leading: Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle, width: 2),
        ),
        child: isSelected ? Center(child: Container(width: 10, height: 10, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.primaryBlue))) : null,
      ),
      title: Row(
        children: [
          if (isVisa)
            Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(border: Border.all(color: AppTheme.borderSubtle), borderRadius: BorderRadius.circular(4)),
              child: const Text('VISA', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
            ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(icon, color: AppTheme.textSubtle),
            ),
          Text(title, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
      subtitle: subtitle.isNotEmpty ? Text(subtitle, style: Theme.of(context).textTheme.labelSmall) : null,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: isSelected ? AppTheme.background : Colors.transparent,
    );
  }
}
