// lib/screens/create_product_step3.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'create_product_state.dart';
import 'create_product_submit.dart';

class CreateProductStep3 extends StatefulWidget {
  final CreateProductState state;
  const CreateProductStep3({super.key, required this.state});

  @override
  State<CreateProductStep3> createState() => _CreateProductStep3State();
}

class _CreateProductStep3State extends State<CreateProductStep3> {
  final _imageUrlController = TextEditingController();

  Future<void> _pickFrom(
    ImageSource source,
    void Function(XFile) onPick,
  ) async {
    final picker = ImagePicker();
    final f = await picker.pickImage(source: source, imageQuality: 85);
    if (f != null) setState(() => onPick(f));
  }

  Future<void> _addProductImage() async {
    await showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Cámara'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFrom(
                  ImageSource.camera,
                  (f) => widget.state.pickedImages.add(f),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Galería'),
              onTap: () async {
                Navigator.pop(context);
                await _pickFrom(
                  ImageSource.gallery,
                  (f) => widget.state.pickedImages.add(f),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _imageUrlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;

    Widget thumb(XFile f, VoidCallback onRemove) => Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(
            File(f.path),
            width: 100,
            height: 100,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.black54,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onRemove,
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, size: 16, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Imágenes del producto')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fotos principales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: s.pickedImages.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  if (i < s.pickedImages.length) {
                    final f = s.pickedImages[i];
                    return thumb(
                      f,
                      () => setState(() => s.pickedImages.removeAt(i)),
                    );
                  }
                  return InkWell(
                    onTap: _addProductImage,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(context).colorScheme.outlineVariant,
                        ),
                      ),
                      child: const Icon(Icons.add_a_photo_outlined),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),
            Text(
              'Foto de la caja (opcional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    await _pickFrom(ImageSource.camera, (f) => s.boxFile = f);
                    setState(() {});
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: s.boxFile == null
                        ? const Icon(Icons.add_a_photo_outlined)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(s.boxFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                if (s.boxFile != null)
                  IconButton(
                    onPressed: () => setState(() => s.boxFile = null),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),

            const SizedBox(height: 16),
            Text(
              'Foto de la factura (opcional)',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                InkWell(
                  onTap: () async {
                    await _pickFrom(
                      ImageSource.camera,
                      (f) => s.invoiceFile = f,
                    );
                    setState(() {});
                  },
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: s.invoiceFile == null
                        ? const Icon(Icons.add_a_photo_outlined)
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.file(
                              File(s.invoiceFile!.path),
                              fit: BoxFit.cover,
                            ),
                          ),
                  ),
                ),
                if (s.invoiceFile != null)
                  IconButton(
                    onPressed: () => setState(() => s.invoiceFile = null),
                    icon: const Icon(Icons.close),
                  ),
              ],
            ),

            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Atrás'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () async {
                      final created = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CreateProductSubmit(state: s),
                        ),
                      );
                      if (created == true) {
                        if (context.mounted) Navigator.pop(context, true);
                      }
                    },
                    child: const Text('Crear producto'),
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
