import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class CloudinaryService {
  static const String cloudName = 'bignpvij';
  static const String uploadPreset = 'erickshaw_preset';

  static Future<String?> uploadFile(
    Uint8List bytes,
    String fileName, {
    String folder = 'erickshaw_docs',
  }) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..fields['folder'] = folder
      ..files.add(
        http.MultipartFile.fromBytes('file', bytes, filename: fileName),
      );

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['secure_url'] as String?;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }
}
