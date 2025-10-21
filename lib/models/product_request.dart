// lib/models/product_request.dart
class ProductRequest {
  final String brand;
  final String model;
  final String storage;
  final double price;
  final String imei;
  final String description;
  final List<String> imageUrls; // URLs (no archivos)
  final String? boxImageUrl; // URL opcional
  final String? invoiceUrl; // URL opcional


  const ProductRequest({
    required this.brand,
    required this.model,
    required this.storage,
    required this.price,
    required this.imei,
    required this.description,
    this.imageUrls = const [],
    this.boxImageUrl,
    this.invoiceUrl,
  });


  Map<String, dynamic> toJson() => {
    'brand': brand,
    'model': model,
    'storage': storage,
    'price': price,
    'imei': imei,
    'description': description,
    'imageUrls': imageUrls,
    'boxImageUrl': boxImageUrl,
    'invoiceUrl': invoiceUrl,
  };
}