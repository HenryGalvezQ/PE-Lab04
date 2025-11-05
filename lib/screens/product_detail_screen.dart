// lib/screens/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/user.dart'; // Para el perfil
import '../services/api_service.dart';
import '../services/chat_service.dart';
import '../screens/chat_screen.dart';
// Importamos el modelo de User, no el de Chat
// import '../models/chat.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;
  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  // Cambiamos el Future para que cargue una LISTA de datos: [Producto, Perfil]
  late Future<List<dynamic>> _dataFuture;
  final ApiService _apiService = ApiService();

  // Estado para los botones de acción
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Ahora _dataFuture carga el producto Y el perfil del usuario
    _dataFuture = Future.wait([
      _apiService.fetchProductById(widget.productId),
      _apiService.getMyProfile(), // [cite: 903]
    ]);
  }

  // Refresca TODOS los datos (producto y perfil)
  void _retryFetch() {
    setState(() {
      _isSubmitting = false; // Resetea el estado de envío
      _dataFuture = Future.wait([
        _apiService.fetchProductById(widget.productId),
        _apiService.getMyProfile(),
      ]);
    });
  }

  // --- ACCIONES DE LOS BOTONES ---

  Future<void> _purchaseProduct(String productId) async {
    setState(() => _isSubmitting = true);
    try {
      // Usamos el nuevo método de api_service
      await _apiService.createTransaction(productId);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Producto reservado exitosamente!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refrescamos la pantalla para ver el nuevo estado
      _retryFetch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al reservar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmSale(String productId) async {
    setState(() => _isSubmitting = true);
    try {
      // Usamos el nuevo método para actualizar el estado a "vendido"
      // Nota: El backend debe permitir al 'owner' hacer esto. [cite: 262]
      await _apiService.updateProductStatus(productId, "sold");

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Venta confirmada!'),
          backgroundColor: Colors.green,
        ),
      );
      // Refrescamos la pantalla
      _retryFetch();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al confirmar: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _startChat(Product product, User me) async {
    // La lógica de _startChat que ya tenías [cite: 785-792]
    try {
      if (me.id == product.sellerId) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Este producto es tuyo.')));
        return;
      }
      final chat = await ChatService().startOrGetChat(
        productId: product.id,
        counterpartId: product.sellerId,
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
  // --- FIN DE ACCIONES ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalle del Producto'),
        actions: [
          // Botón de refresco
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _retryFetch,
          ),
        ],
      ),
      body: FutureBuilder<List<dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _buildErrorView(snapshot.error.toString());
          }
          if (snapshot.hasData) {
            // Desempaquetamos los datos
            final Product product = snapshot.data![0] as Product;
            final User me = snapshot.data![1] as User;
            final bool isOwner = product.sellerId == me.id;

            return _buildProductDetails(context, product, me, isOwner);
          }
          return _buildErrorView('No se pudo cargar el producto.');
        },
      ),
    );
  }

  // ... (Tus widgets _buildImageCarousel y _buildImagePlaceholder
  //      permanecen exactamente iguales que antes) [cite: 757-763]
  Widget _buildImageCarousel(Product product) {
    final validImages =
        product.imageUrls.where((url) => url.trim().isNotEmpty).toList();
    if (validImages.isEmpty) {
      return _buildImagePlaceholder();
    }
    return Container(
      height: 250,
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

  // --- CONTENIDO PRINCIPAL (ACTUALIZADO) ---
  Widget _buildProductDetails(
      BuildContext context, Product product, User me, bool isOwner) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildImageCarousel(product),
                const SizedBox(height: 24),
                
                // --- (NUEVO) CHIP DE ESTADO ---
                Align(
                  alignment: Alignment.centerLeft,
                  child: _StatusChip(status: product.status),
                ),
                const SizedBox(height: 16),
                
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
                
                // Tus _DetailRow (sin cambios) [cite: 768-772]
                _DetailRow(
                  icon: Icons.description,
                  label: 'Descripción',
                  value: product.description,
                ),
                _DetailRow(
                  icon: Icons.person,
                  label: 'Vendedor',
                  value: isOwner ? 'Tú' : 'Vendedor Anónimo',
                ),
                _DetailRow(
                  icon: Icons.inventory,
                  label: 'Incluye caja',
                  value: product.boxImageUrl != null &&
                          product.boxImageUrl!.isNotEmpty
                      ? 'Sí'
                      : 'No',
                ),
              ],
            ),
          ),
        ),

        // --- BOTONES INFERIORES (LÓGICA COMPLETAMENTE NUEVA) ---
        _buildBottomButtons(context, product, me, isOwner),
      ],
    );
  }

  // --- LÓGICA DE BOTONES INFERIORES (REESCRITA) ---
  Widget _buildBottomButtons(
      BuildContext context, Product product, User me, bool isOwner) {
    // Widget para mostrar un estado (cargando, producto no disponible, etc.)
    Widget buildStatusButton(String text, {IconData? icon}) {
      return ElevatedButton.icon(
        onPressed: null, // Deshabilitado
        icon: icon != null ? Icon(icon) : const SizedBox(width: 24),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          backgroundColor: Colors.grey.shade300,
        ),
      );
    }

    List<Widget> buttons = [];

    // --- LÓGICA PARA EL DUEÑO (VENDEDOR) ---
    if (isOwner) {
      if (product.status.toLowerCase() == 'reserved') {
        // 1. Dueño, y producto está "Reservado" -> Mostrar "Confirmar Venta"
        buttons.add(
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () => _confirmSale(product.id),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check_circle),
            label: const Text('Confirmar Venta'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        );
      } else if (product.status.toLowerCase() == 'sold') {
        // 2. Dueño, y producto "Vendido" -> Mostrar estado
        buttons.add(buildStatusButton('Producto Vendido', icon: Icons.check));
      } else {
        // 3. Dueño, y producto "Aprobado" o "Pendiente" -> Mostrar estado
        buttons.add(
            buildStatusButton('Este es tu producto', icon: Icons.person));
      }
    }
    // --- LÓGICA PARA EL NO-DUEÑO (COMPRADOR) ---
    else {
      // 1. Comprador -> Siempre mostrar "Contactar Vendedor"
      buttons.add(
        OutlinedButton.icon(
          onPressed: _isSubmitting ? null : () => _startChat(product, me),
          icon: const Icon(Icons.chat_outlined),
          label: const Text('Contactar Vendedor'),
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
          ),
        ),
      );
      buttons.add(const SizedBox(height: 8));

      // 2. Comprador -> Lógica del botón de "Comprar"
      if (product.status.toLowerCase() == 'approved') {
        // 2a. Producto "Aprobado" -> Mostrar "Comprar"
        buttons.add(
          ElevatedButton.icon(
            onPressed: _isSubmitting ? null : () => _purchaseProduct(product.id),
            icon: _isSubmitting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.shopping_cart_outlined),
            label: const Text('Comprar (Reservar)'),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        );
      } else if (product.status.toLowerCase() == 'reserved') {
        // 2b. Producto "Reservado" -> Mostrar deshabilitado
        buttons.add(buildStatusButton('Producto Reservado'));
      } else if (product.status.toLowerCase() == 'sold') {
        // 2c. Producto "Vendido" -> Mostrar deshabilitado
        buttons.add(buildStatusButton('Producto Vendido'));
      } else {
        // 2d. Producto "Pendiente", "Rechazado", etc. -> Mostrar deshabilitado
        buttons.add(buildStatusButton('Producto no disponible'));
      }
    }

    // --- Contenedor de los botones ---
    return Container(
      padding: const EdgeInsets.all(16.0)
          .copyWith(bottom: 32.0), // Padding extra abajo
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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: buttons,
      ),
    );
  }

  // --- VISTA DE ERROR (Sin cambios) ---
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
}

// --- WIDGET DE AYUDA _DetailRow (Sin cambios) --- [cite: 792-798]
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

// --- (NUEVO) WIDGET DE CHIP DE ESTADO ---
// (Lo pongo aquí también para que la pantalla de detalle lo tenga)
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (String text, Color bgColor, Color fgColor, IconData icon) =
        switch (status.toLowerCase()) {
      'approved' => (
          'Disponible para la venta',
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.check_circle_outline
        ),
      'pending' => (
          'Pendiente de Aprobación',
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          Icons.hourglass_empty_outlined
        ),
      'reserved' => (
          'Reservado (Esperando confirmación)',
          theme.colorScheme.secondaryContainer,
          theme.colorScheme.onSecondaryContainer,
          Icons.shopping_bag_outlined
        ),
      'sold' => (
          'Vendido',
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.check_circle
        ),
      'reject' => (
          'Rechazado',
          theme.colorScheme.errorContainer,
          theme.colorScheme.onErrorContainer,
          Icons.error_outline
        ),
      _ => (
          status,
          theme.colorScheme.surfaceVariant,
          theme.colorScheme.onSurfaceVariant,
          Icons.question_mark
        )
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fgColor),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: theme.textTheme.labelLarge?.copyWith(
                color: fgColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}