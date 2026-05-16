class PaymentModel {
  final int id;
  final String customerEmail;
  final double amount;
  final String method;
  final String status;   // paid / pending / refunded
  final String? transactionId;
  final DateTime? createdAt;

  PaymentModel({
    required this.id,
    required this.customerEmail,
    required this.amount,
    required this.method,
    required this.status,
    this.transactionId,
    this.createdAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> j) => PaymentModel(
    id:            j['id'],
    customerEmail: j['customer_email'] ?? '',
    amount:        j['amount']?.toDouble() ?? 0,
    method:        j['method'] ?? '',
    status:        j['status'] ?? 'pending',
    transactionId: j['transaction_id'],
    createdAt:     j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
  );
}