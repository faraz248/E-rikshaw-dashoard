import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:firebase_storage/firebase_storage.dart';

class CustomerDocumentsPage extends StatefulWidget {
  final String customerId;

  const CustomerDocumentsPage({super.key, required this.customerId});

  @override
  State<CustomerDocumentsPage> createState() => _CustomerDocumentsPageState();
}

class _CustomerDocumentsPageState extends State<CustomerDocumentsPage> {
  final ImagePicker _picker = ImagePicker();
  bool _isUploading = false;

  // Future method actual upload ke liye
  Future<void> _uploadDocument(String docType) async {
    try {
      // 1. Pick Image
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality:
            50, // Image compress kar rahe hain taaki cloud jaldi bhare nahi
      );

      if (image == null) return; // User ne cancel kar diya

      setState(() => _isUploading = true);

      // --- MOCK UPLOAD LOGIC ---
      // Real upload ke liye tujhe FirebaseStorage lagana padega.
      // Abhi ke liye hum sirf Firestore me document ka naam update kar rahe hain fake URL ke sath.
      await Future.delayed(
        const Duration(seconds: 2),
      ); // Simulating upload time
      String fakeUrl = "https://fakeurl.com/${image.name}";

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({'documents.$docType': fakeUrl});

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
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
                    'Uploading Document...',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('customers')
                  .doc(widget.customerId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return const Center(child: Text('Customer data not found.'));
                }

                final data = snapshot.data!.data() as Map<String, dynamic>;
                // Defaulting to empty map if documents field doesn't exist
                final docsMap =
                    (data['documents'] as Map<String, dynamic>?) ?? {};

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
            // TODO: Implement viewing the document
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Document viewing logic will be implemented here.',
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
