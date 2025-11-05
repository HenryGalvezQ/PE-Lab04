class Chat {
  final String id;
  final String productId;
  final String productTitle;
  final String productImageUrl;
  final double productPrice;
  final List<String> participantIds;
  final String sellerId;
  final String buyerId;
  final String lastMessage;
  final DateTime? lastMessageTimestamp;

  Chat({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImageUrl,
    required this.productPrice,
    required this.participantIds,
    required this.sellerId,
    required this.buyerId,
    required this.lastMessage,
    required this.lastMessageTimestamp,
  });

  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
    id: json['id'] ?? '',
    productId: json['productId'] ?? '',
    productTitle: json['productTitle'] ?? '',
    productImageUrl: json['productImageUrl'] ?? '',
    productPrice: (json['productPrice'] as num?)?.toDouble() ?? 0.0,
    participantIds:
        (json['participantIds'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [],
    sellerId: json['sellerId'] ?? '',
    buyerId: json['buyerId'] ?? '',
    lastMessage: json['lastMessage'] ?? '',
    lastMessageTimestamp: json['lastMessageTimestamp'] != null
        ? DateTime.tryParse(json['lastMessageTimestamp'].toString())
        : null,
  );
}
