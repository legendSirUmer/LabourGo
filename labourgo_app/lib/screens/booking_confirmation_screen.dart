import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class BookingConfirmationScreen extends StatelessWidget {
  const BookingConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.deepMidnight),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Track Provider', style: Theme.of(context).textTheme.displaySmall),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppTheme.deepMidnight),
            onPressed: () {},
          )
        ],
      ),
      body: Column(
        children: [
          // Map Section
          SizedBox(
            height: 350,
            width: double.infinity,
            child: Stack(
              children: [
                Image.network(
                  'https://lh3.googleusercontent.com/aida-public/AB6AXuBpsMxRSxSl0ITIqF7i2bltzZZRW-fbdw_0imdCrUxzyBYT9paTpVyz7wEZ55meZAlLTr3HpQ5U_meB9V3YxxwwPEEP3SrFtOt0F6a6fx7y4gcZyppLd9yYWRomm_SCI9lkDv79_OH18IUKuiSY5j-VyoYHSbWLh8dduoRl-_0CPj58ehPnjZ4mSnz1YFCZ274TCbcuHc45gSFWcTmrLYtwRv9kVsQoVN5NixmxGY4I7gBNIekxaYgx6bFr7tepXr2I0G7s7oEfakBb',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
                Positioned(
                  bottom: 16,
                  left: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.primaryBlue.withOpacity(0.1), shape: BoxShape.circle),
                          child: const Icon(Icons.directions_car, color: AppTheme.primaryBlue),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Arriving in 12 mins', style: Theme.of(context).textTheme.displaySmall),
                              const SizedBox(height: 4),
                              Text('Provider is on the way to your location', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Provider Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.borderSubtle),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 28,
                              backgroundImage: const NetworkImage('https://lh3.googleusercontent.com/aida-public/AB6AXuAbxRkkr_eKvq4V6Q0hF2tZYdk5LDXABMmBFKEpMX2MpZOyXPoX8zZXjaOTDXy2uFKnxVpoq_odnUh2d5Mzch3YDB2Yj0rlno5yHubZwjYDX7tJcmirF7E5ctnwZ6GoFfIudh9coURc0yWeuQe-boa7q4GavSzkfZ8xOnafN05_tm_b8yvOzV58mtwaAtNgpNivtdljYNGqpz6EAP_6BCCbUXax8PXn69pUmLdQHi1DlTbqoXEtJ-Fv4vevmAi5cVkhRrCu23UFne9r'),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Marcus Johnson', style: Theme.of(context).textTheme.displaySmall),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(Icons.star, color: AppTheme.primaryBlue, size: 16),
                                      const SizedBox(width: 4),
                                      Text('4.9 (120 jobs) • Master Plumber', style: Theme.of(context).textTheme.labelSmall),
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.call, color: AppTheme.deepMidnight, size: 20),
                                label: Text('Call', style: Theme.of(context).textTheme.labelLarge),
                              ),
                            ),
                            Container(width: 1, height: 24, color: AppTheme.borderSubtle),
                            Expanded(
                              child: TextButton.icon(
                                onPressed: () {},
                                icon: const Icon(Icons.chat_bubble_outline, color: AppTheme.deepMidnight, size: 20),
                                label: Text('Message', style: Theme.of(context).textTheme.labelLarge),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Booking Summary Card
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
                        Text('Booking Details', style: Theme.of(context).textTheme.labelLarge),
                        const SizedBox(height: 16),
                        _buildDetailRow(context, Icons.plumbing, 'Pipe Leak Repair', 'Standard Service'),
                        const SizedBox(height: 12),
                        _buildDetailRow(context, Icons.schedule, 'Today, Oct 24', 'Estimated arrival: 2:30 PM - 3:00 PM'),
                        const SizedBox(height: 12),
                        _buildDetailRow(context, Icons.location_on_outlined, '1240 Broad St, Unit 4B', 'Seattle, WA 98101'),
                        const SizedBox(height: 16),
                        const Divider(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Estimated Total', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle)),
                            Text('\$120.00', style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.primaryBlue)),
                          ],
                        ),
                        const SizedBox(height: 16),
                        CustomButton(
                          text: 'Proceed to Payment',
                          onPressed: () {
                            Navigator.of(context).pushNamed('/payment');
                          },
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, IconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.textSubtle, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: 2),
              Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
            ],
          ),
        ),
      ],
    );
  }
}
