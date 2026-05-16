class ProviderModel {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String status;
  final String? skills;
  final String? city;
  final double? rating;
  final int? jobsCount;
  final DateTime? createdAt;
  final String? image;

  ProviderModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.status,
    this.skills,
    this.city,
    this.rating,
    this.jobsCount,
    this.createdAt,
    this.image,
  });

  factory ProviderModel.fromJson(Map<String, dynamic> j) {
    print('>>> PROVIDER JSON: $j');
    return ProviderModel(
      id: j['id'] ?? 0,
      name: j['name'] ?? '',
      email: j['email'] ?? '',
      phone: j['phone'] ?? '',
      status: j['verification_status'] ?? 'pending',
      skills: j['skills']?.toString(),
      city: j['city']?.toString(),
      rating:
          j['rating'] != null ? double.tryParse(j['rating'].toString()) : null,
      jobsCount: j['jobs_count'],
      createdAt: j['created_at'] != null
          ? DateTime.tryParse(j['created_at'].toString())
          : null,
      image: j['image']?.toString(),
    );
  }
}
