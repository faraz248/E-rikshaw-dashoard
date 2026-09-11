import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../../services/cloudinary_service.dart';

class CustomerDocumentsPage extends StatefulWidget {
  final String customerId; // Firestore customer document ID

  const CustomerDocumentsPage({super.key, required this.customerId});

  @override
  State<CustomerDocumentsPage> createState() => _CustomerDocumentsPageState();
}

class _CustomerDocumentsPageState extends State<CustomerDocumentsPage> {
  final ImagePicker _picker = ImagePicker();
  String uploadingType = ''; // Track which document is currently uploading

  Future<void> _uploadDocument(String docType) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => uploadingType = docType);
      Uint8List bytes = await image.readAsBytes();
      String fileName = '${widget.customerId}_$docType${image.name}';

      // Upload to Cloudinary
      String? downloadUrl = await CloudinaryService.uploadFile(bytes, fileName);

      if (downloadUrl != null) {
        // Update specific document field in Firestore
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId)
            .update({
              'documents.$docType': downloadUrl,
              'updatedAt': FieldValue.serverTimestamp(),
            });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$docType Uploaded Successfully!')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload Failed. Try again.')),
        );
      }
    } catch (e) {
      debugPrint('Error uploading doc: $e');
    } finally {
      if (mounted) setState(() => uploadingType = '');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Documents')),
      body: StreamBuilder<DocumentSnapshot>(
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
          final documents = data['documents'] as Map<String, dynamic>? ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildDocTile(
                title: 'Aadhaar Card',
                icon: Icons.badge,
                docKey: 'aadhaar',
                url: documents['aadhaar'],
              ),
              _buildDocTile(
                title: 'PAN Card',
                icon: Icons.credit_card,
                docKey: 'pan',
                url: documents['pan'],
              ),
              _buildDocTile(
                title: 'RC (Registration Certificate)',
                icon: Icons.directions_car,
                docKey: 'rc',
                url: documents['rc'],
              ),
              _buildDocTile(
                title: 'Insurance',
                icon: Icons.security,
                docKey: 'insurance',
                url: documents['insurance'],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDocTile({
    required String title,
    required IconData icon,
    required String docKey,
    String? url,
  }) {
    bool isUploadingThis = uploadingType == docKey;
    bool isUploaded = url != null && url.isNotEmpty;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 30, color: Colors.blue),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(
          isUploaded ? 'Uploaded (Tap to view/change)' : 'Not uploaded',
          style: TextStyle(color: isUploaded ? Colors.green : Colors.grey),
        ),
        trailing: isUploadingThis
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ElevatedButton(
                onPressed: () => _uploadDocument(docKey),
                child: Text(isUploaded ? 'Update' : 'Upload'),
              ),
        onTap: isUploaded
            ? () {
                showDialog(
                  context: context,
                  builder: (context) => Dialog(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AppBar(
                          title: Text(title),
                          automaticallyImplyLeading: false,
                          actions: [
                            IconButton(
                              icon: const Icon(Icons.close),
                              onPressed: () => Navigator.pop(context),
                            ),
                          ],
                        ),
                        Image.network(url),
                      ],
                    ),
                  ),
                );
              }
            : null,
      ),
    );
  }
}
