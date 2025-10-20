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
  final String? boxImageUrl; // Puede ser nulo
  final String status;
  final bool active;

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
  });

  // Factory constructor para crear una instancia de Product desde un mapa JSON.
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 'N/A',
      brand: json['brand'] ?? 'Sin marca',
      model: json['model'] ?? 'Sin modelo',
      storage: json['storage'] ?? 'N/A',
      // Se convierte el precio a double, con un valor por defecto si es nulo.
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? 'Sin descripción',
      // Convierte la lista de URLs de cualquier tipo a una lista de Strings.
      imageUrls: (json['imageUrls'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      boxImageUrl: json['boxImageUrl'],
      status: json['status'] ?? 'unknown',
      active: json['active'] ?? false,
    );
  }
}
