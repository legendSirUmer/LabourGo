import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';

// ─────────────────────────────────────────────
//  App Colors
// ─────────────────────────────────────────────
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

// ─────────────────────────────────────────────
//  PricingScreen — same logic, new UI
// ─────────────────────────────────────────────
class PricingScreen extends StatefulWidget {
  const PricingScreen({super.key});

  @override
  State<PricingScreen> createState() => _PricingScreenState();
}

class _PricingScreenState extends State<PricingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController priceController = TextEditingController();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  int? _providerId;
  String? _selectedSkill;

  // For local display list (mirrors web app table)
  // Each entry: { 'service': String, 'price': double }
  final List<Map<String, dynamic>> _pricingList = [];
  final List<String> _profileSkills = [];

  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  // For inline edit
  int? _editingIndex;
  final TextEditingController _editPriceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeOut);
    _loadPricing();
  }

  @override
  void dispose() {
    priceController.dispose();
    _editPriceController.dispose();
    _fadeCtrl.dispose();
    super.dispose();
  }

  // ── ORIGINAL LOGIC (unchanged) ─────────────

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

  List<String> _parseSkills(dynamic value) {
    return (value ?? '')
        .toString()
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  List<Map<String, dynamic>> _parseServicePricing(dynamic value) {
    dynamic source = value;
    if (source is String && source.trim().isNotEmpty) {
      try {
        source = jsonDecode(source);
      } catch (_) {
        source = null;
      }
    }

    if (source is! List) return [];

    return source
        .whereType<Map>()
        .map((item) {
          final service = (item['service'] ?? '').toString().trim();
          final rawPrice = item['price'];
          final price =
              rawPrice is num ? rawPrice.toDouble() : double.tryParse('$rawPrice');

          if (service.isEmpty || price == null || price <= 0) return null;

          return {
            'service': service,
            'price': price,
          };
        })
        .whereType<Map<String, dynamic>>()
        .toList();
  }

  Future<void> _syncServicePricing() async {
    if (_providerId == null) return;

    final payload = _pricingList
        .map((entry) => {
              'service': entry['service'].toString(),
              'price': entry['price'],
            })
        .toList();

    await ApiService.updateProvider(_providerId!, {
      'service_pricing': payload,
      if (_pricingList.isNotEmpty) 'price_per_hour': _pricingList.last['price'],
    });
  }

  Future<void> _loadPricing() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final providerId = await _resolveProviderId();
      if (providerId == null) {
        setState(() => _error = 'Provider not found');
        return;
      }

      final data = await ApiService.getProviderById(providerId);

      setState(() {
        _providerId = providerId;

        _profileSkills
          ..clear()
          ..addAll(_parseSkills(data['skills']));

        _pricingList.clear();
        _pricingList.addAll(_parseServicePricing(data['service_pricing']));
        _pricingList.removeWhere(
          (entry) => !_profileSkills.contains(entry['service'].toString()),
        );

        if (_pricingList.isEmpty) {
          final price = data['price_per_hour'];
          final parsedPrice =
              price is num ? price.toDouble() : double.tryParse('$price');

          if (parsedPrice != null && parsedPrice > 0) {
            for (final skill in _profileSkills) {
              _pricingList.add({
                'service': skill,
                'price': parsedPrice,
              });
            }
          }
        }

        _selectedSkill = _profileSkills.isNotEmpty ? _profileSkills.first : null;
        priceController.clear();
      });

      _fadeCtrl.forward();
    } catch (e) {
      setState(() => _error = 'Failed to load pricing');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _savePricing() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_providerId == null) return;
    final selectedSkill = _selectedSkill?.trim();
    if (selectedSkill == null || selectedSkill.isEmpty) {
      _showSnack('Select a skill first', isError: true);
      return;
    }

    setState(() => _saving = true);
    try {
      final price = double.parse(priceController.text.trim());
      final existingIndex = _pricingList.indexWhere(
        (entry) => entry['service'].toString() == selectedSkill,
      );

      setState(() {
        if (existingIndex >= 0) {
          _pricingList[existingIndex]['price'] = price;
        } else {
          _pricingList.add({
            'service': selectedSkill,
            'price': price,
          });
        }
      });

      await _syncServicePricing();

      if (!mounted) return;
      priceController.clear();
      _showSnack('Pricing updated successfully ✓');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to update pricing: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ── UI HELPERS ─────────────────────────────

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor:
            isError ? const Color(0xFFE24B4A) : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _startEdit(int index) {
    setState(() {
      _editingIndex = index;
      _editPriceController.text =
          _pricingList[index]['price'].toStringAsFixed(0);
    });
  }

  void _cancelEdit() => setState(() => _editingIndex = null);

  Future<void> _saveEdit(int index) async {
    final newPrice = double.tryParse(_editPriceController.text.trim());
    if (newPrice == null || newPrice <= 0) {
      _showSnack('Enter a valid price', isError: true);
      return;
    }
    if (_providerId == null) return;

    setState(() => _saving = true);
    try {
      setState(() {
        _pricingList[index]['price'] = newPrice;
        _editingIndex = null;
      });
      await _syncServicePricing();
      _showSnack('Pricing updated ✓');
    } catch (e) {
      _showSnack('Failed to update: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _deleteEntry(int index) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Pricing',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E3A5F))),
        content: Text(
          'Remove "${_pricingList[index]['service']}" pricing?',
          style: const TextStyle(fontSize: 14, color: Color(0xFF5A7A9A)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel',
                style: TextStyle(color: AppColors.primary)),
          ),
          TextButton(
            onPressed: () async {
              setState(() => _pricingList.removeAt(index));
              await _syncServicePricing();
              if (!mounted) return;
              Navigator.pop(context);
              _showSnack('Entry removed');
            },
            child: const Text('Remove',
                style: TextStyle(color: Color(0xFFE24B4A))),
          ),
        ],
      ),
    );
  }

  // ── BUILD ──────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _loading ? _buildLoader() : _buildContent(),
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
                  strokeWidth: 2.5, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Loading pricing…',
              style: TextStyle(color: AppColors.primary, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return FadeTransition(
      opacity: _fadeAnim,
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
                  _buildAddPricingCard(),
                  const SizedBox(height: 20),
                  _buildPricingListSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Hero Header ────────────────────────────

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
                  // Top bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const Text(
                        'Manage Pricing',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w600),
                      ),
                      _HeaderBtn(
                        icon: Icons.refresh_rounded,
                        onTap: _loadPricing,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Icon + title
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(Icons.monetization_on_outlined,
                        color: Colors.white, size: 32),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Set Your Rates',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Define your price per hour for each service',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Summary pill
                  if (_pricingList.isNotEmpty)
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
                          const Icon(Icons.list_alt_rounded,
                              color: Colors.white70, size: 14),
                          const SizedBox(width: 6),
                          Text(
                            '${_pricingList.length} service${_pricingList.length != 1 ? 's' : ''} configured',
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w500),
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

  // ── Add Pricing Card ───────────────────────

  Widget _buildAddPricingCard() {
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
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ADD SERVICE PRICING',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.08),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSkill,
              items: _profileSkills
                  .map(
                    (skill) => DropdownMenuItem(
                      value: skill,
                      child: Text(
                        skill,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: _profileSkills.isEmpty
                  ? null
                  : (value) => setState(() => _selectedSkill = value),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Select a skill' : null,
              style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E3A5F),
                  fontWeight: FontWeight.w600),
              decoration: InputDecoration(
                labelText: 'Skill',
                hintText: _profileSkills.isEmpty
                    ? 'Add skills in your profile first'
                    : 'Select a profile skill',
                prefixIcon: const Icon(Icons.handyman_outlined,
                    color: AppColors.primary, size: 20),
                filled: true,
                fillColor: const Color(0xFFF5F9FF),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: AppColors.primary, width: 1.5),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFE24B4A), width: 1),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide:
                      const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PKR badge
                Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2FB),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Center(
                    child: Text(
                      'PKR',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Price input
                Expanded(
                  child: TextFormField(
                    controller: priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.isEmpty) return 'Price is required';
                      final price = double.tryParse(text);
                      if (price == null) return 'Enter a valid price';
                      if (price <= 0) return 'Price must be greater than 0';
                      return null;
                    },
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF1E3A5F),
                        fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      labelText: 'Pricing',
                      hintText: '0.00',
                      hintStyle: const TextStyle(
                          color: Color(0xFFAAC4D8), fontSize: 15),
                      filled: true,
                      fillColor: const Color(0xFFF5F9FF),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE24B4A), width: 1),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: Color(0xFFE24B4A), width: 1.5),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                      ),
                      errorStyle: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Save button
            GestureDetector(
              onTap: _saving || _profileSkills.isEmpty ? null : _savePricing,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  gradient: _saving || _profileSkills.isEmpty
                      ? const LinearGradient(
                          colors: [Color(0xFFB0C4D8), Color(0xFFB0C4D8)])
                      : AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: _saving
                      ? []
                      : [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Center(
                  child: _saving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.5, color: Colors.white),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.save_outlined,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Save Pricing',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Pricing List Section ───────────────────

  Widget _buildPricingListSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'YOUR SERVICES',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  letterSpacing: 0.08),
            ),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_pricingList.length} total',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (_pricingList.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(
            _pricingList.length,
            (i) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildPricingRow(i),
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
            child: const Icon(Icons.price_change_outlined,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(height: 12),
          const Text('No pricing set yet',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1E3A5F))),
          const SizedBox(height: 4),
          const Text('Add your hourly rate above',
              style: TextStyle(fontSize: 12, color: Color(0xFF8FA8C0))),
        ],
      ),
    );
  }

  Widget _buildPricingRow(int index) {
    final entry = _pricingList[index];
    final isEditing = _editingIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isEditing
            ? Border.all(color: AppColors.primary, width: 1.5)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Service icon
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F2FB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.handyman_outlined,
                color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),

          // Service name + price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry['service'].toString(),
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A5F)),
                ),
                const SizedBox(height: 3),
                isEditing
                    ? SizedBox(
                        height: 32,
                        child: TextField(
                          controller: _editPriceController,
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          autofocus: true,
                          style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700),
                          decoration: const InputDecoration(
                            isDense: true,
                            contentPadding: EdgeInsets.only(bottom: 4),
                            border: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 1.5)),
                            focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                    color: AppColors.primary, width: 2)),
                            prefixText: 'PKR ',
                            prefixStyle: TextStyle(
                                fontSize: 13,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700),
                          ),
                        ),
                      )
                    : Text(
                        'PKR ${entry['price'].toStringAsFixed(2)}  •  per hour',
                        style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5A7A9A),
                            fontWeight: FontWeight.w500),
                      ),
              ],
            ),
          ),

          // Actions
          if (isEditing) ...[
            IconButton(
              onPressed: _cancelEdit,
              icon: const Icon(Icons.close_rounded,
                  color: Color(0xFF8FA8C0), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 2),
            GestureDetector(
              onTap: () => _saveEdit(index),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check_rounded,
                    color: Colors.white, size: 17),
              ),
            ),
          ] else ...[
            IconButton(
              onPressed: () => _startEdit(index),
              icon: const Icon(Icons.edit_outlined,
                  color: AppColors.primary, size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
            const SizedBox(width: 2),
            IconButton(
              onPressed: () => _deleteEntry(index),
              icon: const Icon(Icons.delete_outline_rounded,
                  color: Color(0xFFE24B4A), size: 20),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            ),
          ],
        ],
      ),
    );
  }

  // ── Error Banner ───────────────────────────

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
          const Icon(Icons.error_outline_rounded,
              color: Color(0xFFE24B4A), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                  color: Color(0xFFA32D2D),
                  fontSize: 13,
                  fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Reusable Widgets
// ─────────────────────────────────────────────

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
