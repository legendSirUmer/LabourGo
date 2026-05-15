import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../theme/app_theme.dart';
import 'work_type_bottom_sheet.dart';
import 'experience_country_bottom_sheet.dart';
import '/services/api_service.dart';

// ─────────────────────────────────────────────
// pubspec.yaml — add this dependency:
//   image_picker: ^1.0.4
// Then run: flutter pub get
// ─────────────────────────────────────────────

const _kBlue = AppColors.primary;
const _kCyan = AppColors.accent;
const _kWhite = Colors.white;
const _kBg = Color(0xFFF4F8FD);
const _kSubText = Color(0xFF7A9ABF);
const _kBorder = Color(0xFFD0E4F5);
const _kError = Color(0xFFE53935);
const _kSuccess = Color(0xFF43A047);

class ProviderFormScreen extends StatefulWidget {
  const ProviderFormScreen({super.key});

  @override
  State<ProviderFormScreen> createState() => _ProviderFormScreenState();
}

class _ProviderFormScreenState extends State<ProviderFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  // Profile image
  Uint8List? _profileImageBytes;
  String? _profileImageName;

  // Selectors
  String workType = "Select Work Type";
  String city = "Select City";

  // Controllers
  final TextEditingController name = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController experience = TextEditingController();
  final TextEditingController pricePerHour = TextEditingController();
  final TextEditingController cnic = TextEditingController();

  bool _workTypeTouched = false;
  bool _cityTouched = false;

  bool get _workTypeSelected => workType != "Select Work Type";
  bool get _citySelected => city != "Select City";
  bool get _workTypeError => _workTypeTouched && !_workTypeSelected;
  bool get _cityError => _cityTouched && !_citySelected;

  @override
  void initState() {
    super.initState();
    _loadPrefilledUserInfo();
  }

  Future<void> _loadPrefilledUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    final savedName = prefs.getString('user_name');
    final savedEmail = prefs.getString('user_email');
    final savedPhone = prefs.getString('user_phone');

    if (savedName != null && savedName.isNotEmpty) {
      name.text = savedName;
    }
    if (savedEmail != null && savedEmail.isNotEmpty) {
      email.text = savedEmail;
    }
    if (savedPhone != null && savedPhone.isNotEmpty) {
      phone.text = savedPhone;
    }
  }

  @override
  void dispose() {
    name.dispose();
    phone.dispose();
    email.dispose();
    experience.dispose();
    pricePerHour.dispose();
    cnic.dispose();
    super.dispose();
  }

  // ── Image picker ──
  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
      );
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        if (!mounted) return;
        setState(() {
          _profileImageBytes = bytes;
          _profileImageName = picked.name;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not pick image: $e'),
            backgroundColor: _kError,
          ),
        );
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: _kWhite,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: _kBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Upload Profile Photo',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _kBlue,
                fontFamily: 'Poppins',
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                // Camera
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _kBlue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _kBorder, width: 1.2),
                      ),
                      child: const Column(
                        children: [
                          Icon(Icons.camera_alt_rounded,
                              color: _kBlue, size: 32),
                          SizedBox(height: 8),
                          Text('Camera',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kBlue,
                                fontFamily: 'Poppins',
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Gallery
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        color: _kCyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                            color: _kCyan.withOpacity(0.4), width: 1.2),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.photo_library_rounded,
                              color: _kCyan.withOpacity(0.9), size: 32),
                          const SizedBox(height: 8),
                          Text('Gallery',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _kCyan.withOpacity(0.9),
                                fontFamily: 'Poppins',
                              )),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Remove photo (only if image selected)
            if (_profileImageBytes != null)
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _profileImageBytes = null;
                    _profileImageName = null;
                  });
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Remove Photo',
                    style: TextStyle(
                      color: _kError,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

 void _submit() async {
  setState(() {
    _workTypeTouched = true;
    _cityTouched = true;
  });

  final formValid = _formKey.currentState?.validate() ?? false;

  if (!formValid || !_workTypeSelected || !_citySelected) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please fill all fields")),
    );
    return;
  }

  if (_profileImageBytes == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Please upload a profile photo")),
    );
    return;
  }

  try {
    final cleanPhone = phone.text.replaceAll(RegExp(r'[^0-9]'), '');
    final experienceYears = int.tryParse(experience.text.trim());
    final priceValue = double.tryParse(pricePerHour.text.trim());

    if (experienceYears == null || priceValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter valid numeric values")),
      );
      return;
    }

    final existing = await ApiService.findProviderByEmailPhone(
      email.text.trim(),
      cleanPhone,
    );

    if (existing != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Provider already registered")),
      );
      return;
    }

    final created = await ApiService.createProvider(
      data: {
        "name": name.text.trim(),
        "email": email.text.trim(),
        "phone": cleanPhone,
        "skills": workType,
        "experience": experienceYears,
        "price_per_hour": priceValue,
      },
      imageBytes: _profileImageBytes,
      imageName: _profileImageName,
    );

    // ✅ IMPORTANT FIX — SAVE USER DATA
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_email', email.text.trim());
    await prefs.setString('user_phone', cleanPhone);
    await prefs.setString('user_name', name.text.trim());
    final providerId = created['id'];
    if (providerId is int) {
      await prefs.setInt('provider_id', providerId);
    } else if (providerId is String) {
      final parsed = int.tryParse(providerId);
      if (parsed != null) {
        await prefs.setInt('provider_id', parsed);
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Form Submitted Successfully"),
        backgroundColor: _kSuccess,
      ),
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => _ProviderApprovalPendingScreen(
          email: email.text.trim(),
          phone: phone.text.trim(),
        ),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Error: $e")),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        centerTitle: true,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _kBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.arrow_back_ios_new_rounded,
                color: _kBlue, size: 18),
          ),
        ),
        title: const Text(
          'Worker Registration',
          style: TextStyle(
            color: _kBlue,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: _kBorder, height: 1),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          children: [
            // ── Header card ──
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [_kBlue, Color(0xFF5BA3D9)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: _kBlue.withOpacity(0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: _kWhite.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.person_add_rounded,
                        color: _kWhite, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Worker Registration',
                            style: TextStyle(
                                color: _kWhite,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Poppins')),
                        SizedBox(height: 2),
                        Text('All fields marked * are required',
                            style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontFamily: 'Poppins')),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Profile Image Upload ──
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: Stack(
                      children: [
                        // Avatar circle
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _kBlue.withOpacity(0.08),
                            border: Border.all(
                              color: _profileImageBytes != null
                                  ? _kBlue
                                  : _kBorder,
                              width: 2,
                            ),
                            image: _profileImageBytes != null
                                ? DecorationImage(
                                    image:
                                        MemoryImage(_profileImageBytes!),
                                    fit: BoxFit.cover,
                                  )
                                : null,
                          ),
                          child: _profileImageBytes == null
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.person_rounded,
                                        color: _kBlue.withOpacity(0.4),
                                        size: 40),
                                  ],
                                )
                              : null,
                        ),
                        // Camera badge
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 30,
                            height: 30,
                            decoration: BoxDecoration(
                              color: _kBlue,
                              shape: BoxShape.circle,
                              border:
                                  Border.all(color: _kWhite, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt_rounded,
                                color: _kWhite, size: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _profileImageBytes != null
                        ? 'Tap to change photo'
                        : 'Upload Profile Photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: _profileImageBytes != null ? _kBlue : _kSubText,
                      fontWeight: _profileImageBytes != null
                          ? FontWeight.w600
                          : FontWeight.w400,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Personal Info ──
            _SectionLabel(label: 'Personal Information'),
            const SizedBox(height: 12),

            _ValidatedField(
              controller: name,
              label: 'Full Name *',
              hint: 'e.g. Ahmed Raza',
              icon: Icons.person_outline_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Full name is required';
                if (v.trim().length < 3)
                  return 'Name must be at least 3 characters';
                return null;
              },
            ),
            const SizedBox(height: 12),

            _ValidatedField(
              controller: phone,
              label: 'Phone Number *',
              hint: '03XX-XXXXXXX',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Phone number is required';
                final clean =
                    v.replaceAll('-', '').replaceAll(' ', '');
                if (!RegExp(r'^03[0-9]{9}$').hasMatch(clean)) {
                  return 'Enter a valid Pakistani number (03XX-XXXXXXX)';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            _ValidatedField(
              controller: email,
              label: 'Email Address *',
              hint: 'example@email.com',
              icon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Email is required';
                if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$')
                    .hasMatch(v.trim())) {
                  return 'Enter a valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // ── CNIC field ──
            _ValidatedField(
              controller: cnic,
              label: 'CNIC *',
              hint: 'XXXXX-XXXXXXX-X',
              icon: Icons.credit_card_rounded,
              keyboardType: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'CNIC is required';
                final clean =
                    v.replaceAll('-', '').replaceAll(' ', '');
                if (!RegExp(r'^\d{13}$').hasMatch(clean)) {
                  return 'Enter a valid 13-digit CNIC (XXXXX-XXXXXXX-X)';
                }
                return null;
              },
              inputFormatters: [CnicInputFormatter()],
            ),

            const SizedBox(height: 24),

            // ── Work Details ──
            _SectionLabel(label: 'Work Details'),
            const SizedBox(height: 12),

            _SelectorField(
              label: 'Work Type *',
              value: workType,
              isSelected: _workTypeSelected,
              hasError: _workTypeError,
              icon: Icons.construction_rounded,
              onTap: () async {
                setState(() => _workTypeTouched = true);
                final result = await showWorkTypeBottomSheet(context);
                if (!mounted) return;
                if (result != null) setState(() => workType = result);
              },
            ),
            if (_workTypeError) _ErrorText(text: 'Please select a work type'),

            const SizedBox(height: 12),

            _ValidatedField(
              controller: experience,
              label: 'Years of Experience *',
              hint: 'e.g. 3',
              icon: Icons.workspace_premium_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Experience is required';
                final n = int.tryParse(v.trim());
                if (n == null) return 'Enter a valid number';
                if (n < 0 || n > 50) return 'Enter a value between 0 and 50';
                return null;
              },
            ),
            const SizedBox(height: 12),

            _ValidatedField(
              controller: pricePerHour,
              label: 'Price Per Hour (PKR) *',
              hint: 'e.g. 1500',
              icon: Icons.price_change_outlined,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
              ],
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return 'Price per hour is required';
                final n = double.tryParse(v.trim());
                if (n == null) return 'Enter a valid price';
                if (n <= 0) return 'Price must be greater than 0';
                if (n > 100000) return 'Enter a value below 100000';
                return null;
              },
            ),
            const SizedBox(height: 12),

            _SelectorField(
              label: 'City *',
              value: city,
              isSelected: _citySelected,
              hasError: _cityError,
              icon: Icons.location_city_rounded,
              onTap: () async {
                setState(() => _cityTouched = true);
                final result = await showCityBottomSheet(context);
                if (!mounted) return;
                if (result != null) setState(() => city = result);
              },
            ),
            if (_cityError) _ErrorText(text: 'Please select a city'),

            const SizedBox(height: 32),

            // ── Submit button ──
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _submit,
//          onPressed: () async {
//   await ApiService.createProvider({
//     "name": name.text,
//     "email": email.text,
//     "phone": phone.text,
//     "skills": workType,
//     "experience": int.parse(experience.text),
//     "price_per_hour": 0,
//   });

//   Navigator.pushNamed(context, '/provider_dashboard');
// },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kBlue,
                  foregroundColor: _kWhite,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Submit Application',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          fontFamily: 'Poppins',
                          letterSpacing: 0.3,
                        )),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 17),
                  ],
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

