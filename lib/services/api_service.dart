import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/product_request.dart'; 
import 'session.dart';

class ApiService {
  static const String _baseUrl = "http://67.205.133.92:9364/";

  // ---------------------------------------------------------------------------
  // 📦 OBTENER TODOS LOS PRODUCTOS
  // ---------------------------------------------------------------------------
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));

      if (response.statusCode == 200) {
        final List<dynamic> productsJson = json.decode(response.body);
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception(
          'Fallo al cargar los productos. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) print('fetchProducts error: $e');
      throw Exception('Fallo al conectar con el servidor.');
    }
  }

  // ---------------------------------------------------------------------------
  // 🔍 OBTENER DETALLE DE PRODUCTO POR ID
  // ---------------------------------------------------------------------------
  Future<Product> fetchProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/$productId'),
      );

      if (response.statusCode == 200) {
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Fallo al cargar el producto. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      if (kDebugMode) print('fetchProductById error: $e');
      throw Exception('Fallo al conectar con el servidor.');
    }
  }

  // ---------------------------------------------------------------------------
  // ➕ CREAR NUEVO PRODUCTO
  // ---------------------------------------------------------------------------
  Future<Product> createProduct(ProductRequest request, {String? token}) async {
    final idToken = token ?? AuthSession.instance.token;
    if (idToken == null || idToken.isEmpty) {
      throw Exception('No hay token de sesión. Inicia sesión primero.');
    }

    final uri = Uri.parse('$_baseUrl/products');
    final resp = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode(request.toJson()),
    );

    if (resp.statusCode == 201) {
      return Product.fromJson(jsonDecode(resp.body));
    } else {
      if (kDebugMode) {
        print('createProduct: ${resp.statusCode} -> ${resp.body}');
      }
      throw Exception('Error al crear producto (${resp.statusCode}).');
    }
  }

  // ---------------------------------------------------------------------------
  // 👤 OBTENER PERFIL DEL USUARIO AUTENTICADO
  // ---------------------------------------------------------------------------
  Future<User> getMyProfile() async {
    final token = AuthSession.instance.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay token de sesión. Inicia sesión primero.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      if (kDebugMode) {
        print('getMyProfile: ${response.statusCode} -> ${response.body}');
      }
      throw Exception('Error al obtener el perfil (${response.statusCode}).');
    }
  }
}
