import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/admin_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  User? get currentUser => _auth.currentUser;

  // 1. Admin Login
  Future<AdminModel?> signInWithEmail(String email, String password) async {
    final creds = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (creds.user != null) {
      final doc = await _db.collection('users').doc(creds.user!.uid).get();
      if (doc.exists && doc.data() != null) {
        return AdminModel.fromMap(doc.data()!);
      }
    }
    return null;
  }

  // 2. Fetch Logged-in Admin Profile
  Future<AdminModel?> getAdminProfile(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return AdminModel.fromMap(doc.data()!);
    }
    return null;
  }

  // 3. Admin Profile Photo Upload & Update
  Future<String> updateAdminProfilePhoto(String uid, File imageFile) async {
    final ref = _storage.ref().child('admin_profiles/$uid.jpg');
    await ref.putFile(imageFile);
    final downloadUrl = await ref.getDownloadURL();

    await _db.collection('users').doc(uid).update({'photoUrl': downloadUrl});

    return downloadUrl;
  }

  // 4. Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
