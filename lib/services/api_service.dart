import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../models/product.dart';
import '../models/product_request.dart'; 
import '../models/transaction.dart';

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

  Future<List<Transaction>> fetchMyTransactions() async {
    final token = AuthSession.instance.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay token de sesión. Inicia sesión primero.');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/transactions'), // Endpoint de transacciones
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Transaction.fromJson(json)).toList();
    } else {
      if (kDebugMode) {
        print('fetchMyTransactions: ${response.statusCode} -> ${response.body}');
      }
      throw Exception(
          'Error al obtener transacciones (${response.statusCode}).');
    }
  }
  // ---------------------------------------------------------------------------
// 🛒 CREAR TRANSACCIÓN (COMPRAR/RESERVAR)
// ---------------------------------------------------------------------------
Future<Transaction> createTransaction(String productId) async {
  final token = AuthSession.instance.token;
  if (token == null || token.isEmpty) {
    throw Exception('No hay token de sesión. Inicia sesión primero.');
  }

  final response = await http.post(
    Uri.parse('$_baseUrl/transactions'), // [cite: 463]
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    // El body solo necesita el productId [cite: 473]
    body: jsonEncode({'productId': productId}),
  );

  if (response.statusCode == 201) { // [cite: 476]
    // Devuelve la transacción recién creada
    return Transaction.fromJson(jsonDecode(response.body));
  } else {
    if (kDebugMode) {
      print(
          'createTransaction Error: ${response.statusCode} -> ${response.body}');
    }
    // Manejo de error específico si el producto ya está reservado
    if (response.statusCode == 409) {
      throw Exception('Este producto ya no está disponible o fue reservado.');
    }
    throw Exception('Error al reservar el producto (${response.statusCode}).');
  }
}

  // ---------------------------------------------------------------------------
  // ✅ ACTUALIZAR ESTADO DE PRODUCTO (CONFIRMAR VENTA)
  // ---------------------------------------------------------------------------
  Future<Product> updateProductStatus(String productId, String status) async {
    final token = AuthSession.instance.token;
    if (token == null || token.isEmpty) {
      throw Exception('No hay token de sesión. Inicia sesión primero.');
    }

    final response = await http.put(
      Uri.parse('$_baseUrl/products/$productId'), // [cite: 261]
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      // El body solo necesita el nuevo estado [cite: 271-272]
      body: jsonEncode({'status': status}),
    );

    if (response.statusCode == 200) { // [cite: 276]
      return Product.fromJson(jsonDecode(response.body));
    } else {
      if (kDebugMode) {
        print(
            'updateProductStatus Error: ${response.statusCode} -> ${response.body}');
      }
      throw Exception(
          'Error al actualizar el estado del producto (${response.statusCode}).');
    }
  }
}
