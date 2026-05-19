import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

class CreateBookingScreen extends StatefulWidget {
  final Map<String, dynamic> category;
  final int? initialProviderId;
  final int? excludedProviderId;

  const CreateBookingScreen({
    super.key,
    required this.category,
    this.initialProviderId,
    this.excludedProviderId,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();

  List<dynamic> _providers = [];
  int? _selectedProvider;
  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _selectedTime = const TimeOfDay(hour: 10, minute: 0);
  bool _loading = false;
  bool _loadingProviders = true;

  @override
  void initState() {
    super.initState();
    _selectedProvider = widget.initialProviderId;
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentProviderId =
          widget.excludedProviderId ?? prefs.getInt('provider_id');
      final userEmail = prefs.getString('user_email') ?? '';
      final userPhone = prefs.getString('user_phone') ?? '';
      final providers = await ApiService.fetchProviders();
      final filteredProviders = providers
          .where((provider) {
            return !_isCurrentProvider(
              provider,
              currentProviderId,
              userEmail,
              userPhone,
            );
          })
          .where(_matchesSelectedCategory)
          .toList(growable: false);
      final selectedStillAvailable = filteredProviders.any((provider) {
        final providerId = int.tryParse(provider['id']?.toString() ?? '');
        return providerId == _selectedProvider;
      });
      setState(() {
        _providers = filteredProviders;
        if (!selectedStillAvailable) _selectedProvider = null;
        _loadingProviders = false;
      });
    } catch (e) {
      setState(() => _loadingProviders = false);
    }
  }

  bool _matchesSelectedCategory(dynamic provider) {
    if (provider is! Map) return false;
    final selectedCategory =
        widget.category['name']?.toString().trim().toLowerCase() ?? '';
    if (selectedCategory.isEmpty) return true;

    final skills = _providerSkills(
      provider,
    ).map((skill) => skill.toLowerCase()).toList(growable: false);
    final serviceValue = (provider['service'] ?? provider['service_name'] ?? '')
        .toString()
        .toLowerCase();
    final categoryValue =
        (provider['category_name'] ?? provider['category'] ?? '')
            .toString()
            .toLowerCase();

    final providerId = int.tryParse(provider['id']?.toString() ?? '');
    if (_selectedProvider != null && providerId == _selectedProvider) {
      return true;
    }

    final hasCategoryMetadata =
        skills.isNotEmpty ||
        serviceValue.isNotEmpty ||
        categoryValue.isNotEmpty;

    if (!hasCategoryMetadata) {
      return false;
    }

    if (skills.any((skill) {
      return skill == selectedCategory ||
          skill.contains(selectedCategory) ||
          selectedCategory.contains(skill);
    })) {
      return true;
    }

    if (serviceValue.isNotEmpty && serviceValue.contains(selectedCategory)) {
      return true;
    }

    if (categoryValue.isNotEmpty && categoryValue.contains(selectedCategory)) {
      return true;
    }

    return false;
  }

  bool _isCurrentProvider(
    dynamic provider,
    int? currentProviderId,
    String userEmail,
    String userPhone,
  ) {
    if (provider is! Map) return false;

    final providerId = int.tryParse(provider['id']?.toString() ?? '');
    if (currentProviderId != null && providerId == currentProviderId) {
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

  List<String> _providerSkills(dynamic provider) {
    if (provider is! Map) return [];
    final skillsValue = provider['skills'];
    if (skillsValue == null) return [];

    if (skillsValue is String) {
      return skillsValue
          .split(RegExp(r'[,;/\n]+'))
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }

    if (skillsValue is Iterable) {
      return skillsValue
          .map((value) => value?.toString().trim() ?? '')
          .where((value) => value.isNotEmpty)
          .toList(growable: false);
    }

    return [skillsValue.toString().trim()];
  }

  String _providerName(dynamic provider) {
    if (provider is Map) {
      final name =
          (provider['full_name'] ??
                  provider['name'] ??
                  provider['fullName'] ??
                  '')
              .toString()
              .trim();
      if (name.isNotEmpty) return name;
    }
    return 'Provider';
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (date != null) setState(() => _selectedDate = date);
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) setState(() => _selectedTime = time);
  }

  Future<void> _createBooking() async {
    if (_selectedProvider == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a provider')));
      return;
    }
    if (_descCtrl.text.isEmpty || _locationCtrl.text.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await ApiService.createBooking(
        providerId: _selectedProvider!,
        categoryId: widget.category['id'],
        description: _descCtrl.text.trim(),
        locationAddress: _locationCtrl.text.trim(),
        scheduledDate:
            '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}',
        scheduledTime:
            '${_selectedTime.hour.toString().padLeft(2, '0')}:${_selectedTime.minute.toString().padLeft(2, '0')}:00',
        priceOffered: _priceCtrl.text.isEmpty ? '0' : _priceCtrl.text.trim(),
      );

      if (result.containsKey('booking')) {
        if (!mounted) return;
        await showDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (_) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 8),
                Text('Booking Created!'),
              ],
            ),
            content: const Text(
              'Your booking is submitted successfully.\nStatus: Pending',
            ),
            actions: [
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  foregroundColor: Colors.white,
                ),
                child: const Text('View My Bookings'),
              ),
            ],
          ),
        );

        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.toString())));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to create booking.')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book ${widget.category['name']}'),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
      ),
      body: _loadingProviders
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1976D2).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF1976D2).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.handyman, color: Color(0xFF1976D2)),
                        const SizedBox(width: 8),
                        Hero(
                          tag: 'category-${widget.category['name']}',
                          child: Text(
                            widget.category['name'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1976D2),
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Select Provider
                  _sectionTitle('Select Provider'),
                  _providers.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.orange[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'No providers available yet.',
                            style: TextStyle(color: Colors.orange),
                          ),
                        )
                      : Column(
                          children: _providers.map((provider) {
                            final isSelected =
                                _selectedProvider == provider['id'];
                            final displayName = _providerName(provider);
                            return GestureDetector(
                              onTap: () => setState(
                                () => _selectedProvider = provider['id'],
                              ),
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? const Color(
                                          0xFF1976D2,
                                        ).withValues(alpha: 0.1)
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? const Color(0xFF1976D2)
                                        : Colors.grey[300]!,
                                    width: isSelected ? 2 : 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Hero(
                                      tag: 'provider-avatar-${provider['id']}',
                                      child: CircleAvatar(
                                        backgroundColor: const Color(
                                          0xFF1976D2,
                                        ).withValues(alpha: 0.2),
                                        child: Text(
                                          displayName.isNotEmpty
                                              ? displayName[0].toUpperCase()
                                              : 'P',
                                          style: const TextStyle(
                                            color: Color(0xFF1976D2),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag:
                                              'provider-name-${provider['id']}',
                                          child: Text(
                                            displayName,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        Text(
                                          provider['phone'] ?? '',
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const Spacer(),
                                    if (isSelected)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Color(0xFF1976D2),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                  const SizedBox(height: 16),

                  // Description
                  _sectionTitle('Describe Your Problem'),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'e.g. My kitchen sink is leaking...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Location
                  _sectionTitle('Your Address'),
                  TextField(
                    controller: _locationCtrl,
                    decoration: InputDecoration(
                      hintText: 'House #, Street, Area, City',
                      prefixIcon: const Icon(Icons.location_on_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Date & Time
                  _sectionTitle('Schedule'),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickDate,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.calendar_today,
                                  color: Color(0xFF1976D2),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: _pickTime,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.access_time,
                                  color: Color(0xFF1976D2),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _selectedTime.format(context),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Price
                  _sectionTitle('Your Budget (PKR)'),
                  TextField(
                    controller: _priceCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'e.g. 1500',
                      prefixIcon: const Icon(Icons.attach_money),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Submit button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _createBooking,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1976D2),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Confirm Booking',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _sectionTitle(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
    ),
  );
}
