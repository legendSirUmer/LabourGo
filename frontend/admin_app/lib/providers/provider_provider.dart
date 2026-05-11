import 'package:flutter/material.dart';
import '../models/provider_model.dart';
import '../services/api_service.dart';

enum LoadingStatus { idle, loading, loaded, error }

class ProviderProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<ProviderModel> _providers = [];
  List<ProviderModel> _filteredProviders = [];
  LoadingStatus _status = LoadingStatus.idle;
  String _errorMessage = '';
  String _searchQuery = '';
  String _statusFilter = 'all';

  // Getters
  List<ProviderModel> get providers => _filteredProviders;
  LoadingStatus get status => _status;
  String get errorMessage => _errorMessage;

  // Stats
  int get totalCount => _providers.length;
  int get approvedCount => _providers.where((p) => p.isApproved).length;
  int get pendingCount => _providers.where((p) => p.isPending).length;
  int get rejectedCount => _providers.where((p) => p.isRejected).length;

  // ─── FETCH PROVIDERS ─────────────────────────────────────
  Future<void> fetchProviders() async {
    _status = LoadingStatus.loading;
    notifyListeners();

    try {
      _providers = await _apiService.getProviders();
      _applyFilters();
      _status = LoadingStatus.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _status = LoadingStatus.error;
    }

    notifyListeners();
  }

  // ─── SEARCH ───────────────────────────────────────────────
  void search(String query) {
    _searchQuery = query.toLowerCase();
    _applyFilters();
    notifyListeners();
  }

  // ─── FILTER BY STATUS ─────────────────────────────────────
  void filterByStatus(String status) {
    _statusFilter = status;
    _applyFilters();
    notifyListeners();
  }

  // ─── APPLY BOTH FILTERS ───────────────────────────────────
  void _applyFilters() {
    _filteredProviders = _providers.where((p) {
      final matchesSearch = _searchQuery.isEmpty ||
          p.name.toLowerCase().contains(_searchQuery) ||
          p.email.toLowerCase().contains(_searchQuery);

      final matchesStatus = _statusFilter == 'all' || p.status == _statusFilter;

      return matchesSearch && matchesStatus;
    }).toList();
  }

  // ─── UPDATE STATUS ────────────────────────────────────────
  Future<bool> updateStatus(int providerId, String newStatus) async {
    final success = await _apiService.updateProviderStatus(
      providerId,
      newStatus,
    );
    if (success) {
      final index = _providers.indexWhere((p) => p.id == providerId);
      if (index != -1) {
        _providers[index] = ProviderModel(
          id: _providers[index].id,
          name: _providers[index].name,
          email: _providers[index].email,
          phone: _providers[index].phone,
          status: newStatus,
          profileImage: _providers[index].profileImage,
          createdAt: _providers[index].createdAt,
        );
        _applyFilters();
        notifyListeners();
      }
    }
    return success;
  }
}
