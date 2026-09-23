import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/admin_model.dart';
import '../services/auth_service.dart';
import 'shop_customer_list_screen.dart';
import 'login_screen.dart';

class AdminDashboardScreen extends StatefulWidget {
  final AdminModel admin;

  const AdminDashboardScreen({super.key, required this.admin});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  late AdminModel _admin;
  final AuthService _authService = AuthService();
  bool _isUploadingPhoto = false;

  @override
  void initState() {
    super.initState();
    _admin = widget.admin;
  }

  Future<void> _updatePhoto() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 70,
    );

    if (picked != null) {
      setState(() => _isUploadingPhoto = true);
      try {
        final newUrl = await _authService.updateAdminProfilePhoto(
          _admin.uid,
          File(picked.path),
        );
        setState(() {
          _admin = AdminModel(
            uid: _admin.uid,
            name: _admin.name,
            email: _admin.email,
            shopId: _admin.shopId,
            shopName: _admin.shopName,
            photoUrl: newUrl,
            role: _admin.role,
          );
        });
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
        }
      } finally {
        if (mounted) setState(() => _isUploadingPhoto = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_admin.shopName),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final nav = Navigator.of(context);
              await _authService.signOut();
              if (mounted) {
                nav.pushReplacement(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: _admin.photoUrl != null
                              ? NetworkImage(_admin.photoUrl!)
                              : null,
                          child: _admin.photoUrl == null
                              ? const Icon(Icons.person, size: 40)
                              : null,
                        ),
                        Positioned(
                          bottom: -4,
                          right: -4,
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              size: 20,
                              color: Colors.blue,
                            ),
                            onPressed: _isUploadingPhoto ? null : _updatePhoto,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _admin.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            _admin.email,
                            style: const TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Shop ID: ${_admin.shopId}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: Colors.grey.shade300),
              ),
              leading: const Icon(
                Icons.people,
                color: Colors.blueAccent,
                size: 30,
              ),
              title: const Text(
                'Customers & EMI Records',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text('Manage entries for ${_admin.shopName}'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ShopCustomerListScreen(
                      shopId: _admin.shopId,
                      shopName: _admin.shopName,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