// ─────────────────────────────────────────────
// CNIC AUTO-FORMATTER  →  XXXXX-XXXXXXX-X
// ─────────────────────────────────────────────

class CnicInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue newVal) {
    final digits = newVal.text.replaceAll(RegExp(r'[^0-9]'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 13; i++) {
      if (i == 5 || i == 12) buffer.write('-');
      buffer.write(digits[i]);
    }
    final str = buffer.toString();
    return TextEditingValue(
      text: str,
      selection: TextSelection.collapsed(offset: str.length),
    );
  }
}

// ─────────────────────────────────────────────
// SECTION LABEL
// ─────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: _kCyan,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: _kBlue,
              fontFamily: 'Poppins',
            )),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// VALIDATED TEXT FIELD
// ─────────────────────────────────────────────
class _ValidatedField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType keyboardType;
  final String? Function(String?) validator;
  final List<TextInputFormatter>? inputFormatters;

  const _ValidatedField({
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.validator,
    this.keyboardType = TextInputType.text,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kBlue,
              fontFamily: 'Poppins',
            )),
        const SizedBox(height: 5),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          inputFormatters: inputFormatters,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF1A2A3A),
            fontFamily: 'Poppins',
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
                color: _kSubText, fontSize: 13, fontFamily: 'Poppins'),
            prefixIcon: Icon(icon, color: _kBlue, size: 19),
            filled: true,
            fillColor: _kWhite,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kError, width: 1.5),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: _kError, width: 1.8),
            ),
            errorStyle: const TextStyle(
              fontSize: 11,
              fontFamily: 'Poppins',
              color: _kError,
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// SELECTOR FIELD
// ─────────────────────────────────────────────
class _SelectorField extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final bool hasError;
  final IconData icon;
  final VoidCallback onTap;

  const _SelectorField({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.hasError,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _kBlue,
              fontFamily: 'Poppins',
            )),
        const SizedBox(height: 5),
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: _kWhite,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: hasError
                    ? _kError
                    : isSelected
                        ? _kBlue
                        : _kBorder,
                width: isSelected || hasError ? 1.8 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Icon(icon,
                    color: hasError
                        ? _kError
                        : isSelected
                            ? _kBlue
                            : _kSubText,
                    size: 19),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(value,
                      style: TextStyle(
                        fontSize: 14,
                        color: isSelected
                            ? const Color(0xFF1A2A3A)
                            : _kSubText,
                        fontFamily: 'Poppins',
                      )),
                ),
                Icon(Icons.keyboard_arrow_down_rounded,
                    color: hasError
                        ? _kError
                        : isSelected
                            ? _kBlue
                            : _kSubText,
                    size: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// ERROR TEXT
// ─────────────────────────────────────────────
class _ErrorText extends StatelessWidget {
  final String text;
  const _ErrorText({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5, left: 14),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: _kError, size: 13),
          const SizedBox(width: 4),
          Text(text,
              style: const TextStyle(
                fontSize: 11,
                color: _kError,
                fontFamily: 'Poppins',
              )),
        ],
      ),
    );
  }
}

