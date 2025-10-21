import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class CloudinaryService {
  final String cloudName; // p.ej. 'dg5llpefb'
  final String uploadPreset; // p.ej. 'imagenes_android' (unsigned)
  final String folder; // p.ej. 'products'

  CloudinaryService({
    required this.cloudName,
    required this.uploadPreset,
    this.folder = 'products',
  });

  Future<String> uploadXFile(XFile file) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );
    final req = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final streamed = await req.send();
    final resp = await http.Response.fromStream(streamed);

    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      final secureUrl = data['secure_url'] as String?;
      if (secureUrl == null || secureUrl.isEmpty) {
        throw Exception('Cloudinary: respuesta sin secure_url');
      }
      return secureUrl;
    }
    throw Exception('Cloudinary error ${resp.statusCode}: ${resp.body}');
  }
}
