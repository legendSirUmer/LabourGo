import 'package:flutter/material.dart';
import '../../theme/cust_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _darkMode = false;
  bool _locationPermissions = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'App Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    Icons.language_rounded,
                    'Language',
                    trailing: const Text(
                      'English',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildListTile(
                    context,
                    Icons.payments_outlined,
                    'Currency',
                    trailing: const Text(
                      'PKR',
                      style: TextStyle(color: AppColors.textMuted),
                    ),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildSwitchTile(
                    Icons.dark_mode_outlined,
                    'Dark Mode',
                    _darkMode,
                    (val) => setState(() => _darkMode = val),
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildSwitchTile(
                    Icons.location_on_outlined,
                    'Location Permissions',
                    _locationPermissions,
                    (val) => setState(() => _locationPermissions = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),
            const Text(
              'Account & Privacy',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  _buildListTile(
                    context,
                    Icons.credit_card_rounded,
                    'Payment Methods',
                    showArrow: true,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildListTile(
                    context,
                    Icons.work_outline_rounded,
                    'Become a Provider',
                    showArrow: true,
                    onTap: () {
                      Navigator.pushNamed(context, '/provider_intro');
                    },
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildListTile(
                    context,
                    Icons.privacy_tip_outlined,
                    'Privacy Policy',
                    showArrow: true,
                  ),
                  const Divider(height: 1, indent: 56, endIndent: 16),
                  _buildListTile(
                    context,
                    Icons.description_outlined,
                    'Terms of Service',
                    showArrow: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: const Text(
                        'Delete Account',
                        style: TextStyle(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                        'Are you sure you want to permanently delete your account? This action cannot be undone.',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(color: AppColors.textMuted),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Account deletion requested.'),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text('Delete'),
                        ),
                      ],
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: BorderSide(
                    color: AppColors.error.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Delete Account',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile(
    BuildContext context,
    IconData icon,
    String title, {
    Widget? trailing,
    bool showArrow = false,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      trailing:
          trailing ??
          (showArrow
              ? const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.textMuted,
                )
              : null),
      onTap:
          onTap ??
          () {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$title tapped!')));
          },
    );
  }

  Widget _buildSwitchTile(
    IconData icon,
    String title,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return SwitchListTile(
      secondary: Icon(icon, color: AppColors.primary, size: 24),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      value: value,
      activeThumbColor: AppColors.primary,
      onChanged: onChanged,
    );
  }
}
