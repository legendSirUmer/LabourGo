class ReviewModel {
  final int id;
  final String userName;
  final String providerName;
  final double rating;
  final String comment;
  final DateTime? createdAt;
  final String status; // approved / flagged / pending

  ReviewModel({
    required this.id,
    required this.userName,
    required this.providerName,
    required this.rating,
    required this.comment,
    this.createdAt,
    required this.status,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> j) => ReviewModel(
    id: j['id'],
    userName: j['user_name'] ?? '',
    providerName: j['provider_name'] ?? '',
    rating: (j['rating']?.toDouble() ?? 0),
    comment: j['comment'] ?? '',
    createdAt: j['created_at'] != null
        ? DateTime.tryParse(j['created_at'])
        : null,
    status: j['status'] ?? 'pending',
  );
}
