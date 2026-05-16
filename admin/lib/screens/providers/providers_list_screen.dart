import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/provider_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/empty_state.dart';
import 'provider_detail_screen.dart';

class ProvidersListScreen extends StatefulWidget {
  const ProvidersListScreen({super.key});
  @override
  State<ProvidersListScreen> createState() => _State();
}

class _State extends State<ProvidersListScreen> {
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProviderProvider>().fetchProviders();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Color _statusColor(String s) {
    switch (s) {
      case 'approved':
        return AppTheme.successColor;
      case 'pending':
        return AppTheme.warningColor;
      case 'rejected':
        return AppTheme.dangerColor;
      case 'suspended':
        return Colors.grey;
      default:
        return AppTheme.textSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<ProviderProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Providers Management'),
        actions: [
          IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () =>
                  context.read<ProviderProvider>().fetchProviders()),
        ],
      ),
      body: Column(children: [
        Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Column(children: [
            TextField(
              controller: _search,
              decoration: InputDecoration(
                hintText: 'Search providers...',
                hintStyle: const TextStyle(fontSize: 13),
                prefixIcon: const Icon(Icons.search, size: 20),
                isDense: true,
                suffixIcon: _search.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _search.clear();
                          context.read<ProviderProvider>().search('');
                        })
                    : null,
              ),
              onChanged: (v) => context.read<ProviderProvider>().search(v),
            ),
            const SizedBox(height: 10),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  'all',
                  'approved',
                  'pending',
                  'rejected',
                  'suspended'
                ].map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: FilterChip(
                      label: Text(
                          s == 'all'
                              ? 'All'
                              : '${s[0].toUpperCase()}${s.substring(1)}',
                          style: const TextStyle(fontSize: 11)),
                      selected: false,
                      onSelected: (_) =>
                          context.read<ProviderProvider>().filterByStatus(s),
                    ),
                  );
                }).toList(),
              ),
            ),
          ]),
        ),
        // Mini stats bar
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(children: [
            _miniStat('Total', prov.totalCount, AppTheme.primaryColor),
            _miniStat('Approved', prov.approvedCount, AppTheme.successColor),
            _miniStat('Pending', prov.pendingCount, AppTheme.warningColor),
            _miniStat('Rejected', prov.rejectedCount, AppTheme.dangerColor),
          ]),
        ),
        const Divider(height: 1),
        Expanded(child: _buildContent(prov)),
      ]),
    );
  }

  Widget _miniStat(String label, int count, Color color) {
    return Expanded(
        child: Column(children: [
      Text('$count',
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: color)),
      Text(label,
          style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
    ]));
  }

  Widget _buildContent(ProviderProvider prov) {
    if (prov.status == LoadingStatus.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (prov.status == LoadingStatus.error) {
      return Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Icon(Icons.error_outline, size: 48, color: AppTheme.dangerColor),
        const SizedBox(height: 12),
        Text(prov.errorMessage),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => context.read<ProviderProvider>().fetchProviders(),
          style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
          child: const Text('Retry'),
        ),
      ]));
    }
    if (prov.providers.isEmpty)
      return const EmptyState(message: 'No providers found');

    return RefreshIndicator(
      onRefresh: () => context.read<ProviderProvider>().fetchProviders(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: prov.providers.length,
        itemBuilder: (ctx, i) {
          final p = prov.providers[i];
          final color = _statusColor(p.status);
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.push(
                  ctx,
                  MaterialPageRoute(
                      builder: (_) => ProviderDetailScreen(provider: p))),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                    child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryColor)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                        Text(p.name,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 14)),
                        Text(p.email,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                        Text(p.phone,
                            style: const TextStyle(
                                fontSize: 11, color: AppTheme.textSecondary)),
                      ])),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: color.withOpacity(0.3)),
                    ),
                    child: Text(p.status.toUpperCase(),
                        style: TextStyle(
                            fontSize: 9,
                            color: color,
                            fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }
}
