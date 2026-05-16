import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/user_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/section_title.dart';

class UserDetailScreen extends StatelessWidget {
  final UserModel user;
  const UserDetailScreen({super.key, required this.user});

  Future<void> _toggleBan(BuildContext ctx) async {
    final confirmed = await showDialog<bool>(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(user.isActive ? 'Ban User?' : 'Unban User?'),
        content: Text(
          user.isActive
              ? 'This will prevent ${user.fullName} from using the platform.'
              : 'This will restore ${user.fullName}\'s access.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              user.isActive ? 'Ban' : 'Unban',
              style: TextStyle(
                color: user.isActive
                    ? AppTheme.dangerColor
                    : AppTheme.successColor,
              ),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true && ctx.mounted) {
      await ctx.read<UserProvider>().toggleBan(user.id);
      if (ctx.mounted) Navigator.pop(ctx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(user.fullName)),
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
                      backgroundColor: AppTheme.infoColor.withOpacity(0.1),
                      child: Text(
                        user.fullName[0].toUpperCase(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.infoColor,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          user.role.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
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
                            color: user.isActive
                                ? AppTheme.successColor.withOpacity(0.1)
                                : AppTheme.dangerColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            user.isActive ? 'ACTIVE' : 'BANNED',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: user.isActive
                                  ? AppTheme.successColor
                                  : AppTheme.dangerColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SectionTitle('Contact Info'),
            Card(
              child: Column(
                children: [
                  ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.email_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    title: const Text(
                      'Email',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      user.email,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.phone_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    title: const Text(
                      'Phone',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      user.phone,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.shopping_bag_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    title: const Text(
                      'Bookings',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      '${user.bookingsCount ?? 0}',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  ListTile(
                    dense: true,
                    leading: const Icon(
                      Icons.calendar_today_outlined,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                    title: const Text(
                      'Joined',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    trailing: Text(
                      user.joinedAt?.toString().split(' ')[0] ?? 'N/A',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _toggleBan(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: user.isActive
                    ? AppTheme.dangerColor
                    : AppTheme.successColor,
                minimumSize: const Size(double.infinity, 48),
              ),
              icon: Icon(
                user.isActive ? Icons.block : Icons.check_circle,
                size: 18,
              ),
              label: Text(user.isActive ? 'Ban This User' : 'Unban This User'),
            ),
          ],
        ),
      ),
    );
  }
}
