import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/provider_model.dart';
import 'provider_detail_screen.dart';

class ProvidersListScreen extends StatefulWidget {
  const ProvidersListScreen({super.key});

  @override
  State<ProvidersListScreen> createState() => _ProvidersListScreenState();
}

class _ProvidersListScreenState extends State<ProvidersListScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Fetch providers when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<ProviderProvider>().fetchProviders();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerProv = context.watch<ProviderProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers Management'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<ProviderProvider>().fetchProviders(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search + Filter Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: 'Search providers...',
                    prefixIcon: Icon(Icons.search),
                    isDense: true,
                  ),
                  onChanged: (val) {
                    context.read<ProviderProvider>().search(val);
                  },
                ),
                const SizedBox(height: 10),

                // Filter chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      'all',
                      'approved',
                      'pending',
                      'rejected',
                    ].map((status) => _StatusChip(status: status)).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Stats Row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _MiniStat(
                  'Total',
                  providerProv.totalCount,
                  AppTheme.primaryColor,
                ),
                _MiniStat(
                  'Approved',
                  providerProv.approvedCount,
                  AppTheme.successColor,
                ),
                _MiniStat(
                  'Pending',
                  providerProv.pendingCount,
                  AppTheme.warningColor,
                ),
                _MiniStat(
                  'Rejected',
                  providerProv.rejectedCount,
                  AppTheme.dangerColor,
                ),
              ],
            ),
          ),

          // Content
          Expanded(child: _buildContent(providerProv)),
        ],
      ),
    );
  }

  Widget _buildContent(ProviderProvider providerProv) {
    switch (providerProv.status) {
      case LoadingStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case LoadingStatus.error:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.dangerColor,
              ),
              const SizedBox(height: 16),
              Text(providerProv.errorMessage),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<ProviderProvider>().fetchProviders(),
                child: const Text('Retry'),
              ),
            ],
          ),
        );

      case LoadingStatus.loaded:
      case LoadingStatus.idle:
        if (providerProv.providers.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.search_off, size: 64, color: AppTheme.textSecondary),
                SizedBox(height: 16),
                Text('No providers found'),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: providerProv.providers.length,
          itemBuilder: (context, index) {
            return _ProviderCard(provider: providerProv.providers[index]);
          },
        );
    }
  }
}

// ─── Provider Card Widget ─────────────────────────────────
class _ProviderCard extends StatelessWidget {
  final ProviderModel provider;
  const _ProviderCard({required this.provider});

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

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProviderDetailScreen(provider: provider),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
                child: Text(
                  provider.name.isNotEmpty
                      ? provider.name[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      provider.email,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    Text(
                      provider.phone,
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                  border:
                      Border.all(color: _statusColor.withValues(alpha: 0.4)),
                ),
                child: Text(
                  provider.status.toUpperCase(),
                  style: TextStyle(
                    color: _statusColor,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
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

// ─── Status Filter Chip ───────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          status == 'all'
              ? 'All'
              : '${status[0].toUpperCase()}${status.substring(1)}',
        ),
        selected: false,
        onSelected: (_) =>
            context.read<ProviderProvider>().filterByStatus(status),
      ),
    );
  }
}

// ─── Mini Stat Widget ─────────────────────────────────────
class _MiniStat extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _MiniStat(this.label, this.count, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
          ),
        ],
      ),
    );
  }
}
