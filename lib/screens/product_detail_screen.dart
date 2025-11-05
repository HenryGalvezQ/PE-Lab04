import 'package:flutter/material.dart';
import '../models/product.dart';
import '../services/api_service.dart';
import '../services/chat_service.dart';
import '../screens/chat_screen.dart';
import '../models/chat.dart';
import '../models/user.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<Product> _productDetailFuture;
  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _productDetailFuture = _apiService.fetchProductById(widget.productId);
  }

  void _retryFetch() {
    setState(() {
      _productDetailFuture = _apiService.fetchProductById(widget.productId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle del Producto')),
      body: FutureBuilder<Product>(
        future: _productDetailFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            final product = snapshot.data!;
            return _buildProductDetails(context, product);
          }
          return _buildErrorView('No se pudo cargar el producto.');
        },
      ),
    );
  }

  // Este widget crea el carrusel horizontal de imágenes
  Widget _buildImageCarousel(Product product) {
    // Filtramos imágenes vacías o nulas
    final validImages = product.imageUrls
        .where((url) => url.trim().isNotEmpty)
        .toList();

    if (validImages.isEmpty) {
      return _buildImagePlaceholder();
    }

    return Container(
      height: 250,
      // Usamos PageView para un carrusel que se "pagina"
      child: PageView.builder(
        itemCount: validImages.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: Image.network(
                validImages[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: const Center(
        child: Icon(Icons.broken_image, size: 64, color: Colors.grey),
      ),
    );
  }

  // Contenido principal de la pantalla
  Widget _buildProductDetails(BuildContext context, Product product) {
    return Column(
      children: [
        // Usamos Expanded para que la lista ocupe el espacio
        // y los botones queden abajo
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Carrusel de Imágenes
                _buildImageCarousel(product),
                const SizedBox(height: 24),

                // 2. Título y Precio
                Text(
                  '${product.brand} ${product.model} ${product.storage}',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Divider(height: 40),

                // 3. Filas de Detalles (replicando tu DetailRow)
                _DetailRow(
                  icon: Icons.description,
                  label: 'Descripción',
                  value: product.description,
                ),
                _DetailRow(
                  icon: Icons.person,
                  label: 'Vendedor',
                  value: 'Vendedor Anónimo', // Aún no tenemos esta info
                ),
                _DetailRow(
                  icon: Icons.inventory,
                  label: 'Incluye caja',
                  value:
                      product.boxImageUrl != null &&
                          product.boxImageUrl!.isNotEmpty
                      ? 'Sí'
                      : 'No',
                ),
              ],
            ),
          ),
        ),

        // 4. Botones (deshabilitados para visitante)
        _buildBottomButtons(context, product),
      ],
    );
  }

  // Botones fijos en la parte inferior
  Widget _buildBottomButtons(BuildContext context, Product product) {
    return Container(
      padding: const EdgeInsets.all(
        16.0,
      ).copyWith(bottom: 32.0), // Más padding abajo para que no pegue al borde
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Botón "Contactar Vendedor" (deshabilitado)
          OutlinedButton(
            onPressed: () {
              _startChat(product);
            },
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.chat_outlined),
                SizedBox(width: 8),
                Text('Contactar Vendedor'),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Botón "Comprar" (deshabilitado)
          ElevatedButton(
            onPressed: null, // Deshabilitado
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: Colors.grey.shade300,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.shopping_cart_outlined),
                SizedBox(width: 8),
                Text('Comprar'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vista de Error
  Widget _buildErrorView(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error al cargar',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            Text(
              error,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _retryFetch,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startChat(Product product) async {
    try {
      // Evitar chat con uno mismo: saco mi perfil del backend
      final me = await _apiService.getMyProfile(); // /users/me
      // :contentReference[oaicite:7]{index=7}
      if (me.id == product.sellerId) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Este producto es tuyo.')));
        return;
      }

      final chat = await ChatService().startOrGetChat(
        productId: product.id,
        counterpartId: product.sellerId, // sellerId viene en Product
        // :contentReference[oaicite:8]{index=8}
      );

      if (!mounted) return;
      final title = '${product.brand} ${product.model}';
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(chatId: chat.id, title: title),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('No se pudo abrir el chat: $e')));
    }
  }
}

// Widget de ayuda para las filas
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
