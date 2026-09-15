import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;
  String? userId;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
  }

  Future<void> _uploadDocument(String docType) async {
    if (userId == null) return;

    try {
      // 1. Camera/Gallery se photo click karwao
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery, // CAMERA KI JAGAH GALLERY KAR DIYA
        imageQuality: 50,
      );

      if (image == null) return;

      setState(() => _isUploading = true);

      // 2. Firebase Storage me save karo
      final String fileName =
          'kyc/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(
        fileName,
      );
      final UploadTask uploadTask = storageRef.putFile(File(image.path));

      final TaskSnapshot snapshot = await uploadTask;
      final String downloadUrl = await snapshot.ref.getDownloadURL();

      // 3. Firestore Database me link update karo
      await FirebaseFirestore.instance.collection('customers').doc(userId).set({
        'documents': {docType: downloadUrl},
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$docType Uploaded Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      debugPrint("Upload Error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Documents'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: _isUploading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Uploading securely to cloud...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .doc(userId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data?.data() as Map<String, dynamic>?;
                final docsMap =
                    (data?['documents'] as Map<String, dynamic>?) ?? {};

                return ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    const Text(
                      'Tap on a document to capture and upload.',
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildDocTile(
                      'Aadhaar Card',
                      docsMap['Aadhaar Card'],
                      Icons.badge,
                    ),
                    _buildDocTile(
                      'PAN Card',
                      docsMap['PAN Card'],
                      Icons.credit_card,
                    ),
                    _buildDocTile(
                      'RC (Registration)',
                      docsMap['RC'],
                      Icons.description,
                    ),
                    _buildDocTile(
                      'Insurance',
                      docsMap['Insurance'],
                      Icons.verified_user,
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildDocTile(String title, String? url, IconData icon) {
    bool isUploaded = url != null && url.isNotEmpty;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(
          icon,
          color: isUploaded ? Colors.green : Colors.grey,
          size: 30,
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          isUploaded ? 'Uploaded (Verified)' : 'Not uploaded',
          style: TextStyle(
            color: isUploaded ? Colors.green : Colors.red,
            fontWeight: isUploaded ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        trailing: isUploaded
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.camera_alt, color: Colors.blue),
        onTap: () {
          if (!isUploaded) {
            _uploadDocument(title);
          } else {
            // Agar uploaded hai toh usko badi screen par dikhao
            showDialog(
              context: context,
              builder: (_) => AlertDialog(
                content: Image.network(url),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                ],
              ),
            );
          }
        },
      ),
    );
  }
}
