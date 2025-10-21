// lib/screens/create_product_step2.dart
import 'package:flutter/material.dart';
import 'create_product_state.dart';
import 'create_product_step3.dart';

class CreateProductStep2 extends StatelessWidget {
  final CreateProductState state;
  const CreateProductStep2({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalles del producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'IMEI (obligatorio)',
                hintText: '123456789012345',
              ),
              onChanged: (v) => state.imei = v,
            ),
            TextField(
              decoration: const InputDecoration(labelText: 'Descripción'),
              maxLines: 4,
              onChanged: (v) => state.description = v,
            ),
            const Spacer(),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Atrás'),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final created = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateProductStep3(state: state),
                        ),
                      );
                      if (created == true) {
                        if (context.mounted) Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Siguiente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
