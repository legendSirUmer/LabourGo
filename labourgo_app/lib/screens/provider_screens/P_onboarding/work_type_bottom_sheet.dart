import 'package:flutter/material.dart';
import '../../../services/api_service.dart';
import '../../../theme/app_theme.dart';

const _kBlue = AppColors.primary;
const _kCyan = AppColors.accent;
const _kWhite = Colors.white;
const _kBg = Color(0xFFF4F8FD);
const _kBorder = Color(0xFFD0E4F5);
const _kSubText = Color(0xFF7A9ABF);

Future<String?> showWorkTypeBottomSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _WorkTypeSheet(),
  );
}

class _WorkTypeSheet extends StatefulWidget {
  @override
  State<_WorkTypeSheet> createState() => _WorkTypeSheetState();
}

class _WorkTypeSheetState extends State<_WorkTypeSheet> {
  final TextEditingController _controller = TextEditingController();
  String? _selected;
  bool _loading = true;
  String? _error;
  List<Map<String, dynamic>> _workTypes = [];

  @override
  void initState() {
    super.initState();
    _loadWorkTypes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadWorkTypes() async {
    try {
      final categories = await ApiService.fetchServiceCategories();
      setState(() {
        _workTypes = categories
            .map((item) => {
                  'label': (item['name'] ?? '').toString(),
                  'iconUrl': ApiService.resolveImageUrl(
                    item['icon']?.toString(),
                  ),
                })
            .where((item) => (item['label'] ?? '').toString().isNotEmpty)
            .toList();
      });
    } catch (e) {
      setState(() => _error = 'Unable to load services');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _submit(String value) {
    final trimmed = value.trim();
    if (trimmed.isNotEmpty) Navigator.pop(context, trimmed);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                      Icons.construction_rounded,
                      color: _kBlue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Work Type',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _kBlue,
                          fontFamily: 'Poppins',
                        ),
                      ),
                      Text(
                        'Choose your primary skill',
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

            const SizedBox(height: 20),

            // ── Work type grid ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _loading
                  ? const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _workTypes.isEmpty
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            _error ?? 'No services available',
                            style: const TextStyle(
                              color: _kSubText,
                              fontSize: 12,
                              fontFamily: 'Poppins',
                            ),
                          ),
                        )
                      : GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 10,
                            mainAxisSpacing: 10,
                            childAspectRatio: 1.1,
                          ),
                          itemCount: _workTypes.length,
                          itemBuilder: (context, index) {
                            final item = _workTypes[index];
                            final label = (item['label'] ?? '').toString();
                            final iconUrl = item['iconUrl'] as String?;
                            final isSelected = _selected == label;
                            return GestureDetector(
                              onTap: () {
                                setState(() => _selected = label);
                                Future.delayed(
                                    const Duration(milliseconds: 180), () {
                                  Navigator.pop(context, label);
                                });
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? _kBlue.withOpacity(0.08)
                                      : _kBg,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? _kBlue : _kBorder,
                                    width: isSelected ? 1.8 : 1.2,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? _kBlue.withOpacity(0.12)
                                            : _kWhite,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected ? _kBlue : _kBorder,
                                          width: 1,
                                        ),
                                      ),
                                      child: iconUrl != null && iconUrl.isNotEmpty
                                          ? ClipOval(
                                              child: Image.network(
                                                iconUrl,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Icon(
                                              Icons.construction_rounded,
                                              color:
                                                  isSelected ? _kBlue : _kSubText,
                                              size: 20,
                                            ),
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      label,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: isSelected
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isSelected
                                            ? _kBlue
                                            : const Color(0xFF1A2A3A),
                                        fontFamily: 'Poppins',
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

            // ── Divider ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(child: Divider(color: _kBorder, thickness: 1)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'or add your own',
                      style: TextStyle(
                        fontSize: 12,
                        color: _kSubText,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ),
                  Expanded(child: Divider(color: _kBorder, thickness: 1)),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Custom input ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1A2A3A),
                  fontFamily: 'Poppins',
                ),
                onSubmitted: _submit,
                decoration: InputDecoration(
                  hintText: 'Type your service (e.g. Welder)',
                  hintStyle: const TextStyle(
                    color: _kSubText,
                    fontSize: 13,
                    fontFamily: 'Poppins',
                  ),
                  prefixIcon: const Icon(
                    Icons.edit_outlined,
                    color: _kBlue,
                    size: 20,
                  ),
                  filled: true,
                  fillColor: _kBg,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
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

            // ── Add button ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => _submit(_controller.text),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kCyan,
                    foregroundColor: _kBlue,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, size: 20),
                      SizedBox(width: 6),
                      Text(
                        'Add Custom Service',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }
}