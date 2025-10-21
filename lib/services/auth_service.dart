import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class AuthService {
  static const String _baseUrl = "http://67.205.133.92:9364/";

  // REGISTRO DE USUARIO
  Future<User> register({
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
      return User.fromJson(data['user']);
    } else {
      throw Exception("Error al registrar: ${response.body}");
    }
  }

  // LOGIN: flujo alternativo de Firebase REST API
  Future<String> login(String email, String password, String apiKey) async {
    final url =
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey";

    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "email": email,
        "password": password,
        "returnSecureToken": true,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['idToken']; // Este token se usa en headers Authorization
    } else {
      throw Exception("Credenciales inválidas");
    }
  }

  // PERFIL DEL USUARIO AUTENTICADO
  Future<User> getProfile(String token) async {
    final response = await http.get(
      Uri.parse("${_baseUrl}users/me"),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return User.fromJson(jsonDecode(response.body));
    } else {
      throw Exception("No se pudo obtener el perfil");
    }
  }
}
