// lib/models/transaction.dart
class Transaction {
  final String id;
  final String productId;
  final String buyerId;
  final String sellerId;
  final String status;
  final bool active;

  Transaction({
    required this.id,
    required this.productId,
    required this.buyerId,
    required this.sellerId,
    required this.status,
    required this.active,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      productId: json['productId'] ?? '',
      buyerId: json['buyerId'] ?? '',
      sellerId: json['sellerId'] ?? '',
      status: json['status'] ?? 'unknown',
      active: json['active'] ?? false,
    );
  }
}