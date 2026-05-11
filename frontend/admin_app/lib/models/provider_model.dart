class ProviderModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String? profileImage;
  final DateTime? createdAt;

  ProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.profileImage,
    this.createdAt,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> json) {
    return ProviderModel(
      id: _readInt(json['id']),
      name: _readString(
        json['name'] ?? json['full_name'],
        fallback: 'Unknown Provider',
      ),
      email: _readString(json['email']),
      phone: _readString(json['phone']),
      status: _readString(
        json['verification_status'] ?? json['status'],
        fallback: 'pending',
      ),
      profileImage: _readNullableString(
        json['image'] ?? json['profile_image'] ?? json['profile_pic'],
      ),
      createdAt: _readDate(json['created_at']),
    );
  }

  bool get isApproved => status == 'approved';
  bool get isPending => status == 'pending';
  bool get isRejected => status == 'rejected';

  static int _readInt(Object? value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _readString(Object? value, {String fallback = ''}) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? fallback : text;
  }

  static String? _readNullableString(Object? value) {
    final text = value?.toString().trim();
    return text == null || text.isEmpty ? null : text;
  }

  static DateTime? _readDate(Object? value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }
}
