import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import '../services/api_service.dart';

enum LoadingStatus { idle, loading, loaded, error }

class ProviderProvider extends ChangeNotifier {
  LoadingStatus status = LoadingStatus.idle;
  String errorMessage = '';
  List<ProviderModel> _all = [];
  List<ProviderModel> providers = [];
  String _currentFilter = 'all';
  String _searchQuery = '';

  int get totalCount => _all.length;
  int get approvedCount => _all.where((p) => p.status == 'approved').length;
  int get pendingCount => _all.where((p) => p.status == 'pending').length;
  int get rejectedCount => _all.where((p) => p.status == 'rejected').length;

  Future<void> fetchProviders() async {
    status = LoadingStatus.loading;
    notifyListeners();
    try {
      final data = await ApiService.getProviders();
      print('>>> FETCHED ${data.length} providers');
      _all = data.map((j) => ProviderModel.fromJson(j)).toList();
      _applyFilters();
      status = LoadingStatus.loaded;
    } catch (e) {
      print('>>> PROVIDER ERROR: $e');
      errorMessage = 'Failed to load providers: $e';
      status = LoadingStatus.error;
    }
    notifyListeners();
  }

  void filterByStatus(String s) {
    _currentFilter = s;
    _applyFilters();
    notifyListeners();
  }

  void search(String q) {
    _searchQuery = q.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    providers = _all.where((p) {
      final matchStatus = _currentFilter == 'all' || p.status == _currentFilter;
      final matchSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery) ||
          p.email.toLowerCase().contains(_searchQuery);
      return matchStatus && matchSearch;
    }).toList();
  }

  Future<bool> updateStatus(int id, String newStatus) async {
    final ok = await ApiService.updateProviderStatus(id, newStatus);
    if (ok) await fetchProviders();
    return ok;
  }
}
