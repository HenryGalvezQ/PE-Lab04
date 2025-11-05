// lib/widgets/product_card.dart
import 'package:flutter/material.dart';
import '../models/product.dart';
import '../screens/product_detail_screen.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final String imageUrl = product.imageUrls.isNotEmpty &&
            product.imageUrls.first.trim().isNotEmpty
        ? product.imageUrls.first
        : 'https_invalid_url_placeholder';

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          ).then((result) {
            // Nota: Podríamos pasar un 'true' al volver si algo cambió
            // para forzar un refresco de la lista de "Mis Productos".
            // Por ahora, lo dejamos simple.
          });
        },
        borderRadius: BorderRadius.circular(20.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                clipBehavior: Clip.antiAlias,
                child: Image.network(
                  imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${product.brand} ${product.model}',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // --- PRECIO (YA NO ESTABA, LO RE-AGREGO) ---
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // --- INICIO: CHIP DE ESTADO (NUEVO) ---
                    _StatusChip(status: product.status),
                    // --- FIN: CHIP DE ESTADO (NUEVO) ---
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 16.0,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// --- WIDGET DE CHIP DE ESTADO (AÑADIDO AL FINAL DEL ARCHIVO) ---
class _StatusChip extends StatelessWidget {
  final String status;
  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (String text, Color bgColor, Color fgColor, IconData icon) =
        switch (status.toLowerCase()) {
      'approved' => (
          'Aprobado',
          theme.colorScheme.primaryContainer,
          theme.colorScheme.onPrimaryContainer,
          Icons.check_circle_outline
        ),
      'pending' => (
          'Pendiente',
          theme.colorScheme.tertiaryContainer,
          theme.colorScheme.onTertiaryContainer,
          Icons.hourglass_empty_outlined
        ),
      'reserved' => (
          'Reservado',
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
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.8),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fgColor),
          const SizedBox(width: 6),
          Text(
            text,
            style: theme.textTheme.labelMedium?.copyWith(
              color: fgColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}