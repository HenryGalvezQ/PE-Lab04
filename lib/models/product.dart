// Este archivo define la estructura de datos de un producto,
// facilitando la conversión de JSON a un objeto Dart.

class Product {
  final String id;
  final String brand;
  final String model;
  final String storage;
  final double price;
  final String description;
  final List<String> imageUrls;
  final String? boxImageUrl;
  final String status;
  final bool active;
  final String sellerId; // <- agregar esta línea

  Product({
    required this.id,
    required this.brand,
    required this.model,
    required this.storage,
    required this.price,
    required this.description,
    required this.imageUrls,
    this.boxImageUrl,
    required this.status,
    required this.active,
    required this.sellerId, // <- agregar al constructor
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 'N/A',
      brand: json['brand'] ?? 'Sin marca',
      model: json['model'] ?? 'Sin modelo',
      storage: json['storage'] ?? 'N/A',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? 'Sin descripción',
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      boxImageUrl: json['boxImageUrl'],
      status: json['status'] ?? 'unknown',
      active: json['active'] ?? false,
      sellerId: json['sellerId'] ?? 'unknown', // <- mapear desde JSON
    );
  }
}