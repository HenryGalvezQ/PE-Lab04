// lib/screens/create_product_state.dart
import 'package:image_picker/image_picker.dart';

class CreateProductState {
  String brand = '';
  String model = '';
  String storage = '';
  String priceText = '';
  double get price => double.tryParse(priceText) ?? 0.0;
  String imei = '';
  String description = '';

  final List<String> imageUrls = [];
  String? boxImageUrl;
  String? invoiceUrl;
  // NUEVO: archivos locales a subir
  final List<XFile> pickedImages = [];
  XFile? boxFile;
  XFile? invoiceFile;

  String? validate() {
    if (brand.trim().isEmpty) return 'Por favor ingresa la marca.';
    if (model.trim().isEmpty) return 'Por favor ingresa el modelo.';
    if (storage.trim().isEmpty) return 'Por favor ingresa el almacenamiento.';
    if (price <= 0) return 'Por favor ingresa un precio válido.';
    if (imei.trim().isEmpty) return 'Por favor ingresa el IMEI.';
    // Acepta al menos una imagen ya sea como URL o archivo local
    final hasAnyImage = imageUrls.isNotEmpty || pickedImages.isNotEmpty;
    if (!hasAnyImage) return 'Debes agregar al menos una imagen.';
    return null;
  }
}
