import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CloudinaryService {
  // Apne Cloudinary dashboard se ye details replace karein:
  static const String cloudName = "your_cloud_name";
  static const String uploadPreset = "your_unsigned_upload_preset";

  static Future<String?> uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/raw/upload");
      var request = http.MultipartRequest("POST", uri);

      var multipartFile = http.MultipartFile.fromBytes(
        'file',
        fileBytes,
        filename: fileName,
      );

      request.files.add(multipartFile);
      request.fields['upload_preset'] = uploadPreset;

      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        var jsonMap = jsonDecode(responseString);
        return jsonMap['secure_url'] as String?;
      } else {
        debugPrint("Cloudinary Upload Error: $responseString");
        return null;
      }
    } catch (e) {
      debugPrint("Cloudinary Service Exception: $e");
      return null;
    }
  }
}
