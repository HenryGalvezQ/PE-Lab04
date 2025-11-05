import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String title; // puedes pasar "Marca Modelo" del producto
  const ChatScreen({super.key, required this.chatId, required this.title});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  late final String _myUid;

  @override
  void initState() {
    super.initState();
    _myUid = fb.FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final uid = _myUid;
    if (uid.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No estás autenticado en Firebase.')),
      );
      return;
    }
    try {
      final chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(widget.chatId);
      final msgRef = chatRef.collection('messages').doc();

      await FirebaseFirestore.instance.runTransaction((tx) async {
        tx.set(msgRef, {
          'senderId': _myUid,
          'text': text,
          'timestamp': FieldValue.serverTimestamp(),
        });
        tx.update(chatRef, {
          'lastMessage': text,
          'lastMessageTimestamp': FieldValue.serverTimestamp(),
        });
      });

      _controller.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al enviar: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final msgsQuery = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: msgsQuery.snapshots(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snap.hasError) {
                  return Center(child: Text('Error: ${snap.error}'));
                }
                final docs = snap.data?.docs ?? [];
                final messages = docs.map(Message.fromDoc).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: messages.length,
                  itemBuilder: (_, i) {
                    final m = messages[i];
                    final mine = m.senderId == _myUid;
                    final align = mine
                        ? Alignment.centerRight
                        : Alignment.centerLeft;
                    final bg = mine
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surface;
                    final fg = mine
                        ? Theme.of(context).colorScheme.onPrimary
                        : null;
                    return Align(
                      alignment: align,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: bg,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(mine ? 20 : 4),
                            topRight: Radius.circular(mine ? 4 : 20),
                            bottomLeft: const Radius.circular(20),
                            bottomRight: const Radius.circular(20),
                          ),
                        ),
                        child: Text(m.text, style: TextStyle(color: fg)),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 6.0,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: const InputDecoration(
                        hintText: 'Escribe un mensaje…',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(24)),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: _send, child: const Icon(Icons.send)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
