import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';
import 'package:flutter/foundation.dart';
import '../models/product_request.dart';
import 'session.dart';

class ApiService {
  static const String _baseUrl = "http://67.205.133.92:9364/";

  // Obtiene la lista completa de productos.
  Future<List<Product>> fetchProducts() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/products'));

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa (200 OK), decodifica el JSON.
        final List<dynamic> productsJson = json.decode(response.body);
        // Convierte la lista de JSON a una lista de objetos Product.
        return productsJson.map((json) => Product.fromJson(json)).toList();
      } else {
        // Si el servidor devuelve un error, lanza una excepción.
        throw Exception(
          'Fallo al cargar los productos. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      // Captura errores de red o de parseo.
      print(e);
      throw Exception('Fallo al conectar con el servidor.');
    }
  }

  // Obtiene un producto específico por su ID.
  Future<Product> fetchProductById(String productId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/products/$productId'),
      );

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, decodifica el JSON y crea el objeto Product.
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception(
          'Fallo al cargar el producto. Código: ${response.statusCode}',
        );
      }
    } catch (e) {
      print(e);
      throw Exception('Fallo al conectar con el servidor.');
    }
  }

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
}
