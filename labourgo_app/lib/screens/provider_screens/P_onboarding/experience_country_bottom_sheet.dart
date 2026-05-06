import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';

const _kBlue = AppColors.primary;
const _kCyan = AppColors.accent;
const _kWhite = Colors.white;
const _kBg = Color(0xFFF4F8FD);
const _kBorder = Color(0xFFD0E4F5);
const _kSubText = Color(0xFF7A9ABF);

Future<String?> showCityBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => const _CitySheet(),
  );
}

class _CitySheet extends StatefulWidget {
  const _CitySheet();

  @override
  State<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends State<_CitySheet> {
  String? _selected;
  String _search = '';
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _cities = [];

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      final cities = await ApiService.fetchCities();
      setState(() {
        _cities = cities
            .map((item) => {
                  'label': (item['label'] ?? '').toString(),
                  'tag': (item['tag'] ?? '').toString(),
                })
            .where((item) => (item['label'] ?? '').toString().isNotEmpty)
            .toList();
      });
    } catch (e) {
      setState(() => _error = 'Unable to load cities');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<Map<String, dynamic>> get _filtered => _cities
      .where((c) =>
          (c['label'] as String)
              .toLowerCase()
              .contains(_search.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _kWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Handle ──
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: _kBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),

          // ── Title ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: _kBlue.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: _kBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Select Your City',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: _kBlue,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    Text(
                      'Where do you offer your services?',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kSubText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // ── Search bar ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              onChanged: (val) => setState(() => _search = val),
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF1A2A3A),
                fontFamily: 'Poppins',
              ),
              decoration: InputDecoration(
                hintText: 'Search city...',
                hintStyle: const TextStyle(
                  color: _kSubText,
                  fontSize: 13,
                  fontFamily: 'Poppins',
                ),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: _kBlue,
                  size: 20,
                ),
                filled: true,
                fillColor: _kBg,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kBorder, width: 1.2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kBorder, width: 1.2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: _kBlue, width: 1.8),
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── City list ──
          ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.45,
            ),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _filtered.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Column(
                          children: [
                            Icon(Icons.location_off_rounded,
                                color: _kSubText, size: 40),
                            const SizedBox(height: 10),
                            Text(
                              _error ?? 'No city found',
                              style: const TextStyle(
                                color: _kSubText,
                                fontSize: 14,
                                fontFamily: 'Poppins',
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: _filtered.length,
                        separatorBuilder: (_, __) => Divider(
                          color: _kBorder,
                          height: 1,
                          thickness: 1,
                        ),
                        itemBuilder: (context, index) {
                          final city = _filtered[index];
                          final label = (city['label'] ?? '').toString();
                          final tag = (city['tag'] ?? '').toString();
                          final isSelected = _selected == label;

                          return GestureDetector(
                            onTap: () {
                              setState(() => _selected = label);
                              Future.delayed(
                                const Duration(milliseconds: 180),
                                () => Navigator.pop(context, label),
                              );
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 13,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? _kBlue.withOpacity(0.06)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  // Location pin icon
                                  Container(
                                    width: 38,
                                    height: 38,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? _kBlue.withOpacity(0.12)
                                          : _kBg,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      Icons.location_on_rounded,
                                      color: isSelected ? _kBlue : _kSubText,
                                      size: 18,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  // City name + province tag
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          label,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: isSelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: isSelected
                                                ? _kBlue
                                                : const Color(0xFF1A2A3A),
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                        Text(
                                          tag,
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: _kSubText,
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Checkmark if selected
                                  if (isSelected)
                                    Container(
                                      width: 24,
                                      height: 24,
                                      decoration: const BoxDecoration(
                                        color: _kCyan,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check_rounded,
                                        color: _kBlue,
                                        size: 14,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}