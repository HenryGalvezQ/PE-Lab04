// lib/screens/create_product_step1.dart
import 'package:flutter/material.dart';
import 'create_product_state.dart';
import 'create_product_step2.dart';

class CreateProductStep1 extends StatelessWidget {
  final CreateProductState state;
  const CreateProductStep1({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comienza con tu venta')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(labelText: 'Marca'),
              onChanged: (v) => state.brand = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Modelo'),
              onChanged: (v) => state.model = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Almacenamiento'),
              onChanged: (v) => state.storage = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Precio (S/)'),
              keyboardType: TextInputType.number,
              onChanged: (v) => state.priceText = v,
            ),
            const Spacer(),
            FilledButton(
              onPressed: () async {
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateProductStep2(state: state),
                  ),
                );
                if (created == true) {
                  // Propaga el resultado hacia atrás (hasta ProductListScreen)
                  // de modo que el FAB .await lo reciba.
                  if (context.mounted) Navigator.pop(context, true);
                }
              },
              child: const Text('Siguiente'),
            ),
          ],
        ),
      ),
    );
  }
}
