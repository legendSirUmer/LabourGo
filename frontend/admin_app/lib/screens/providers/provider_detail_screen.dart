import 'package:flutter/material.dart';
import '../../models/provider_model.dart';
import '../../theme/app_theme.dart';

class ProviderDetailScreen extends StatelessWidget {
  final ProviderModel provider;
  const ProviderDetailScreen({super.key, required this.provider});

  @override
  Widget build(BuildContext context) {
    final joinedText = provider.createdAt == null
        ? 'Unknown'
        : provider.createdAt!.toLocal().toString();

    return Scaffold(
      appBar: AppBar(title: Text(provider.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(provider.email, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(provider.phone, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text(
              'Status: ${provider.status}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Joined: $joinedText',
              style: const TextStyle(
                fontSize: 14,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
