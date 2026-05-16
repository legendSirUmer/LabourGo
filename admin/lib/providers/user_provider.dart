import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';

enum LoadingStatus { idle, loading, loaded, error }

class UserProvider extends ChangeNotifier {
  LoadingStatus status = LoadingStatus.idle;
  String errorMessage = '';
  List<UserModel> _all = [];
  List<UserModel> users = [];
  String _searchQuery = '';

  int get totalCount => _all.length;
  int get activeCount => _all.where((u) => u.isActive).length;
  int get inactiveCount => _all.where((u) => !u.isActive).length;

  Future<void> fetchUsers() async {
    status = LoadingStatus.loading;
    notifyListeners();
    try {
      final data = await ApiService.getUsers();
      print('>>> FETCHED ${data.length} users');
      _all = data.map((j) => UserModel.fromJson(j)).toList();
      _applySearch();
      status = LoadingStatus.loaded;
    } catch (e) {
      print('>>> USER ERROR: $e');
      errorMessage = 'Failed to load users: $e';
      status = LoadingStatus.error;
    }
    notifyListeners();
  }

  void search(String q) {
    _searchQuery = q.toLowerCase();
    _applySearch();
    notifyListeners();
  }

  void _applySearch() {
    users = _searchQuery.isEmpty
        ? List.from(_all)
        : _all
            .where((u) =>
                u.fullName.toLowerCase().contains(_searchQuery) ||
                u.email.toLowerCase().contains(_searchQuery))
            .toList();
  }

  Future<bool> toggleBan(int id) async {
    final ok = await ApiService.toggleUserBan(id);
    if (ok) await fetchUsers();
    return ok;
  }
}
