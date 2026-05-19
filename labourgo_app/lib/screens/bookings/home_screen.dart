import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:shimmer/shimmer.dart';
import 'package:confetti/confetti.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../theme/cust_theme.dart';
import '../auth/login_screen.dart';
import '../profile/edit_profile_screen.dart';
import '../provider_screens/P_onboarding/provider_intro_screen.dart';
import 'my_bookings_screen.dart';
import 'create_booking_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _providers = [];
  List<dynamic> _payments = [];
  Map<String, dynamic>? _profile;
  bool _loading = true;
  bool _paymentsLoading = true;
  String? _paymentsError;
  String _userName = '';
  String _searchQuery = '';
  String _selectedCity = '';
  String _selectedService = '';
  double? _maxFee;
  int? _currentProviderId;
  int _navIndex = 0;
  int _bookingsRefreshToken = 0;
  final TextEditingController _searchCtrl = TextEditingController();
  late final PageController _pageController;
  late ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _pageController = PageController(initialPage: _navIndex);
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final results = await Future.wait([
        ApiService.getCategories(),
        ApiService.fetchProviders(),
        ApiService.getProfile(),
        ApiService.getMyPayments(),
      ]);
      final profile = Map<String, dynamic>.from(results[2] as Map);
      final userEmail =
          (profile['email'] ?? prefs.getString('user_email') ?? '').toString();
      final userPhone =
          (profile['phone'] ?? prefs.getString('user_phone') ?? '').toString();
      final currentProviderId = prefs.getInt('provider_id');
      final providers = (results[1] as List)
          .where(
            (provider) => !_isCurrentProvider(
              provider,
              currentProviderId,
              userEmail,
              userPhone,
            ),
          )
          .toList(growable: false);

      setState(() {
        _categories = results[0] as List;
        _providers = providers;
        _profile = profile;
        _userName = profile['full_name'] ?? 'User';
        _currentProviderId = currentProviderId;
        _payments = results[3] as List;
        _loading = false;
        _paymentsLoading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _paymentsLoading = false;
        _paymentsError = 'Could not load payments. Pull to refresh.';
      });
    }
  }

  List<dynamic> get _visibleCategories {
    final query = _searchQuery.trim().toLowerCase();
    return _categories
        .where((category) {
          final name = (category['name'] ?? '').toString().toLowerCase();
          final matchesSearch = query.isEmpty || name.contains(query);
          final matchesService =
              _selectedService.isEmpty ||
              name == _selectedService.toLowerCase();
          return matchesSearch && matchesService;
        })
        .toList(growable: false);
  }

  List<dynamic> get _visibleProviders {
    final query = _searchQuery.trim().toLowerCase();
    return _providers
        .where((provider) {
          if (provider is! Map) return false;

          final searchable = [
            _providerName(provider),
            _providerCity(provider),
            _providerServiceText(provider),
            (provider['phone'] ?? '').toString(),
          ].join(' ').toLowerCase();

          final matchesSearch = query.isEmpty || searchable.contains(query);
          final city = _providerCity(provider).toLowerCase();
          final matchesCity =
              _selectedCity.isEmpty || city == _selectedCity.toLowerCase();
          final service = _providerServiceText(provider).toLowerCase();
          final matchesService =
              _selectedService.isEmpty ||
              service.contains(_selectedService.toLowerCase());
          final fee = _providerFee(provider);
          final matchesFee = _maxFee == null || fee == null || fee <= _maxFee!;

          return matchesSearch && matchesCity && matchesService && matchesFee;
        })
        .toList(growable: false);
  }

  List<String> get _availableCities {
    final cities = _providers
        .whereType<Map>()
        .map(_providerCity)
        .where((city) => city.trim().isNotEmpty)
        .toSet()
        .toList();
    cities.sort();
    return cities;
  }

  String _providerName(Map provider) {
    return (provider['name'] ?? provider['full_name'] ?? 'Provider').toString();
  }

  String _providerCity(Map provider) {
    return (provider['city'] ??
            provider['location_city'] ??
            provider['area'] ??
            provider['location'] ??
            '')
        .toString()
        .trim();
  }

  List<String> _providerSkills(Map provider) {
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

  String _providerPrimaryService(Map provider) {
    final skills = _providerSkills(provider);
    if (skills.isNotEmpty) return skills.first;

    final service = provider['service'] ?? provider['service_name'];
    if (service is String && service.trim().isNotEmpty) return service.trim();

    final categoryName = provider['category_name'] ?? provider['category'];
    if (categoryName is String && categoryName.trim().isNotEmpty) {
      return categoryName.trim();
    }

    return 'Service Provider';
  }

  String _providerServiceText(Map provider) {
    final values = [
      _providerSkills(provider),
      provider['service'],
      provider['service_name'],
      provider['category'],
      provider['category_name'],
      provider['role'],
      provider['service_id'],
      provider['category_id'],
    ];
    return values
        .where((value) => value != null)
        .map(_formatProviderValue)
        .where((value) => value.isNotEmpty)
        .join(' ');
  }

  String _formatProviderValue(Object? value) {
    if (value == null) return '';
    if (value is String) return value.trim();
    if (value is num) return value.toString();
    if (value is Iterable) {
      return value
          .map(_formatProviderValue)
          .where((text) => text.isNotEmpty)
          .join(' ');
    }
    if (value is Map) {
      final parts = value.values
          .map(_formatProviderValue)
          .where((text) => text.isNotEmpty)
          .toSet()
          .toList();
      return parts.join(' ');
    }
    return value.toString().trim();
  }

  double? _providerFee(Map provider) {
    final raw =
        provider['price_per_hour'] ??
        provider['price'] ??
        provider['hourly_rate'] ??
        provider['fee'];
    if (raw is num) return raw.toDouble();
    return double.tryParse(raw?.toString() ?? '');
  }

  Future<void> _openBookingForCategory(Map<String, dynamic> category) async {
    final created = await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => CreateBookingScreen(
          category: category,
          excludedProviderId: _currentProviderId,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
      ),
    );
    if (!mounted) return;
    if (created == true) {
      setState(() {
        _navIndex = 1;
        _bookingsRefreshToken++;
      });
    }
  }

  Map<String, dynamic>? _findCategoryForProvider(Map provider) {
    final categoryField = provider['category'];
    if (categoryField != null) {
      final normalizedValue = _formatProviderValue(categoryField).toLowerCase();
      if (normalizedValue.isNotEmpty) {
        for (final category in _categories) {
          final categoryName = (category['name'] ?? '')
              .toString()
              .toLowerCase();
          final categoryId =
              (category['id'] ?? category['category_id'])
                  ?.toString()
                  .toLowerCase() ??
              '';
          if (normalizedValue == categoryName ||
              normalizedValue == categoryId ||
              categoryName.contains(normalizedValue) ||
              normalizedValue.contains(categoryName)) {
            return category as Map<String, dynamic>;
          }
        }
      }
    }

    final skills = _providerSkills(
      provider,
    ).map((skill) => skill.toLowerCase()).toList(growable: false);
    if (skills.isNotEmpty) {
      for (final category in _categories) {
        final categoryName = (category['name'] ?? '').toString().toLowerCase();
        if (categoryName.isNotEmpty) {
          for (final skill in skills) {
            if (skill == categoryName ||
                skill.contains(categoryName) ||
                categoryName.contains(skill)) {
              return category as Map<String, dynamic>;
            }
          }
        }
      }
    }

    final serviceText = _providerServiceText(provider).toLowerCase();
    for (final category in _categories) {
      final categoryName = (category['name'] ?? '').toString().toLowerCase();
      if (categoryName.isNotEmpty && serviceText.contains(categoryName)) {
        return category as Map<String, dynamic>;
      }
    }

    return null;
  }

  Future<void> _openBookingForProvider(Map provider) async {
    if (_categories.isEmpty) return;
    final category =
        _findCategoryForProvider(provider) ??
        (_selectedService.isNotEmpty
                ? _categories.firstWhere(
                    (cat) =>
                        (cat['name'] ?? '').toString().toLowerCase() ==
                        _selectedService.toLowerCase(),
                    orElse: () => _categories[0],
                  )
                : _categories[0])
            as Map<String, dynamic>;
    final created = await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => CreateBookingScreen(
          category: category,
          initialProviderId: int.tryParse(provider['id']?.toString() ?? ''),
          excludedProviderId: _currentProviderId,
        ),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(scale: animation, child: child),
          );
        },
      ),
    );
    if (!mounted) return;
    if (created == true) {
      setState(() {
        _navIndex = 1;
        _bookingsRefreshToken++;
      });
    }
  }

  Future<void> _showProviderFilters() async {
    String tempCity = _selectedCity;
    String tempService = _selectedService;
    final feeCtrl = TextEditingController(
      text: _maxFee == null ? '' : _formatPrice(_maxFee),
    );

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final services = _categories
                .map((category) => (category['name'] ?? '').toString())
                .where((name) => name.trim().isNotEmpty)
                .toList(growable: false);
            final cities = _availableCities;

            return SafeArea(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text(
                            'Filter Providers',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {
                              feeCtrl.clear();
                              setSheetState(() {
                                tempCity = '';
                                tempService = '';
                              });
                            },
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Maximum fee',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: feeCtrl,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'e.g. 1500',
                          prefixText: 'PKR ',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'City',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _filterChip(
                            label: 'Any',
                            selected: tempCity.isEmpty,
                            onTap: () => setSheetState(() => tempCity = ''),
                          ),
                          ...cities.map(
                            (city) => _filterChip(
                              label: city,
                              selected: tempCity == city,
                              onTap: () => setSheetState(() => tempCity = city),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        'Service',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _filterChip(
                            label: 'Any',
                            selected: tempService.isEmpty,
                            onTap: () => setSheetState(() => tempService = ''),
                          ),
                          ...services.map(
                            (service) => _filterChip(
                              label: service,
                              selected: tempService == service,
                              onTap: () =>
                                  setSheetState(() => tempService = service),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedCity = tempCity;
                              _selectedService = tempService;
                              _maxFee = double.tryParse(feeCtrl.text.trim());
                            });
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text('Apply Filters'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    feeCtrl.dispose();
  }

  Widget _filterChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textDark,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  void _showAllServices() {
    final services = _visibleCategories;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _listSheet(
          title: 'All Services',
          child: services.isEmpty
              ? const Center(child: Text('No services found'))
              : ListView.separated(
                  itemCount: services.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final category = services[index];
                    final name = (category['name'] ?? 'Service').toString();
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _catBg(index),
                        child: Icon(
                          _categoryIcon(name),
                          color: _catColor(index),
                        ),
                      ),
                      title: Text(name),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: () {
                        Navigator.pop(context);
                        _openBookingForCategory(category);
                      },
                    );
                  },
                ),
        );
      },
    );
  }

  void _showAllProviders() {
    final providers = _visibleProviders;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return _listSheet(
          title: 'All Providers',
          child: providers.isEmpty
              ? const Center(child: Text('No providers found'))
              : ListView.separated(
                  itemCount: providers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final provider = providers[index] as Map;
                    final name = _providerName(provider);
                    final city = _providerCity(provider);
                    final fee = _formatPrice(
                      provider['price_per_hour'] ??
                          provider['price'] ??
                          provider['hourly_rate'],
                    );
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _catBg(index),
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'P',
                          style: TextStyle(
                            color: _catColor(index),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(
                        [
                          _providerServiceText(provider),
                          if (city.isNotEmpty) city,
                          'PKR $fee/hr',
                        ].where((value) => value.trim().isNotEmpty).join(' • '),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _openBookingForProvider(provider);
                        },
                        child: const Text('Book'),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _listSheet({required String title, required Widget child}) {
    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.78,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Expanded(child: child),
            ],
          ),
        ),
      ),
    );
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

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good morning';
    if (h < 17) return 'Good afternoon';
    return 'Good evening';
  }

  String _firstName() {
    return _userName.split(' ').first;
  }

  String? _profilePicUrl(dynamic rawValue) {
    if (rawValue == null) return null;
    if (rawValue is String && rawValue.trim().isNotEmpty) {
      final value = rawValue.trim();
      if (value.startsWith('http://') || value.startsWith('https://')) {
        return value;
      }
      return ApiService.resolveImageUrl(value);
    }
    if (rawValue is Map && rawValue['url'] is String) {
      return ApiService.resolveImageUrl(rawValue['url'].toString());
    }
    return null;
  }

  String _formatPrice(dynamic rawValue) {
    if (rawValue == null) return '0';
    if (rawValue is num) {
      return rawValue % 1 == 0
          ? rawValue.toStringAsFixed(0)
          : rawValue.toStringAsFixed(2);
    }
    final parsed = double.tryParse(rawValue.toString());
    if (parsed != null) {
      return parsed % 1 == 0
          ? parsed.toStringAsFixed(0)
          : parsed.toStringAsFixed(2);
    }
    return rawValue.toString();
  }

  IconData _categoryIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains('plumb')) return Icons.plumbing_rounded;
    if (n.contains('electric')) return Icons.electrical_services_rounded;
    if (n.contains('clean')) return Icons.cleaning_services_rounded;
    if (n.contains('carpet')) return Icons.carpenter_rounded;
    if (n.contains('paint')) return Icons.format_paint_rounded;
    if (n.contains('ac')) return Icons.ac_unit_rounded;
    if (n.contains('garden')) return Icons.grass_rounded;
    return Icons.handyman_rounded;
  }

  Color _catBg(int i) => [
    const Color(0xFFE8F4FD),
    const Color(0xFFE0F9F9),
    const Color(0xFFFFF3E0),
    const Color(0xFFF3E5F5),
    const Color(0xFFE8F5E9),
    const Color(0xFFFFEBEE),
  ][i % 6];

  Color _catColor(int i) => [
    AppColors.primary,
    AppColors.cyan,
    const Color(0xFFFF9800),
    const Color(0xFF9C27B0),
    const Color(0xFF4CAF50),
    const Color(0xFFE53935),
  ][i % 6];

  Future<void> _logout() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Logout',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await ApiService.clearToken();
              if (mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (_) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          _loading
              ? const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                )
              : PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _navIndex = index;
                    });
                  },
                  children: [
                    _buildHome(),
                    MyBookingsScreen(
                      embedded: true,
                      refreshToken: _bookingsRefreshToken,
                    ),
                    _buildPaymentsSection(),
                    _buildProfile(),
                    _buildProviderTab(),
                  ],
                ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ── HOME TAB ─────────────────────────────────────────
  Widget _buildHome() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          // ── Header ────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF3A6F9F), Color(0xFF4682B4)],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Location + Avatar row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  'Karachi, Gulshan-e-Iqbal',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: _logout,
                            icon: const Icon(
                              Icons.logout_rounded,
                              color: Colors.white,
                            ),
                            tooltip: 'Logout',
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Greeting
                      Row(
                        children: [
                          Text(
                            '${_greeting()}, ${_firstName()} 👋',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Search bar
                      ClipRRect(
                        borderRadius: BorderRadius.circular(18),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.15),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.search_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: TextField(
                                    controller: _searchCtrl,
                                    onChanged: (value) {
                                      setState(() => _searchQuery = value);
                                    },
                                    cursorColor: Colors.white,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                    ),
                                    decoration: InputDecoration(
                                      isDense: true,
                                      border: InputBorder.none,
                                      hintText: 'Search services or providers',
                                      hintStyle: TextStyle(
                                        color: Colors.white.withOpacity(0.8),
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                if (_searchQuery.isNotEmpty)
                                  GestureDetector(
                                    onTap: () {
                                      _searchCtrl.clear();
                                      setState(() => _searchQuery = '');
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(6),
                                      child: Icon(
                                        Icons.close_rounded,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                GestureDetector(
                                  onTap: _showProviderFilters,
                                  child: Container(
                                    padding: const EdgeInsets.all(6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.tune_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Promo Banner ───────────────────────
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(const ClipboardData(text: 'LABOURGO'));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Code copied to clipboard!'),
                          backgroundColor: AppColors.primary,
                        ),
                      );
                      _confettiController.play();
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.cyan, AppColors.primary],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.textDark.withOpacity(0.12),
                            blurRadius: 22,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'First Booking Free!',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Use code LABOURGO [TAP TO COPY]',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Text('🎁', style: TextStyle(fontSize: 32)),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Services ───────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Our Services',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAllServices,
                        child: Row(
                          children: [
                            Text(
                              'See All',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal categories
                  SizedBox(
                    height: 90,
                    child: _visibleCategories.isEmpty
                        ? const Center(child: Text('No services'))
                        : AnimationLimiter(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _visibleCategories.length,
                              itemBuilder: (context, i) {
                                final cat = _visibleCategories[i];
                                return AnimationConfiguration.staggeredList(
                                  position: i,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: GestureDetector(
                                        onTap: () =>
                                            _openBookingForCategory(cat),
                                        child: Container(
                                          width: 90,
                                          margin: const EdgeInsets.only(
                                            right: 12,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: AppColors.textDark
                                                    .withOpacity(0.06),
                                                blurRadius: 14,
                                                offset: const Offset(0, 8),
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Container(
                                                width: 42,
                                                height: 42,
                                                decoration: BoxDecoration(
                                                  color: _catBg(i),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: Icon(
                                                  _categoryIcon(cat['name']),
                                                  color: _catColor(i),
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(height: 6),
                                              Hero(
                                                tag: 'category-${cat['name']}',
                                                child: Text(
                                                  cat['name'],
                                                  style: const TextStyle(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight.w500,
                                                    color: AppColors.textDark,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),

                  const SizedBox(height: 24),

                  // ── Top Providers ──────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Top Providers',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      GestureDetector(
                        onTap: _showAllProviders,
                        child: Row(
                          children: [
                            Text(
                              'See All',
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.primary,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Horizontal provider cards
                  SizedBox(
                    height: 210,
                    child: _visibleProviders.isEmpty
                        ? Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: const Center(
                              child: Text(
                                'No providers yet',
                                style: TextStyle(color: AppColors.textMuted),
                              ),
                            ),
                          )
                        : _loading
                        ? Shimmer.fromColors(
                            baseColor: Colors.grey[300]!,
                            highlightColor: Colors.grey[100]!,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: 3,
                              itemBuilder: (context, i) {
                                return Container(
                                  width: 168,
                                  margin: const EdgeInsets.only(right: 14),
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(22),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 46,
                                            height: 46,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            width: 18,
                                            height: 18,
                                            decoration: const BoxDecoration(
                                              color: Colors.white,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        width: 100,
                                        height: 14,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        width: 60,
                                        height: 11,
                                        color: Colors.white,
                                      ),
                                      const SizedBox(height: 6),
                                      Row(
                                        children: [
                                          Container(
                                            width: 14,
                                            height: 14,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 3),
                                          Container(
                                            width: 30,
                                            height: 12,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            width: 40,
                                            height: 11,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        width: 80,
                                        height: 13,
                                        color: Colors.white,
                                      ),
                                      const Spacer(),
                                      Container(
                                        width: double.infinity,
                                        height: 32,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          )
                        : AnimationLimiter(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: _visibleProviders.length,
                              itemBuilder: (context, i) {
                                final p = _visibleProviders[i];
                                return AnimationConfiguration.staggeredList(
                                  position: i,
                                  duration: const Duration(milliseconds: 375),
                                  child: SlideAnimation(
                                    horizontalOffset: 50.0,
                                    child: FadeInAnimation(
                                      child: _providerCard(p, i),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentsSection() {
    return RefreshIndicator(
      onRefresh: _loadData,
      color: AppColors.primary,
      child: _paymentsLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _payments.isEmpty
          ? ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.receipt_long,
                        size: 64,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 14),
                      Text(
                        _paymentsError ?? 'No payments yet',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: AppColors.textMuted,
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
              itemCount: _payments.length,
              itemBuilder: (context, index) {
                final payment = _payments[index];
                final bookingInfo = payment['booking_info'] ?? {};
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textDark.withOpacity(0.06),
                        blurRadius: 14,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                bookingInfo['service'] ?? 'Service',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                bookingInfo['provider'] ?? 'Provider',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.textMuted,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: _paymentStatusColor(
                                payment['status'],
                              ).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              payment['status']?.toString().toUpperCase() ??
                                  'UNKNOWN',
                              style: TextStyle(
                                color: _paymentStatusColor(payment['status']),
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'PKR ${payment['amount']?.toString() ?? '0'}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.payment,
                            size: 16,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            payment['method']?.toString().toUpperCase() ??
                                'UNKNOWN',
                            style: const TextStyle(color: AppColors.textMuted),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      if (payment['transaction_id'] != null)
                        Text(
                          'TxID: ${payment['transaction_id']}',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Color _paymentStatusColor(String? status) {
    switch (status) {
      case 'paid':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
        return Colors.red;
      case 'refunded':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Widget _providerCard(Map p, int index) {
    final name = p['name'] ?? p['full_name'] ?? 'Provider';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'P';
    final photoUrl = _profilePicUrl(p['image'] ?? p['profile_pic']);
    final specialty = _providerPrimaryService(p);
    final ratingValue = p['rating'] is num
        ? (p['rating'] as num).toDouble()
        : double.tryParse(p['rating']?.toString() ?? '') ?? 0.0;
    final ratingText = ratingValue.toStringAsFixed(1);
    final jobsCompleted = p['jobs_completed']?.toString() ?? '0';
    final pricePerHour = _formatPrice(
      p['price_per_hour'] ?? p['price'] ?? p['hourly_rate'],
    );

    return Container(
      width: 168,
      margin: const EdgeInsets.only(right: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            offset: const Offset(4, 4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-4, -4),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + verified badge
          Row(
            children: [
              photoUrl == null
                  ? Hero(
                      tag: 'provider-avatar-${p['id']}',
                      child: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_catColor(index), _catColor(index + 2)],
                          ),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                  : Hero(
                      tag: 'provider-avatar-${p['id']}',
                      child: ClipOval(
                        child: Image.network(
                          photoUrl,
                          width: 46,
                          height: 46,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  _catColor(index),
                                  _catColor(index + 2),
                                ],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                initial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
              const SizedBox(width: 6),
              const Icon(
                Icons.verified_rounded,
                color: AppColors.cyan,
                size: 18,
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Name
          Hero(
            tag: 'provider-name-${p['id']}',
            child: Text(
              name.length > 12 ? '${name.substring(0, 10)}...' : name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ),

          // Specialty / Service
          Text(
            specialty.toString(),
            style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          // Rating + jobs completed
          Row(
            children: [
              const Icon(
                Icons.star_rounded,
                color: Color(0xFFFFC107),
                size: 14,
              ),
              const SizedBox(width: 4),
              Text(
                ratingText,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '($jobsCompleted jobs)',
                style: const TextStyle(
                  fontSize: 11,
                  color: AppColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),

          const SizedBox(height: 6),

          // Price
          Text(
            'PKR $pricePerHour/hr',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),

          const Spacer(),

          GestureDetector(
            onTap: () => _openBookingForProvider(p),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: const Center(
                child: Text(
                  'Book',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PROFILE TAB ──────────────────────────────────────
  Widget _buildProfile() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.cyan],
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _firstName().isNotEmpty ? _firstName()[0].toUpperCase() : 'U',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _userName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Customer',
              style: TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 32),
            _profileTile(Icons.person_outlined, 'Edit Profile', () async {
              if (_profile == null) return;

              final updated = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => EditProfileScreen(initialProfile: _profile!),
                ),
              );
              if (updated == true) {
                _loadData();
              }
            }),
            _profileTile(Icons.history_rounded, 'Booking History', () {
              setState(() {
                _navIndex = 1;
                _bookingsRefreshToken++;
              });
            }),
            _profileTile(Icons.payment_rounded, 'Payment History', () {
              setState(() {
                _navIndex = 2;
              });
            }),
            _profileTile(Icons.help_outline_rounded, 'Help & Support', () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Help & Support coming soon')),
              );
            }),

            _profileTile(Icons.work_outline_rounded, 'Become a Provider', () {
              Navigator.pushNamed(context, '/provider_intro');
            }),
            const SizedBox(height: 16),
            _profileTile(
              Icons.logout_rounded,
              'Logout',
              _logout,
              color: AppColors.error,
            ),
          ],
        ),
      ),
    );
  }

  // ── PROVIDER TAB ─────────────────────────────────────
  Widget _buildProviderTab() {
    final isProvider = _currentProviderId != null;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Icon(
              Icons.work_outline_rounded,
              size: 64,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            Text(
              isProvider ? 'Provider Dashboard' : 'Become a Provider',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isProvider
                  ? 'You are registered as a provider. Manage your profile and bookings from the provider section.'
                  : 'Join LabourGo as a trusted service provider to get bookings from customers in your area.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProviderIntroScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(isProvider ? 'Open Provider Intro' : 'Get Started'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileTile(
    IconData icon,
    String title,
    VoidCallback onTap, {
    Color? color,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 0.8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color ?? AppColors.primary, size: 22),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color ?? AppColors.textDark,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textMuted,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── BOTTOM NAV ───────────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      {'icon': Icons.home_rounded, 'label': 'Home'},
      {'icon': Icons.calendar_month_rounded, 'label': 'Bookings'},
      {'icon': Icons.payment_rounded, 'label': 'Payments'},
      {'icon': Icons.person_rounded, 'label': 'Profile'},
      {'icon': Icons.work_outline_rounded, 'label': 'Provider'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(items.length, (index) {
          final item = items[index];
          final active = index == _navIndex;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (index == 1 && _navIndex != 1) {
                  _bookingsRefreshToken++;
                }
                setState(() {
                  _navIndex = index;
                });
                _pageController.animateToPage(
                  index,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: active ? AppColors.primary : AppColors.textMuted,
                    size: 24,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    item['label'] as String,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: active ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _pageController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
