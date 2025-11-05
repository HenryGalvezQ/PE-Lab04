// lib/screens/chat_list_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import 'chat_screen.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  // Obtenemos el ID del usuario actual de Firebase Auth
  final String? _myUid = fb.FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot<Map<String, dynamic>>>? _buildStream() {
    final uid = _myUid;
    if (uid == null || uid.isEmpty) {
      // Si no hay UID, no podemos hacer la consulta
      return null;
    }

    // Esta es la consulta clave, basada en la referencia de Kotlin:
    // 1. Ve a la colección 'chats'.
    // 2. Tráeme solo los documentos donde el array 'participantIds' contenga mi UID.
    // 3. Ordénalos por el último mensaje, del más reciente al más antiguo.
    return FirebaseFirestore.instance
        .collection('chats')
        .where('participantIds', arrayContains: uid)
        .orderBy('lastMessageTimestamp', descending: true)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final stream = _buildStream();

    if (stream == null) {
      // Caso: Usuario no autenticado
      return Scaffold(
        appBar: AppBar(title: const Text('Mis Chats')),
        body: const Center(
          child: Text('No estás autenticado para ver tus chats.'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Conversaciones')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: stream,
        builder: (context, snapshot) {
          // Caso: Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Caso: Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar chats: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // Caso: Éxito
          final docs = snapshot.data?.docs ?? [];

          // Caso: Éxito pero no hay chats
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_bubble_outline,
                      size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No tienes conversaciones',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Inicia un chat desde la página de un producto.',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          // Mapeamos los documentos a objetos Chat usando el factory que creamos
          final chats = docs.map((doc) => Chat.fromDoc(doc)).toList();

          // Caso: Éxito y hay chats
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return _ChatListItem(
                chat: chat,
                onTap: () {
                  // Navegamos a la pantalla de chat existente
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatScreen(
                        chatId: chat.id,
                        title: chat.productTitle, // [cite: 51]
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

// --- WIDGET PARA MOSTRAR CADA ITEM DE LA LISTA ---
// (Basado en el estilo de tu ProductCard [cite: 463])
class _ChatListItem extends StatelessWidget {
  final Chat chat;
  final VoidCallback onTap;

  const _ChatListItem({required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final imageUrl = chat.productImageUrl.isNotEmpty
        ? chat.productImageUrl
        : 'https_invalid_url_placeholder';

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.0), // [cite: 15]
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // 1. Imagen del Producto
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0), // [cite: 465]
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  width: 64, // Un poco más pequeño que en la lista de productos
                  height: 64,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 64,
                      height: 64,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),

              // 2. Información (Título y último mensaje)
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chat.productTitle,
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chat.lastMessage,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // 3. Icono de flecha
              Icon(
                Icons.arrow_forward_ios,
                size: 16.0,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}