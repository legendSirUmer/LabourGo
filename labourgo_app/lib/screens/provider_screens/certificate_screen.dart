import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/api_service.dart';

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

class CertificateScreen extends StatefulWidget {
  const CertificateScreen({super.key});

  @override
  State<CertificateScreen> createState() => _CertificateScreenState();
}

class _CertificateScreenState extends State<CertificateScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _certificateNumberController =
      TextEditingController();
  final TextEditingController _issuingAuthorityController =
      TextEditingController();
  final TextEditingController _issueDateController = TextEditingController();
  final TextEditingController _expiryDateController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _statusText;
  String? _selectedSkill;
  String _selectedFileName = 'No file selected';
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  int? _providerId;

  final List<String> _profileSkills = [];
  final List<Map<String, dynamic>> _certificates = [];

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
    _loadStatus();
  }

  @override
  void dispose() {
    _certificateNumberController.dispose();
    _issuingAuthorityController.dispose();
    _issueDateController.dispose();
    _expiryDateController.dispose();
    _fadeCtrl?.dispose();
    super.dispose();
  }

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
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toSet()
        .toList();
  }

  Map<String, dynamic> _mapCertificate(Map<String, dynamic> data) {
    final status = (data['status'] ?? 'pending').toString();
    final formattedStatus =
        status.isNotEmpty ? '${status[0].toUpperCase()}${status.substring(1)}' : 'Pending';

    return {
      'id': data['id'],
      'skill': (data['skill'] ?? '').toString(),
      'certificateNumber': (data['certificate_number'] ?? '').toString(),
      'issuedBy': (data['issuing_authority'] ?? '').toString(),
      'issueDate': (data['issue_date'] ?? '').toString(),
      'expiryDate': (data['expiration_date'] ?? '').toString(),
      'file': ((data['image'] ?? '').toString().split('/').last),
      'imageUrl': ApiService.resolveImageUrl(data['image']?.toString()),
      'status': formattedStatus,
      'verified': (data['verified'] == true) ? 'Yes' : 'No',
    };
  }

  Future<void> _loadStatus() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final providerId = await _resolveProviderId();
      if (!mounted) return;
      if (providerId == null) {
        setState(() => _error = 'Provider not found');
        _fadeCtrl?.forward(from: 0);
        return;
      }

      final data = await ApiService.getProviderById(providerId);
      final certificates = await ApiService.fetchProviderCertificates(providerId);
      if (!mounted) return;

      final status = (data['verification_status'] ?? '').toString();
      final skills = _parseSkills(data['skills']);

      setState(() {
        _providerId = providerId;
        _statusText = _formatStatus(status);
        _profileSkills
          ..clear()
          ..addAll(skills);
        _certificates
          ..clear()
          ..addAll(certificates.map(_mapCertificate));
        _selectedSkill = _profileSkills.isNotEmpty ? _profileSkills.first : null;
      });
      _fadeCtrl?.forward(from: 0);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'Failed to load verification status');
      _fadeCtrl?.forward(from: 0);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _formatStatus(String status) {
    switch (status) {
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'pending':
        return 'Pending';
      default:
        return 'Not available';
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'approved':
        return const Color(0xFF1FA971);
      case 'rejected':
        return const Color(0xFFE24B4A);
      case 'pending':
        return const Color(0xFFFFAA00);
      default:
        return AppColors.primary;
    }
  }

  Future<void> _pickDate(TextEditingController controller) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked == null || !mounted) return;

    final month = picked.month.toString().padLeft(2, '0');
    final day = picked.day.toString().padLeft(2, '0');
    controller.text = '${picked.year}-$month-$day';
  }

  void _pickFile() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD7E5F2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Upload Certificate Image',
              style: TextStyle(
                fontSize: 15,
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
        maxWidth: 1200,
      );

      if (picked == null || !mounted) return;
      final bytes = await picked.readAsBytes();
      if (!mounted) return;
      setState(() {
        _selectedImageBytes = bytes;
        _selectedFileName = picked.name;
        _selectedImageName = picked.name;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnack('Could not pick image: $e', isError: true);
    }
  }

  Future<void> _saveCertificate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (_selectedSkill == null || _selectedSkill!.isEmpty) {
      _showSnack('Select a skill first', isError: true);
      return;
    }
    if (_selectedImageBytes == null) {
      _showSnack('Please choose a certificate image', isError: true);
      return;
    }
    if (_providerId == null) {
      _showSnack('Provider not found', isError: true);
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      final created = await ApiService.createProviderCertificate(
        _providerId!,
        data: {
          'skill': _selectedSkill!,
          'certificate_number': _certificateNumberController.text.trim(),
          'issuing_authority': _issuingAuthorityController.text.trim(),
          'issue_date': _issueDateController.text.trim(),
          'expiration_date': _expiryDateController.text.trim(),
        },
        imageBytes: _selectedImageBytes!,
        imageName: _selectedImageName,
      );

      if (!mounted) return;

      setState(() {
        _certificates.insert(0, _mapCertificate(created));
        _certificateNumberController.clear();
        _issuingAuthorityController.clear();
        _issueDateController.clear();
        _expiryDateController.clear();
        _selectedFileName = 'No file selected';
        _selectedImageBytes = null;
        _selectedImageName = null;
        if (_profileSkills.isNotEmpty) {
          _selectedSkill = _profileSkills.first;
        }
      });

      _showSnack('Certificate added');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to add certificate: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  Future<void> _deleteCertificate(int index) async {
    final certificate = _certificates[index];
    final certificateId = certificate['id'];
    if (_providerId == null || certificateId is! int) {
      _showSnack('Certificate could not be removed', isError: true);
      return;
    }

    try {
      await ApiService.deleteProviderCertificate(_providerId!, certificateId);
      if (!mounted) return;
      setState(() {
        _certificates.removeAt(index);
      });
      _showSnack('Certificate removed');
    } catch (e) {
      if (!mounted) return;
      _showSnack('Failed to remove certificate: $e', isError: true);
    }
  }

  void _showSnack(String msg, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content:
            Text(msg, style: const TextStyle(color: Colors.white, fontSize: 13)),
        backgroundColor:
            isError ? const Color(0xFFE24B4A) : AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  String? _requiredValidator(String? value, String label) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) return '$label is required';
    return null;
  }

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
                strokeWidth: 2.5,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Loading certificates...',
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
                  _buildStatusCard(),
                  const SizedBox(height: 20),
                  _buildAddCertificateCard(),
                  const SizedBox(height: 20),
                  _buildCertificatesSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _HeaderBtn(
                        icon: Icons.arrow_back_ios_new_rounded,
                        onTap: () => Navigator.maybePop(context),
                      ),
                      const Text(
                        'Certificates',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      _HeaderBtn(
                        icon: Icons.refresh_rounded,
                        onTap: _loadStatus,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.workspace_premium_outlined,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Manage Certificates',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Add your certifications and keep your verification details ready',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.18),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.verified_outlined,
                          color: Colors.white70,
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Verification: ${_statusText ?? 'Not available'}',
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

  Widget _buildStatusCard() {
    final statusColor = _statusColor(_statusText);

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
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.verified_user_outlined,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'VERIFICATION STATUS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                    letterSpacing: 0.08,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusText ?? 'Not available',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E3A5F),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              _statusText ?? 'Unknown',
              style: TextStyle(
                color: statusColor,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCertificateCard() {
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
              'ADD CERTIFICATE',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.08,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedSkill,
              items: _profileSkills
                  .map(
                    (skill) => DropdownMenuItem<String>(
                      value: skill,
                      child: Text(skill),
                    ),
                  )
                  .toList(),
              onChanged: _profileSkills.isEmpty
                  ? null
                  : (value) => setState(() => _selectedSkill = value),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Skill is required' : null,
              decoration: _inputDecoration(
                label: 'Skill Type',
                icon: Icons.handyman_outlined,
                hint: _profileSkills.isEmpty
                    ? 'Add skills in profile first'
                    : 'Select a profile skill',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _certificateNumberController,
              validator: (value) =>
                  _requiredValidator(value, 'Certificate number'),
              decoration: _inputDecoration(
                label: 'Certificate Number',
                icon: Icons.badge_outlined,
                hint: 'Enter certificate number',
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _issuingAuthorityController,
              validator: (value) =>
                  _requiredValidator(value, 'Issuing authority'),
              decoration: _inputDecoration(
                label: 'Issuing Authority',
                icon: Icons.account_balance_outlined,
                hint: 'Enter issuing authority',
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _issueDateController,
                    readOnly: true,
                    onTap: () => _pickDate(_issueDateController),
                    validator: (value) => _requiredValidator(value, 'Issue date'),
                    decoration: _inputDecoration(
                      label: 'Issue Date',
                      icon: Icons.event_outlined,
                      hint: 'Select issue date',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _expiryDateController,
                    readOnly: true,
                    onTap: () => _pickDate(_expiryDateController),
                    validator: (value) =>
                        _requiredValidator(value, 'Expiry date'),
                    decoration: _inputDecoration(
                      label: 'Expiry Date',
                      icon: Icons.event_available_outlined,
                      hint: 'Select expiry date',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F9FF),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _selectedImageBytes != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.memory(
                            _selectedImageBytes!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F2FB),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.image_outlined,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Certificate Image',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A5F),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _selectedFileName,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF8FA8C0),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (_selectedImageBytes == null) ...[
                          const SizedBox(height: 4),
                          const Text(
                            'Choose a clear certificate image',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8FA8C0),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _pickFile,
                    icon: const Icon(Icons.upload_file_rounded, size: 16),
                    label: const Text('Choose'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: _saving || _profileSkills.isEmpty ? null : _saveCertificate,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 50,
                decoration: BoxDecoration(
                  gradient: _saving || _profileSkills.isEmpty
                      ? const LinearGradient(
                          colors: [Color(0xFFB0C4D8), Color(0xFFB0C4D8)],
                        )
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
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.add_card_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Add Certificate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
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
    );
  }

  Widget _buildCertificatesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'MY CERTIFICATES',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
                letterSpacing: 0.08,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F2FB),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${_certificates.length} total',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (_certificates.isEmpty)
          _buildEmptyState()
        else
          ...List.generate(
            _certificates.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _buildCertificateCard(index),
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
            child: const Icon(
              Icons.workspace_premium_outlined,
              color: AppColors.primary,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'No certificates added yet',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A5F),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your uploaded certificates will appear here',
            style: TextStyle(fontSize: 12, color: Color(0xFF8FA8C0)),
          ),
        ],
      ),
    );
  }

  Widget _buildCertificateCard(int index) {
    final certificate = _certificates[index];
    final statusColor = _statusColor(certificate['status']);
    final imageUrl = certificate['imageUrl']?.toString();

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    width: 42,
                    height: 42,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F2FB),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      certificate['skill'] ?? 'Certificate',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E3A5F),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Certificate #${certificate['certificateNumber'] ?? '-'}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF5A7A9A),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _deleteCertificate(index),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  color: Color(0xFFE24B4A),
                  size: 20,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _InfoChip(
                label: 'Issued By',
                value: certificate['issuedBy'] ?? '-',
              ),
              _InfoChip(
                label: 'Issue Date',
                value: certificate['issueDate'] ?? '-',
              ),
              _InfoChip(
                label: 'Expiry',
                value: certificate['expiryDate'] ?? '-',
              ),
              _InfoChip(
                label: 'File',
                value: certificate['file'] ?? '-',
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  certificate['status'] ?? 'Pending',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F2FB),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Verified: ${certificate['verified'] ?? 'No'}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

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

  InputDecoration _inputDecoration({
    required String label,
    required IconData icon,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: AppColors.primary, size: 20),
      filled: true,
      fillColor: const Color(0xFFF5F9FF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE24B4A), width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
      ),
      errorStyle: const TextStyle(fontSize: 11),
    );
  }
}

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
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFD7E5F2),
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
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

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F9FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E3A5F),
            ),
          ),
        ],
      ),
    );
  }
}
