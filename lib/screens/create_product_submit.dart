// lib/screens/create_product_submit.dart
import 'package:flutter/material.dart';
import '../models/product_request.dart';
import '../services/api_service.dart';
import '../services/cloudinary_service.dart';
import 'create_product_state.dart';

class CreateProductSubmit extends StatefulWidget {
  final CreateProductState state;
  const CreateProductSubmit({super.key, required this.state});

  @override
  State<CreateProductSubmit> createState() => _CreateProductSubmitState();
}

class _CreateProductSubmitState extends State<CreateProductSubmit> {
  String? _error;
  bool _success = false;
  bool _loading = true;

  late final CloudinaryService _cloudinary;

  @override
  void initState() {
    super.initState();
    _cloudinary = CloudinaryService(
      cloudName: 'dg5llpefb',
      uploadPreset: 'imagenes_android',
      folder: 'products',
    );
    _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
      _success = false;
    });
    final s = widget.state;

    final err = s.validate();
    if (err != null) {
      setState(() {
        _loading = false;
        _error = err;
      });
      return;
    }

    try {
      // 1) Asegura que tengamos URLs; si no, sube los archivos
      final urls = <String>[]..addAll(s.imageUrls);
      for (final f in s.pickedImages) {
        final url = await _cloudinary.uploadXFile(f);
        urls.add(url);
      }

      String? boxUrl = s.boxImageUrl;
      if (boxUrl == null && s.boxFile != null) {
        boxUrl = await _cloudinary.uploadXFile(s.boxFile!);
      }

      String? invoiceUrl = s.invoiceUrl;
      if (invoiceUrl == null && s.invoiceFile != null) {
        invoiceUrl = await _cloudinary.uploadXFile(s.invoiceFile!);
      }

      // 2) POST al backend
      final req = ProductRequest(
        brand: s.brand,
        model: s.model,
        storage: s.storage,
        price: s.price,
        imei: s.imei,
        description: s.description,
        imageUrls: urls,
        boxImageUrl: boxUrl,
        invoiceUrl: invoiceUrl,
      );

      await ApiService().createProduct(req);
      if (!mounted) return;
      setState(() {
        _success = true;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Creación de producto',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text('Subiendo imágenes y guardando…'),
            const SizedBox(height: 24),
            if (_loading) const CircularProgressIndicator(),
            if (!_loading && _error != null)
              Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
                textAlign: TextAlign.center,
              ),
            if (!_loading && _success) const Icon(Icons.check_circle, size: 80),
            const Spacer(),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Volver al inicio'),
            ),
          ],
        ),
      ),
    );
  }
}
