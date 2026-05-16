import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/provider_model.dart';
import '../../providers/provider_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_title.dart';

class ProviderDetailScreen extends StatelessWidget {
  final ProviderModel provider;
  const ProviderDetailScreen({super.key, required this.provider});

  Color get _statusColor {
    switch (provider.status) {
      case 'approved':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'rejected':
        return AppTheme.dangerColor;
      default:
        return AppTheme.textSecondary;
    }
  }

  Future<void> _updateStatus(BuildContext ctx, String newStatus) async {
    final ok = await ctx.read<ProviderProvider>().updateStatus(
      provider.id,
      newStatus,
    );
    if (ctx.mounted) {
      ScaffoldMessenger.of(ctx).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Status updated to $newStatus' : 'Failed to update',
          ),
          backgroundColor: ok ? AppTheme.successColor : AppTheme.dangerColor,
        ),
      );
      if (ok) Navigator.pop(ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(provider.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                      child: Text(
                        provider.name[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            provider.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            provider.email,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          Text(
                            provider.phone,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: _statusColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              provider.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                color: _statusColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionTitle('Details'),
            Card(
              child: Column(
                children: [
                  _infoTile(
                    'City',
                    provider.city ?? 'N/A',
                    Icons.location_on_outlined,
                  ),
                  _infoTile(
                    'Skills',
                    provider.skills ?? 'N/A',
                    Icons.build_outlined,
                  ),
                  _infoTile(
                    'Rating',
                    provider.rating != null ? '${provider.rating} ★' : 'N/A',
                    Icons.star_outline,
                  ),
                  _infoTile(
                    'Jobs Done',
                    '${provider.jobsCount ?? 0}',
                    Icons.work_outline,
                  ),
                  _infoTile(
                    'Joined',
                    provider.createdAt?.toLocal().toString().split(' ')[0] ??
                        'N/A',
                    Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionTitle('Actions'),
            Row(
              children: [
                if (provider.status != 'approved')
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successColor,
                          minimumSize: const Size(0, 44),
                        ),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Approve'),
                        onPressed: () => _updateStatus(context, 'approved'),
                      ),
                    ),
                  ),
                if (provider.status != 'rejected')
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.dangerColor,
                          minimumSize: const Size(0, 44),
                        ),
                        icon: const Icon(Icons.close, size: 16),
                        label: const Text('Reject'),
                        onPressed: () => _updateStatus(context, 'rejected'),
                      ),
                    ),
                  ),
              ],
            ),
            if (provider.status != 'suspended')
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade700,
                    minimumSize: const Size(double.infinity, 44),
                  ),
                  icon: const Icon(Icons.block, size: 16),
                  label: const Text('Suspend Provider'),
                  onPressed: () => _updateStatus(context, 'suspended'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoTile(String label, String value, IconData icon) {
    return ListTile(
      dense: true,
      leading: Icon(icon, size: 18, color: AppTheme.textSecondary),
      title: Text(
        label,
        style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary),
      ),
      trailing: Text(
        value,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
      ),
    );
  }
}
