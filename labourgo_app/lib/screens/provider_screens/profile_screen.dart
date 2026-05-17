import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/api_service.dart';
import '../../widgets/provider_bottom_navigation.dart';

// --------------------------------------------
// App Colors
// --------------------------------------------
class AppColors {
  static const primary = Color(0xFF4682B4);
  static const accent = Color(0xFF5CE1E6);
  static const background = Color(0xFFF0F4F8);

  static const primaryGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

// --------------------------------------------
// ProfileScreen - same logic, new UI
// --------------------------------------------
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final skillsController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _loading = true;
  bool _saving = false;
  bool _imageUploading = false;
  bool _availabilitySaving = false;
  String? _error;
  String? _imageUrl;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  int? _providerId;
  bool _isAvailable = false;

  AnimationController? _fadeCtrl;
  Animation<double>? _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl!, curve: Curves.easeOut);
    _loadProfile();
  }

  @override
  void dispose() {
    nameController.dispose();
    skillsController.dispose();
    phoneController.dispose();
    emailController.dispose();
    _fadeCtrl?.dispose();
    super.dispose();
  }

  // ------------------------------------------
  // Original logic (unchanged)
  // ------------------------------------------
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

  Future<void> _loadProfile() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final providerId = await _resolveProviderId();
      if (providerId == null) {
        setState(() => _error = 'Provider not found. Please sign in again.');
        return;
      }
      final data = await ApiService.getProviderById(providerId);
      if (!mounted) return;
      setState(() {
        _providerId = providerId;
        nameController.text = (data['name'] ?? '').toString();
        skillsController.text = (data['skills'] ?? '').toString();
        phoneController.text = (data['phone'] ?? '').toString();
        emailController.text = (data['email'] ?? '').toString();
        _imageUrl = ApiService.resolveImageUrl(data['image']?.toString());
        _selectedImageBytes = null;
        _selectedImageName = null;
        _isAvailable = _parseAvailability(data['availability']);
      });
      _fadeCtrl?.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load profile');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _updateProfile() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_providerId == null) {
      _showSnack('Provider not found', isError: true);
      return;
    }
    setState(() => _saving = true);
    try {
      final cleanPhone = phoneController.text.trim().replaceAll(
        RegExp(r'[^0-9]'),
        '',
      );
      await ApiService.updateProvider(_providerId!, {
        'name': nameController.text.trim(),
        'skills': skillsController.text.trim(),
        'phone': cleanPhone,
        'email': emailController.text.trim(),
      });
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_email', emailController.text.trim());
      await prefs.setString('user_phone', cleanPhone);
      await prefs.setString('user_name', nameController.text.trim());
      if (!mounted) return;
      _showSnack('Profile updated successfully');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to update profile: $e', isError: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ------------------------------------------
  // Original validators (unchanged)
  // ------------------------------------------
  String? _validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Full name is required';
    if (text.length < 3) return 'Name must be at least 3 characters';
    return null;
  }

  String? _validateSkills(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Skills are required';
    if (text.length < 2) return 'Please enter valid skills';
    return null;
  }

  String? _validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Phone number is required';
    final clean = text.replaceAll(RegExp(r'[^0-9]'), '');
    if (!RegExp(r'^03[0-9]{9}$').hasMatch(clean)) {
      return 'Enter a valid Pakistani number';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return 'Email is required';
    if (!RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$').hasMatch(text)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  bool _parseAvailability(dynamic value) {
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is num) return value != 0;
    return false;
  }

  // ------------------------------------------
  // UI helpers
  // ------------------------------------------
  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          msg,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        backgroundColor: isError ? const Color(0xFFE24B4A) : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD0E3F5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Update Profile Photo',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ImageSourceTile(
                    icon: Icons.photo_camera_rounded,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.camera);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ImageSourceTile(
                    icon: Icons.photo_library_rounded,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      _pickImage(ImageSource.gallery);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picked = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 900,
      );

      if (picked == null) return;
      final file = File(picked.path);

      setState(() => _selectedImageName = file.path.split('/').last);
      await _uploadImage(file);
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not pick image: $e', isError: true);
    }
  }

  Future<void> _uploadImage(File file) async {
    if (_providerId == null) {
      _showSnack('Provider not found', isError: true);
      return;
    }

    setState(() => _imageUploading = true);
    try {
      final data = await ApiService.updateProviderImage(_providerId!, file);
      final updatedPath = data['image']?.toString();
      final resolved = ApiService.resolveImageUrl(updatedPath);

      setState(() {
        if (resolved != null && resolved.isNotEmpty) {
          _imageUrl = resolved;
          _selectedImageName = null;
        }
      });

      _showSnack('Profile photo updated');
    } catch (e) {
      _showSnack('Failed to update photo: $e', isError: true);
    } finally {
      if (mounted) setState(() => _imageUploading = false);
    }
  }

  Future<void> _toggleAvailability(bool value) async {
    if (_availabilitySaving) return;
    if (_providerId == null) {
      _showSnack('Provider not found', isError: true);
      return;
    }

    final previous = _isAvailable;
    setState(() {
      _availabilitySaving = true;
      _isAvailable = value;
    });

    try {
      final data = await ApiService.toggleAvailability(_providerId!);
      final updated = _parseAvailability(data['availability']);
      setState(() => _isAvailable = updated);
    } catch (e) {
      if (mounted) {
        setState(() => _isAvailable = previous);
      }
      _showSnack('Failed to update availability: $e', isError: true);
    } finally {
      if (mounted) setState(() => _availabilitySaving = false);
    }
  }

  String _initials() {
    final name = nameController.text.trim();
    if (name.isEmpty) return '?';
    return name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() : '')
        .join();
  }

  // ------------------------------------------
  // Build
  // ------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          final velocity = details.primaryVelocity ?? 0;
          // Swipe left -> Bookings
          if (velocity < -300) {
            Navigator.pushNamed(context, '/view-bookings');
          }
          // Swipe right -> Dashboard
          else if (velocity > 300) {
            Navigator.pushNamed(context, '/provider_dashboard');
          }
        },
        child: _loading ? _buildLoader() : _buildContent(),
      ),
      bottomNavigationBar: ProviderBottomNavigation(
        currentIndex: 1,
        onTap: (index) {
          if (index == 1) return;
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/provider_dashboard');
              break;
            case 2:
              Navigator.pushNamed(context, '/view-bookings');
              break;
            case 3:
              Navigator.pushNamed(context, '/home');
              break;
          }
        },
      ),
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
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading profile...',
            style: TextStyle(color: AppColors.primary, fontSize: 13),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final fadeAnim = _fadeAnim ?? const AlwaysStoppedAnimation(1.0);

    return FadeTransition(
      opacity: fadeAnim,
      child: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeroHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
                child: Column(
                  children: [
                    if (_error != null) _buildErrorBanner(),
                    _FormCard(
                      label: 'Personal Info',
                      children: [
                        _FieldRow(
                          iconBg: const Color(0xFFE8F2FB),
                          icon: Icons.person_outline_rounded,
                          iconColor: AppColors.primary,
                          label: 'Full Name',
                          child: TextFormField(
                            controller: nameController,
                            onChanged: (_) => setState(() {}),
                            validator: _validateName,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: _fieldTextStyle,
                            decoration: _fieldDeco('e.g. Zain Ali'),
                          ),
                        ),
                        _divider(),
                        _FieldRow(
                          iconBg: const Color(0xFFE0F8F9),
                          icon: Icons.phone_outlined,
                          iconColor: const Color(0xFF2AB0BC),
                          label: 'Phone',
                          child: TextFormField(
                            controller: phoneController,
                            keyboardType: TextInputType.phone,
                            validator: _validatePhone,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: _fieldTextStyle,
                            decoration: _fieldDeco('03XXXXXXXXX'),
                          ),
                        ),
                        _divider(),
                        _FieldRow(
                          iconBg: const Color(0xFFFFF0E6),
                          icon: Icons.email_outlined,
                          iconColor: const Color(0xFFE07B30),
                          label: 'Email',
                          child: TextFormField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: _fieldTextStyle,
                            decoration: _fieldDeco('you@example.com'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      label: 'Skills & Services',
                      children: [
                        _FieldRow(
                          iconBg: const Color(0xFFEEF2FF),
                          icon: Icons.construction_outlined,
                          iconColor: const Color(0xFF6366F1),
                          label: 'Skills',
                          child: TextFormField(
                            controller: skillsController,
                            validator: _validateSkills,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            style: _fieldTextStyle,
                            decoration: _fieldDeco(
                              'e.g. Painter, Interior Design',
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.only(left: 52),
                          child: Text(
                            'Separate multiple skills with commas',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _FormCard(
                      label: 'Availability',
                      children: [
                        _FieldRow(
                          iconBg: const Color(0xFFE8F2FB),
                          icon: Icons.schedule_rounded,
                          iconColor: AppColors.primary,
                          label: 'Available for jobs',
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _isAvailable ? 'Available' : 'Unavailable',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF1E3A5F),
                                ),
                              ),
                              Switch(
                                value: _isAvailable,
                                onChanged: _availabilitySaving
                                    ? null
                                    : _toggleAvailability,
                                activeColor: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                        if (_availabilitySaving)
                          const Padding(
                            padding: EdgeInsets.only(left: 52, top: 6),
                            child: Text(
                              'Updating availability...',
                              style: TextStyle(
                                fontSize: 11,
                                color: Color(0xFF7A94B2),
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildUpdateButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ------------------------------------------
  // Hero header
  // ------------------------------------------
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
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
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
                        'My Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _HeaderBtn(
                        icon: Icons.refresh_rounded,
                        onTap: _loadProfile,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Avatar
                  GestureDetector(
                    onTap: _showImageSourceSheet,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 92,
                          height: 92,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.5),
                              width: 3,
                            ),
                          ),
                          child: ClipOval(child: _buildAvatar()),
                        ),
                        if (_imageUploading)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.35),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 2,
                          right: 2,
                          child: Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.8),
                                width: 1.5,
                              ),
                            ),
                            child: const Icon(
                              Icons.camera_alt_rounded,
                              color: AppColors.primary,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Live name from controller
                  Text(
                    nameController.text.isEmpty
                        ? 'Your Name'
                        : nameController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),

                  // Skills preview
                  if (skillsController.text.isNotEmpty)
                    Text(
                      skillsController.text,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                  const SizedBox(height: 14),

                  // Email pill
                  if (emailController.text.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.email_outlined,
                            color: Colors.white70,
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            emailController.text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
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

  Widget _buildAvatar() {
    if (_selectedImageBytes != null) {
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
        width: 92,
        height: 92,
      );
    }
    if (_imageUrl != null && _imageUrl!.isNotEmpty) {
      return Image.network(
        _imageUrl!,
        fit: BoxFit.cover,
        width: 92,
        height: 92,
        errorBuilder: (_, __, ___) => _initialsAvatar(),
      );
    }
    return _initialsAvatar();
  }

  Widget _initialsAvatar() => Container(
    color: const Color(0xFFD0E8F5),
    alignment: Alignment.center,
    child: Text(
      _initials(),
      style: const TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: AppColors.primary,
      ),
    ),
  );

  // ------------------------------------------
  // Error banner
  // ------------------------------------------
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
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFE24B4A),
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFA32D2D),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------------------------------
  // Update button
  // ------------------------------------------
  Widget _buildUpdateButton() {
    return GestureDetector(
      onTap: _saving ? null : _updateProfile,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 54,
        decoration: BoxDecoration(
          gradient: _saving
              ? const LinearGradient(
                  colors: [Color(0xFFB0C4D8), Color(0xFFB0C4D8)],
                )
              : AppColors.primaryGradient,
          borderRadius: BorderRadius.circular(18),
          boxShadow: _saving
              ? []
              : [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: _saving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_rounded, color: Colors.white, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Update Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ------------------------------------------
  // Shared styles
  // ------------------------------------------
  static const _fieldTextStyle = TextStyle(
    fontSize: 14,
    color: Color(0xFF1E3A5F),
    fontWeight: FontWeight.w500,
  );

  InputDecoration _fieldDeco(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFFAAC4D8), fontSize: 13),
    isDense: true,
    contentPadding: const EdgeInsets.only(bottom: 6, top: 2),
    border: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFD0E3F5), width: 1.5),
    ),
    enabledBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFD0E3F5), width: 1.5),
    ),
    focusedBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: AppColors.primary, width: 1.5),
    ),
    errorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE24B4A), width: 1.5),
    ),
    focusedErrorBorder: const UnderlineInputBorder(
      borderSide: BorderSide(color: Color(0xFFE24B4A), width: 1.5),
    ),
    errorStyle: const TextStyle(fontSize: 11),
  );

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(vertical: 10),
    child: Divider(height: 1, color: Color(0xFFEDF3F9)),
  );
}

// --------------------------------------------
// Reusable widgets
// --------------------------------------------
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

class _FormCard extends StatelessWidget {
  final String label;
  final List<Widget> children;
  const _FormCard({required this.label, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.08,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _FieldRow extends StatelessWidget {
  final Color iconBg;
  final IconData icon;
  final Color iconColor;
  final String label;
  final Widget child;

  const _FieldRow({
    required this.iconBg,
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  color: Color(0xFF8FA8C0),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.05,
                ),
              ),
              child,
            ],
          ),
        ),
      ],
    );
  }
}

class _ImageSourceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ImageSourceTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF4F8FD),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD0E3F5), width: 1.2),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
