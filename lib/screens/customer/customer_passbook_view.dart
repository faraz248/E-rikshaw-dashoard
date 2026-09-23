import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import '../../widgets/photo_upload_card.dart';
import '../auth/unified_login_screen.dart';

class CustomerPassbookView extends StatefulWidget {
  final String customerId;
  const CustomerPassbookView({super.key, required this.customerId});

  @override
  State<CustomerPassbookView> createState() => _CustomerPassbookViewState();
}

class _CustomerPassbookViewState extends State<CustomerPassbookView> {
  bool uploadingProfile = false;

  // TERI IMGBB API KEY YAHAN BHI SET HAI
  final String imgbbApiKey = 'df9cc8a402cdc3b397f324cfc343ebae';

  Future<void> _uploadProfilePhoto() async {
    final picker = ImagePicker();
    final pickedFile =
        await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (pickedFile == null) return;

    setState(() => uploadingProfile = true);
    try {
      final bytes = await pickedFile.readAsBytes();

      // ImgBB API Request
      final uri = Uri.parse('https://api.imgbb.com/1/upload');
      final request = http.MultipartRequest('POST', uri)
        ..fields['key'] = imgbbApiKey
        ..files.add(http.MultipartFile.fromBytes('image', bytes,
            filename: 'profile.jpg'));

      final response = await request.send();

      if (response.statusCode == 200) {
        final resData = await response.stream.bytesToString();
        final jsonMap = jsonDecode(resData);
        final downloadUrl = jsonMap['data']['url'];

        // Firestore database mein URL save
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId)
            .update({'profilePhoto': downloadUrl});
      } else {
        throw Exception('ImgBB Upload Failed');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => uploadingProfile = false);
    }
  }

  void _showCustomerEditDialog(Map<String, dynamic> data) {
    final fnameC = TextEditingController(text: data['fatherName']);
    final addrC = TextEditingController(text: data['address']);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Edit Personal Details',
            style: TextStyle(color: Colors.black87)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and Phone are Read-Only to prevent fraud
            Text('Name: ${data['name'] ?? 'N/A'}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 5),
            Text('Mobile: ${data['phone'] ?? 'N/A'}',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Text('(Name and Mobile cannot be changed)',
                  style: TextStyle(fontSize: 10, color: Colors.redAccent)),
            ),
            const Divider(),
            TextField(
                controller: fnameC,
                decoration: const InputDecoration(labelText: 'Father Name')),
            TextField(
                controller: addrC,
                decoration: const InputDecoration(labelText: 'Address')),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(widget.customerId)
                  .update({
                'fatherName': fnameC.text.trim(),
                'address': addrC.text.trim(),
              });
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text('My Ledger', style: TextStyle(color: Colors.black87)),
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HubLoginPortal())))
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.customerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());
            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final docs = data['documents'] as Map<String, dynamic>? ?? {};
            final profilePhoto = data['profilePhoto'] ?? '';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Profile Section
                Center(
                  child: Column(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: profilePhoto.isNotEmpty
                                ? NetworkImage(profilePhoto)
                                : null,
                            child: profilePhoto.isEmpty && !uploadingProfile
                                ? const Icon(Icons.person,
                                    size: 50, color: Colors.grey)
                                : null,
                          ),
                          if (uploadingProfile)
                            const Positioned.fill(
                                child: CircularProgressIndicator(
                                    color: Colors.teal)),
                          Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                  onTap: _uploadProfilePhoto,
                                  child: Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: const BoxDecoration(
                                          color: Colors.teal,
                                          shape: BoxShape.circle),
                                      child: const Icon(Icons.camera_alt,
                                          size: 16, color: Colors.white)))),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(data['name'] ?? 'N/A',
                              style: const TextStyle(
                                  color: Colors.black87,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                          IconButton(
                            icon: const Icon(Icons.edit,
                                size: 20, color: Colors.blue),
                            onPressed: () => _showCustomerEditDialog(data),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Locked Registration Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Vehicle Registration & Specifications',
                          style: TextStyle(
                              color: Colors.teal,
                              fontWeight: FontWeight.bold,
                              fontSize: 16)),
                      const Divider(),
                      _buildInfoRow('Vehicle Owner Name', data['name']),
                      _buildInfoRow('Chassis No.', data['chassisNumber']),
                      _buildInfoRow('Father Name', data['fatherName']),
                      _buildInfoRow('Mobile No.', data['phone']),
                      _buildInfoRow('Address', data['address']),
                      _buildInfoRow('Date of Purchase', data['purchaseDate']),
                      _buildInfoRow(
                          'Registration No (RC)', data['vehicleNumber']),
                      _buildInfoRow('Battery Model', data['batteryModel']),
                      _buildInfoRow('Battery No.', data['batteryNo']),
                      _buildInfoRow('Vehicle Model', data['vehicleModel']),
                      const Divider(),
                      _buildInfoRow(
                          'Total Amount', '₹${data['totalAmount'] ?? 0}'),
                      _buildInfoRow(
                          'Received Amount', '₹${data['receivedAmount'] ?? 0}'),
                      _buildInfoRow('Balance', '₹${data['pendingAmount'] ?? 0}',
                          isBold: true),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Allowed Uploads for Customer
                const Text('Identity Documents (You Can Upload/Edit)',
                    style: TextStyle(
                        color: Colors.orange, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                PhotoUploadCard(
                    title: 'Aadhar Card',
                    docKey: 'aadhar',
                    url: docs['aadhar'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'PAN Card',
                    docKey: 'pan',
                    url: docs['pan'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'DL/Bijli Bill/Niwas/Ration',
                    docKey: 'address_proof',
                    url: docs['address_proof'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Customer Signature',
                    docKey: 'signature',
                    url: docs['signature'],
                    canUpload: true,
                    customerId: widget.customerId),
                const SizedBox(height: 20),

                // Locked Docs Section
                const Text('Vehicle & Warranty (LOCKED - Admin Only)',
                    style: TextStyle(
                        color: Colors.redAccent, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                PhotoUploadCard(
                    title: 'Charger Photo',
                    docKey: 'charger_photo',
                    url: docs['charger_photo'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Battery Photo',
                    docKey: 'battery_photo',
                    url: docs['battery_photo'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Charger Warranty Card',
                    docKey: 'charger_warranty',
                    url: docs['charger_warranty'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Battery Warranty Card',
                    docKey: 'battery_warranty',
                    url: docs['battery_warranty'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Chassis Photo',
                    docKey: 'chassis_photo',
                    url: docs['chassis_photo'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Delivery Photo',
                    docKey: 'delivery_photo',
                    url: docs['delivery_photo'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Invoice',
                    docKey: 'invoice',
                    url: docs['invoice'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'RC Document',
                    docKey: 'rc_doc',
                    url: docs['rc_doc'],
                    canUpload: false,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Insurance',
                    docKey: 'insurance',
                    url: docs['insurance'],
                    canUpload: false,
                    customerId: widget.customerId),
              ],
            );
          }),
    );
  }

  Widget _buildInfoRow(String label, dynamic value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          Text('${value ?? 'N/A'}',
              style: TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: isBold ? FontWeight.bold : FontWeight.w500)),
        ],
      ),
    );
  }
}
