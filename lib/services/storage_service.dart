import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  // Camera ya Gallery se image pick karo
  Future<File?> pickImage(ImageSource source) async {
    final pickedFile =
        await _picker.pickImage(source: source, imageQuality: 75);
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  // Generic File Uploader
  Future<String> uploadFile({
    required File file,
    required String path,
  }) async {
    final ref = _storage.ref().child(path);
    final uploadTask = await ref.putFile(file);
    return await uploadTask.ref.getDownloadURL();
  }
}
