import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_button.dart';

class ProviderProfileScreen extends StatefulWidget {
  const ProviderProfileScreen({super.key});

  @override
  State<ProviderProfileScreen> createState() => _ProviderProfileScreenState();
}

class _ProviderProfileScreenState extends State<ProviderProfileScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  String? _selectedService = 'Deep Cleaning';
  String? _selectedTime = '11:30 AM';

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
  }

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
        title: Text(
          'Profile',
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: AppTheme.deepMidnight),
            onPressed: () {},
          )
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Profile Avatar
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        image: const DecorationImage(
                          image: NetworkImage(
                            'https://lh3.googleusercontent.com/aida-public/AB6AXuBLUbKjoYYyaUsbnL6ESj-Y8ppOgFCvHvJZmkUV_2pZU9ETa7jGn3w12VxIu9PUVuSRSBvO3IzUDeFqbyzQhwtmD_w2zTFMk0bEgzTrZFpxtjwrUlRT34eA2Lva5x6U4gJqSa2y_yMglyGR4i4yq31fvZOynSg1_Sel1Km7g9NqOStfauaOKpUEEHhexYBWcxrvauYqFDrhywVAoWLQo90SgRKDlrDsml3yFqtgHmBCo4EBlSmd4Uogcr7Mgaf4DA8J5uwv6gxREJNt',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF006A3D),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(Icons.verified, color: Colors.white, size: 16),
                    )
                  ],
                ),
                const SizedBox(height: 16),
                Text('Sarah Jenkins', style: Theme.of(context).textTheme.displayMedium),
                const SizedBox(height: 4),
                Text('Professional Home Cleaner', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.star, color: Color(0xFF006A3D), size: 18),
                      const SizedBox(width: 4),
                      Text('4.9', style: Theme.of(context).textTheme.labelLarge),
                      const SizedBox(width: 8),
                      Text('•', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.borderSubtle)),
                      const SizedBox(width: 8),
                      Text('142 jobs completed', style: Theme.of(context).textTheme.labelSmall),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat_bubble_outline, size: 20),
                        label: const Text('Message'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: AppTheme.borderSubtle),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.share_outlined, size: 20),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          side: BorderSide(color: AppTheme.borderSubtle),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // About
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('About', style: Theme.of(context).textTheme.displaySmall),
                ),
                const SizedBox(height: 8),
                Text(
                  "Hi, I'm Sarah! I have over 5 years of experience in residential cleaning. I pride myself on attention to detail and using eco-friendly products to keep your home safe and sparkling.",
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle, height: 1.5),
                ),
                const SizedBox(height: 32),
                // Services & Rates
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Services & Rates', style: Theme.of(context).textTheme.displaySmall),
                ),
                const SizedBox(height: 16),
                _buildServiceCard(context, 'House Cleaning', 'Standard maintenance', '\$45/hr', Icons.cleaning_services, _selectedService == 'House Cleaning'),
                const SizedBox(height: 12),
                _buildServiceCard(context, 'Deep Cleaning', 'Thorough interior wash', '\$65/hr', Icons.cleaning_services, _selectedService == 'Deep Cleaning'),
                
                const SizedBox(height: 32),
                // Availability
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Availability', style: Theme.of(context).textTheme.displaySmall),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.borderSubtle),
                  ),
                  child: Column(
                    children: [
                      TableCalendar(
                        firstDay: DateTime.now().subtract(const Duration(days: 365)),
                        lastDay: DateTime.now().add(const Duration(days: 365)),
                        focusedDay: _focusedDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          setState(() {
                            _selectedDay = selectedDay;
                            _focusedDay = focusedDay; 
                          });
                        },
                        calendarFormat: CalendarFormat.month,
                        availableCalendarFormats: const {
                          CalendarFormat.month: 'Month',
                        },
                        headerStyle: HeaderStyle(
                          formatButtonVisible: false,
                          titleCentered: true,
                          titleTextStyle: Theme.of(context).textTheme.labelLarge!,
                          leftChevronIcon: const Icon(Icons.chevron_left, color: AppTheme.deepMidnight),
                          rightChevronIcon: const Icon(Icons.chevron_right, color: AppTheme.deepMidnight),
                        ),
                        calendarStyle: CalendarStyle(
                          selectedDecoration: const BoxDecoration(
                            color: AppTheme.primaryBlue,
                            shape: BoxShape.circle,
                          ),
                          todayDecoration: BoxDecoration(
                            color: AppTheme.primaryBlue.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          defaultTextStyle: Theme.of(context).textTheme.bodyMedium!,
                          weekendTextStyle: Theme.of(context).textTheme.bodyMedium!,
                        ),
                        daysOfWeekStyle: DaysOfWeekStyle(
                          weekdayStyle: Theme.of(context).textTheme.labelSmall!,
                          weekendStyle: Theme.of(context).textTheme.labelSmall!,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _selectedDay != null 
                              ? 'Available slots for ${DateFormat('MMM d').format(_selectedDay!)}'
                              : 'Select a date', 
                          style: Theme.of(context).textTheme.labelSmall,
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (_selectedDay != null)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildTimeSlot(context, '09:00 AM', _selectedTime == '09:00 AM'),
                              const SizedBox(width: 8),
                              _buildTimeSlot(context, '11:30 AM', _selectedTime == '11:30 AM'),
                              const SizedBox(width: 8),
                              _buildTimeSlot(context, '02:00 PM', _selectedTime == '02:00 PM'),
                            ],
                          ),
                        )
                    ],
                  ),
                ),
                
                const SizedBox(height: 100), // Space for sticky CTA
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                border: Border(top: BorderSide(color: AppTheme.borderSubtle)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), offset: const Offset(0, -4), blurRadius: 10)
                ]
              ),
              child: SafeArea(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('Est. Total (2 hrs)', style: Theme.of(context).textTheme.labelSmall),
                        Text('\$130', style: Theme.of(context).textTheme.displayMedium),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/booking_confirmation');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        minimumSize: const Size(0, 48),
                      ),
                      child: const Text('Book Now', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceCard(BuildContext context, String title, String subtitle, String price, IconData icon, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedService = title),
      child: Container(
        padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle, width: isSelected ? 2 : 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isSelected ? AppTheme.primaryBlue.withOpacity(0.1) : AppTheme.background,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: isSelected ? AppTheme.primaryBlue : AppTheme.primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 2),
                Text(subtitle, style: Theme.of(context).textTheme.labelSmall),
              ],
            ),
          ),
          RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.displaySmall?.copyWith(color: AppTheme.primaryBlue),
              children: [
                TextSpan(text: price.split('/')[0]),
                TextSpan(
                  text: '/${price.split('/')[1]}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.textSubtle),
                ),
              ],
            ),
          ),
        ],
      ),
    ));
  }
  
  Widget _buildTimeSlot(BuildContext context, String time, bool isSelected) {
    return GestureDetector(
      onTap: () => setState(() => _selectedTime = time),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryBlue : AppTheme.background,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isSelected ? AppTheme.primaryBlue : AppTheme.borderSubtle),
      ),
      child: Text(
        time,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(color: isSelected ? Colors.white : AppTheme.deepMidnight),
      ),
    ));
  }
}
