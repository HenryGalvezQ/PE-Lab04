// lib/screens/chat_screen.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
// Imports de 'intl' para formatear fechas y horas
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart'; // Para fechas en español

import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String title;
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
    
    // Inicializa la localización de fechas para español
    // (Asegúrate de haber añadido 'intl' a tu pubspec.yaml)
    initializeDateFormatting('es_ES');
  }

  Future<void> _send() async {
    // ... (Tu función _send sigue siendo la misma, no necesita cambios)
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
    // ... (Fin de la función _send)
  }

  @override
  Widget build(BuildContext context) {
    // La consulta a Firestore sigue siendo la misma
    final msgsQuery = FirebaseFirestore.instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false); //

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

                // --- ¡NUEVA LÓGICA DE AGRUPACIÓN! ---
                // Creamos una lista que contendrá tanto widgets de Fecha (String)
                // como widgets de Mensaje (Message)
                final List<dynamic> displayItems = [];
                String? lastDateHeader;

                for (final m in messages) {
                  // Ignoramos mensajes que aún no tienen hora (raro, pero seguro)
                  if (m.timestamp == null) continue;

                  // 1. Revisa si necesitamos un cabezal de fecha
                  final dateHeader = formatDateHeader(m.timestamp!);
                  if (dateHeader != lastDateHeader) {
                    displayItems.add(dateHeader);
                    lastDateHeader = dateHeader;
                  }
                  
                  // 2. Añade el mensaje
                  displayItems.add(m);
                }
                // --- FIN DE LA LÓGICA DE AGRUPACIÓN ---

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  // Usamos la nueva lista de items (fechas + mensajes)
                  itemCount: displayItems.length,
                  itemBuilder: (_, i) {
                    final item = displayItems[i];

                    // --- RENDERIZADO CONDICIONAL ---
                    
                    // Caso 1: El item es un String, renderiza un separador de fecha
                    if (item is String) {
                      return _DateSeparator(date: item);
                    }

                    // Caso 2: El item es un Mensaje, renderiza la burbuja
                    final m = item as Message;
                    final mine = m.senderId == _myUid;
                    final align =
                        mine ? Alignment.centerRight : Alignment.centerLeft;
                    
                    // --- ¡CAMBIO DE COLOR SOLICITADO! ---
                    // 'surface' es blanco, 'surfaceContainer' es un gris claro
                    final bg = mine
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).colorScheme.surfaceContainer; 
                    
                    final fg = mine
                        ? Theme.of(context).colorScheme.onPrimary
                        : null; // null usa el color de texto por defecto (oscuro)

                    return Align(
                      alignment: align,
                      // Añadimos una restricción de ancho para que las burbujas
                      // no ocupen toda la pantalla
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.75,
                        ),
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
                          
                          // --- ¡NUEVO CHILD CON HORA! ---
                          // Usamos un Row para poner el texto y la hora
                          child: Row(
                            mainAxisSize: MainAxisSize.min, // No estirar
                            crossAxisAlignment: CrossAxisAlignment.end, // Alinear hora abajo
                            children: [
                              // El texto del mensaje (Flexible para que se ajuste)
                              Flexible(
                                child: Text(
                                  m.text,
                                  style: TextStyle(color: fg, fontSize: 16),
                                ),
                              ),
                              const SizedBox(width: 8),
                              // La hora del mensaje
                              Text(
                                formatMessageTime(m.timestamp!),
                                style: TextStyle(
                                  // El color del texto es el mismo de la burbuja,
                                  // pero con opacidad
                                  color: (fg ?? Theme.of(context).colorScheme.onSurface)
                                      .withOpacity(0.7),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          // --- FIN DEL NUEVO CHILD ---
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          
          // --- La caja de texto inferior no cambia ---
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

// --- WIDGETS Y FUNCIONES DE AYUDA (Añadir al final del archivo) ---

/// Widget para mostrar la cabecera de la fecha ("Hoy", "Ayer", etc.)
class _DateSeparator extends StatelessWidget {
  final String date;
  const _DateSeparator({required this.date});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12.0),
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface, // Fondo blanco
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          date,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ),
    );
  }
}

/// Formatea la fecha para el cabezal (p.ej. "Hoy", "Ayer", "martes, 3 de sep")
String formatDateHeader(DateTime date) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final dateToFormat = DateTime(date.year, date.month, date.day);

  if (dateToFormat == today) {
    return "Hoy";
  } else if (dateToFormat == yesterday) {
    return "Ayer";
  } else if (now.difference(dateToFormat).inDays < 7) {
    // Día de la semana (ej. "martes")
    return DateFormat.EEEE('es_ES').format(date);
  } else {
    // Fecha completa (ej. "3 de septiembre de 2024")
    return DateFormat.yMMMMd('es_ES').format(date);
  }
}

/// Formatea la hora del mensaje (p.ej. "10:30 a. m.")
String formatMessageTime(DateTime date) {
  // 'jm' es el formato para "10:30 AM"
  return DateFormat.jm('es_ES').format(date);
}