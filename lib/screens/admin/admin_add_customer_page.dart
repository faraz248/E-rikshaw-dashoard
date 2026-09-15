import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminAddCustomerPage extends StatefulWidget {
  const AdminAddCustomerPage({super.key});

  @override
  State<AdminAddCustomerPage> createState() => _AdminAddCustomerPageState();
}

class _AdminAddCustomerPageState extends State<AdminAddCustomerPage> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  
  File? _imageFile;
  bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    vehicleNumberController.dispose();
    super.dispose();
  }

  // Pick Image Logic
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery, 
      imageQuality: 60, // Compress image to save cloud space
    );
    
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  // Upload and Save Logic
  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a photo first!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isUploading = true);

    try {
      // 1. Upload Image to Firebase Storage
      final String fileName = 'customers/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference storageRef = FirebaseStorage.instance.ref().child(fileName);
      final UploadTask uploadTask = storageRef.putFile(_imageFile!);
      
      final TaskSnapshot snapshot = await uploadTask;
      final String imageUrl = await snapshot.ref.getDownloadURL();

      // 2. Save Data to Firestore
      await FirebaseFirestore.instance.collection('customers').add({
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'vehicleNumber': vehicleNumberController.text.trim(),
        'profileImageUrl': imageUrl,
        'pendingAmount': 0,
        'paidEmi': 0,
        'totalEmi': 0,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer Added Successfully!'), backgroundColor: Colors.green),
      );
      Navigator.pop(context); // Go back to dashboard

    } catch (e) {
      debugPrint("Error saving customer: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Offline Customer'),
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
                  Text('Uploading Data & Image...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Image Picker UI
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 150,
                        width: 150,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: _imageFile != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(_imageFile!, fit: BoxFit.cover),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt, size: 40, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to add photo', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Input Fields
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder(), prefixIcon: Icon(Icons.person)),
                      validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.phone)),
                      validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: vehicleNumberController,
                      decoration: const InputDecoration(labelText: 'Vehicle Number', border: OutlineInputBorder(), prefixIcon: Icon(Icons.electric_rickshaw)),
                      validator: (val) => val == null || val.isEmpty ? 'Vehicle Number is required' : null,
                    ),
                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton.icon(
                        onPressed: _saveCustomer,
                        icon: const Icon(Icons.save),
                        label: const Text('Save Customer', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}