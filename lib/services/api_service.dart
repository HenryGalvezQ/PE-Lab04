import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/product.dart';

// Esta clase maneja toda la comunicación con tu backend.
class ApiService {
  // IMPORTANTE: Reemplaza esta URL con la dirección de tu backend.
  // Para emulador de Android, usa 'http://10.0.2.2:PUERTO' si el backend corre en tu PC.
  // Para emulador de iOS o dispositivo físico, usa la IP de tu PC en la red local.
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
            'Fallo al cargar los productos. Código: ${response.statusCode}');
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
      final response =
          await http.get(Uri.parse('$_baseUrl/products/$productId'));

      if (response.statusCode == 200) {
        // Si la respuesta es exitosa, decodifica el JSON y crea el objeto Product.
        return Product.fromJson(json.decode(response.body));
      } else {
        throw Exception(
            'Fallo al cargar el producto. Código: ${response.statusCode}');
      }
    } catch (e) {
      print(e);
      throw Exception('Fallo al conectar con el servidor.');
    }
  }
}
