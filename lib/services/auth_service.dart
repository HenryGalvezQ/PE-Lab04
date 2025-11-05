import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart' as app;
import 'package:firebase_auth/firebase_auth.dart' as fb;

class AuthService {
  static const String _baseUrl = "http://67.205.133.92:9364/";

  // REGISTRO DE USUARIO
  Future<app.User> register({
    required String firstName,
    required String lastName,
    required String dniNumber,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${_baseUrl}auth/register"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "firstName": firstName,
        "lastName": lastName,
        "dniNumber": dniNumber,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return app.User.fromJson(data['user']);
    } else {
      throw Exception("Error al registrar: ${response.body}");
    }
  }

  // LOGIN: flujo alternativo de Firebase REST API
  Future<String> login(String email, String password, String apiKey) async {
    // 1) Autentica en FirebaseAuth SDK
    final cred = await fb.FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // getIdToken() es String? → forzamos refresco y validamos
    final token = await cred.user?.getIdToken(true);
    if (token == null) {
      throw Exception('No se pudo obtener el ID token de Firebase.');
    }
    return token; // ⭐ ahora cumple Future<String>
  }

  // PERFIL DEL USUARIO AUTENTICADO
  Future<app.User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("${_baseUrl}users/me"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return app.User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("No se pudo obtener el perfil");
    }
  }
}
