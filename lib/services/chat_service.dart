import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/chat.dart';
import '../models/start_chat_request.dart';
import '../services/session.dart';

class ChatService {
  static const String _baseUrl = "http://67.205.133.92:9364/"; // mismo baseUrl
  // :contentReference[oaicite:4]{index=4}

  Future<Chat> startOrGetChat({
    required String productId,
    required String counterpartId,
  }) async {
    final token = AuthSession.instance.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay token de sesión.');
    }

    final uri = Uri.parse('${_baseUrl}chats'); // POST /chats
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(
        StartChatRequest(
          productId: productId,
          counterpartId: counterpartId,
        ).toJson(),
      ),
    );

    if (resp.statusCode == 200 || resp.statusCode == 201) {
      return Chat.fromJson(jsonDecode(resp.body));
    }
    throw Exception(
      'No se pudo iniciar/obtener el chat: '
      '${resp.statusCode} ${resp.body}',
    );
  }
}
