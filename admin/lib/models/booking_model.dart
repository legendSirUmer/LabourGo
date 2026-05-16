class BookingModel {
  final int id;
  final String customerEmail;
  final String providerEmail;
  final String category;
  final String status; // pending / confirmed / completed / cancelled
  final String? scheduledDate;
  final double? amount;

  BookingModel({
    required this.id,
    required this.customerEmail,
    required this.providerEmail,
    required this.category,
    required this.status,
    this.scheduledDate,
    this.amount,
  });

  factory BookingModel.fromJson(Map<String, dynamic> j) => BookingModel(
    id: j['id'],
    customerEmail: j['customer_email'] ?? '',
    providerEmail: j['provider_email'] ?? '',
    category: j['category'] ?? '',
    status: j['status'] ?? 'pending',
    scheduledDate: j['scheduled_date'],
    amount: j['amount']?.toDouble(),
  );
}
