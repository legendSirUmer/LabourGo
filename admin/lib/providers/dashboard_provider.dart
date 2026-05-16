import 'package:flutter/material.dart';
import '../services/api_service.dart';

class DashboardProvider extends ChangeNotifier {
  bool isLoading = false;
  Map<String, dynamic> _stats = {};

  int get totalProviders => (_stats['total_providers'] ?? 0) as int;
  int get activeUsers => (_stats['active_users'] ?? 0) as int;
  int get totalUsers => (_stats['total_users'] ?? 0) as int;
  int get pendingProviders => (_stats['pending_providers'] ?? 0) as int;
  int get totalBookings => (_stats['total_bookings'] ?? 0) as int;
  int get completedBookings => (_stats['completed_bookings'] ?? 0) as int;
  double get totalRevenue =>
      double.tryParse(_stats['total_revenue']?.toString() ?? '0') ?? 0;

  String get revenueFormatted {
    if (totalRevenue >= 1000)
      return 'PKR ${(totalRevenue / 1000).toStringAsFixed(0)}K';
    return 'PKR ${totalRevenue.toStringAsFixed(0)}';
  }

  Future<void> fetchStats() async {
    isLoading = true;
    notifyListeners();
    try {
      final data = await ApiService.getDashboardStats();
      print('>>> DASHBOARD STATS: $data');
      if (data.isNotEmpty) _stats = data;
    } catch (e) {
      print('>>> STATS ERROR: $e');
    }
    isLoading = false;
    notifyListeners();
  }
}