class _ProviderApprovalPendingScreen extends StatefulWidget {
  const _ProviderApprovalPendingScreen({
    required this.email,
    required this.phone,
  });

  final String email;
  final String phone;

  @override
  State<_ProviderApprovalPendingScreen> createState() =>
      _ProviderApprovalPendingScreenState();
}

class _ProviderApprovalPendingScreenState
    extends State<_ProviderApprovalPendingScreen> {
  bool _isChecking = false;

  Future<void> _checkApproval() async {
    if (_isChecking) return;
    setState(() => _isChecking = true);

    try {
      final cleanPhone = widget.phone.replaceAll(RegExp(r'[^0-9]'), '');
      final provider = await ApiService.findProviderByEmailPhone(
        widget.email,
        cleanPhone,
      );

      if (!mounted) return;

      if (provider == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Provider not registered')),
        );
        return;
      }

      final status = (provider['verification_status'] ?? '').toString();
      if (status == 'approved') {
        final prefs = await SharedPreferences.getInstance();
        final providerId = provider['id'];
        if (providerId is int) {
          await prefs.setInt('provider_id', providerId);
        } else if (providerId is String) {
          final parsed = int.tryParse(providerId);
          if (parsed != null) {
            await prefs.setInt('provider_id', parsed);
          }
        }
        await prefs.setString('user_email', widget.email);
        await prefs.setString('user_phone', cleanPhone);
        await prefs.setString('user_name', (provider['name'] ?? '').toString());
        await prefs.setBool('is_logged_in', true);
        await prefs.setBool('is_provider_signed_in', true);
        Navigator.pushReplacementNamed(context, '/provider_dashboard');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Approval is still pending')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Check failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _kBg,
      appBar: AppBar(
        backgroundColor: _kWhite,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Application Status',
          style: TextStyle(
            color: _kBlue,
            fontWeight: FontWeight.w700,
            fontFamily: 'Poppins',
          ),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _kBlue.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.hourglass_top_rounded,
                  color: _kBlue,
                  size: 34,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Waiting for Approval',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: _kBlue,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your application is under review.\nYou will see the dashboard once approved.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: _kSubText,
                  fontFamily: 'Poppins',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: _isChecking ? null : _checkApproval,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kBlue,
                    foregroundColor: _kWhite,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: _isChecking
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(_kWhite),
                          ),
                        )
                      : const Text(
                          'Check Approval',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Poppins',
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}