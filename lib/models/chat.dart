// lib/models/chat.dart
import 'package:cloud_firestore/cloud_firestore.dart'; // <-- AÑADE ESTO

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

  // Este factory se usa para la respuesta de la API REST (ChatService)
  factory Chat.fromJson(Map<String, dynamic> json) => Chat(
        id: json['id'] ?? '',
        productId: json['productId'] ?? '',
        productTitle: json['productTitle'] ?? '',
        productImageUrl: json['productImageUrl'] ?? '',
        productPrice: (json['productPrice'] as num?)?.toDouble() ?? 0.0,
        participantIds: (json['participantIds'] as List<dynamic>?)
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

  // --- AÑADE ESTE NUEVO FACTORY ---
  // Este factory se usa para leer los datos desde Firestore
  factory Chat.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['lastMessageTimestamp'];
    DateTime? lastTime;
    if (ts is Timestamp) {
      lastTime = ts.toDate();
    } else if (ts is String) {
      lastTime = DateTime.tryParse(ts);
    }

    return Chat(
      id: doc.id, // El ID viene del documento, no de los datos
      productId: data['productId'] ?? '',
      productTitle: data['productTitle'] ?? '',
      productImageUrl: data['productImageUrl'] ?? '',
      productPrice: (data['productPrice'] as num?)?.toDouble() ?? 0.0,
      participantIds: (data['participantIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sellerId: data['sellerId'] ?? '',
      buyerId: data['buyerId'] ?? '',
      lastMessage: data['lastMessage'] ?? '',
      lastMessageTimestamp: lastTime,
    );
  }
  // --- FIN DEL CÓDIGO NUEVO ---
}