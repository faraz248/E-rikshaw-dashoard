import '../../services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddCustomerPage extends StatefulWidget {
  const AdminAddCustomerPage({super.key});

  @override
  State<AdminAddCustomerPage> createState() => _AdminAddCustomerPageState();
}

class _AdminAddCustomerPageState extends State<AdminAddCustomerPage> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final vehicleController = TextEditingController();
  final addressController = TextEditingController();

  String? uploadedImageUrl;
  bool isUploading = false;
  bool loading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    vehicleController.dispose();
    addressController.dispose();
    super.dispose();
  }

  Future<void> pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;

      setState(() => isUploading = true);

      Uint8List bytes = await image.readAsBytes();
      String fileName = image.name;

      String? downloadUrl = await CloudinaryService.uploadFile(bytes, fileName);

      if (downloadUrl != null) {
        setState(() {
          uploadedImageUrl = downloadUrl;
          isUploading = false;
        });
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image Uploaded Successfully!')),
        );
      } else {
        setState(() => isUploading = false);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Upload Failed. Try again.')),
        );
      }
    } catch (e) {
      setState(() => isUploading = false);
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _saveCustomer() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name aur Phone zaroori hai.')),
      );
      return;
    }

    if (uploadedImageUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload a profile photo or document first!')),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance.collection('customers').add({
        'name': name,
        'phone': phone,
        'vehicleNumber': vehicleController.text.trim(),
        'address': addressController.text.trim(),
        'profileImageUrl': uploadedImageUrl,
        'addedByAdmin': true,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Offline Customer Added Successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Offline Customer')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.person_add, size: 60, color: Colors.blue),
            const SizedBox(height: 10),
            const Text(
              'Ye customer bina App ke database me add hoga.',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: uploadedImageUrl == null
                        ? const Center(
                            child: Text(
                              'No Image',
                              style: TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(uploadedImageUrl!, fit: BoxFit.cover),
                          ),
                  ),
                  const SizedBox(height: 8),
                  isUploading
                      ? const CircularProgressIndicator()
                      : TextButton.icon(
                          onPressed: pickAndUploadImage,
                          icon: const Icon(Icons.upload_file),
                          label: const Text('Upload Photo / Aadhaar'),
                        ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vehicleController,
              decoration: const InputDecoration(
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Address',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: (loading || isUploading) ? null : _saveCustomer,
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Save Customer',
                        style: TextStyle(fontSize: 16),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
