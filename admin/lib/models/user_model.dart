class UserModel {
  final int id;
  final String fullName;
  final String email;
  final String phone;
  final String role;
  final bool isActive;
  final int? bookingsCount;
  final DateTime? joinedAt;

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.role,
    required this.isActive,
    this.bookingsCount,
    this.joinedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> j) {
    return UserModel(
      id: j['id'] ?? 0,
      fullName: j['full_name'] ?? j['email'] ?? '',
      email: j['email'] ?? '',
      phone: j['phone'] ?? '',
      role: j['role'] ?? 'customer',
      isActive: j['is_active'] ?? true,
      bookingsCount: j['bookings_count'],
      joinedAt: j['joined_at'] != null
          ? DateTime.tryParse(j['joined_at'].toString())
          : null,
    );
  }
}
