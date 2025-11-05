import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String senderId;
  final String text;
  final DateTime? timestamp;

  Message({
    required this.id,
    required this.senderId,
    required this.text,
    required this.timestamp,
  });

  factory Message.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final ts = data['timestamp'];
    DateTime? t;
    if (ts is Timestamp) t = ts.toDate();
    return Message(
      id: doc.id,
      senderId: data['senderId'] ?? '',
      text: data['text'] ?? '',
      timestamp: t,
    );
  }

  Map<String, dynamic> toMap() => {
    'senderId': senderId,
    'text': text,
    'timestamp': FieldValue.serverTimestamp(),
  };
}
