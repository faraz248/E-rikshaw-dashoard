import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../widgets/photo_upload_card.dart';

class AdminCustomerDetailView extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic> customerData;

  const AdminCustomerDetailView(
      {super.key, required this.customerId, required this.customerData});

  @override
  State<AdminCustomerDetailView> createState() =>
      _AdminCustomerDetailViewState();
}

class _AdminCustomerDetailViewState extends State<AdminCustomerDetailView> {
  void _viewImageFullScreen(String url) {
    if (url.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(10),
        child: Stack(
          alignment: Alignment.center,
          children: [
            InteractiveViewer(
                panEnabled: true,
                minScale: 0.5,
                maxScale: 4,
                child: Image.network(url, fit: BoxFit.contain)),
            Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                    icon:
                        const Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context)))
          ],
        ),
      ),
    );
  }

  void _showFullEditDialog(Map<String, dynamic> data) {
    final nameC = TextEditingController(text: data['name']);
    final chassisC = TextEditingController(text: data['chassisNumber']);
    final fnameC = TextEditingController(text: data['fatherName']);
    final phoneC = TextEditingController(text: data['phone']);
    final addrC = TextEditingController(text: data['address']);
    final dateC = TextEditingController(text: data['purchaseDate']);
    final rcC = TextEditingController(text: data['vehicleNumber']);
    final bModelC = TextEditingController(text: data['batteryModel']);
    final bNumC = TextEditingController(text: data['batteryNo']);
    final totalC =
        TextEditingController(text: data['totalAmount']?.toString() ?? '0');
    final rcvC =
        TextEditingController(text: data['receivedAmount']?.toString() ?? '0');
    final balC =
        TextEditingController(text: data['pendingAmount']?.toString() ?? '0');
    final vModelC = TextEditingController(text: data['vehicleModel']);

    // Naya Battery Type Logic
    String selectedBatteryType = data['batteryType'] ?? 'Lead-Acid';

    void updateBalance() {
      final total = double.tryParse(totalC.text) ?? 0;
      final rcv = double.tryParse(rcvC.text) ?? 0;
      balC.text = (total - rcv).toString();
    }

    totalC.addListener(updateBalance);
    rcvC.addListener(updateBalance);

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(builder: (context, setStateDialog) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Edit All Specifications',
              style: TextStyle(color: Colors.black87)),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView(
              shrinkWrap: true,
              children: [
                TextField(
                    controller: nameC,
                    decoration: const InputDecoration(labelText: 'Owner Name')),
                TextField(
                    controller: fnameC,
                    decoration:
                        const InputDecoration(labelText: 'Father Name')),
                TextField(
                    controller: phoneC,
                    decoration: const InputDecoration(labelText: 'Mobile No')),
                TextField(
                    controller: addrC,
                    decoration: const InputDecoration(labelText: 'Address')),
                TextField(
                    controller: dateC,
                    decoration:
                        const InputDecoration(labelText: 'Date of Purchase')),
                TextField(
                    controller: vModelC,
                    decoration:
                        const InputDecoration(labelText: 'Vehicle Model')),
                TextField(
                    controller: chassisC,
                    decoration: const InputDecoration(labelText: 'Chassis No')),
                TextField(
                    controller: rcC,
                    decoration:
                        const InputDecoration(labelText: 'Registration No')),

                // Dropdown for Battery Type
                DropdownButtonFormField<String>(
                  value: selectedBatteryType,
                  decoration: const InputDecoration(labelText: 'Battery Type'),
                  items: ['Lead-Acid', 'Lithium-Ion']
                      .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (val) =>
                      setStateDialog(() => selectedBatteryType = val!),
                ),

                TextField(
                    controller: bModelC,
                    decoration:
                        const InputDecoration(labelText: 'Battery Model')),
                TextField(
                    controller: bNumC,
                    decoration: const InputDecoration(labelText: 'Battery No')),
                TextField(
                    controller: totalC,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Total Amount')),
                TextField(
                    controller: rcvC,
                    keyboardType: TextInputType.number,
                    decoration:
                        const InputDecoration(labelText: 'Received Amount')),
                TextField(
                    controller: balC,
                    readOnly: true,
                    decoration: const InputDecoration(
                        labelText: 'Balance (Auto)',
                        filled: true,
                        fillColor: Colors.black12)),
              ],
            ),
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
                  'name': nameC.text.trim(),
                  'chassisNumber': chassisC.text.trim(),
                  'fatherName': fnameC.text.trim(), 'phone': phoneC.text.trim(),
                  'address': addrC.text.trim(),
                  'purchaseDate': dateC.text.trim(),
                  'vehicleNumber': rcC.text.trim(),
                  'batteryModel': bModelC.text.trim(),
                  'batteryNo': bNumC.text.trim(),
                  'vehicleModel': vModelC.text.trim(),
                  'batteryType': selectedBatteryType, // Saving new field
                  'totalAmount': double.tryParse(totalC.text) ?? 0,
                  'receivedAmount': double.tryParse(rcvC.text) ?? 0,
                  'pendingAmount': double.tryParse(balC.text) ?? 0,
                });
                if (!context.mounted) return;
                Navigator.pop(context);
              },
              child: const Text('Save Details',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      }),
    );
  }

  void _confirmDeleteCustomer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:
            const Text('Delete Customer?', style: TextStyle(color: Colors.red)),
        content: const Text(
            'This will permanently delete this customer and all their ledger data. Proceed?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(widget.customerId)
                  .delete();
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
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
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text('Customer Profile',
            style: TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
              icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
              tooltip: 'Delete',
              onPressed: _confirmDeleteCustomer)
        ],
      ),
      body: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('customers')
              .doc(widget.customerId)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.data!.exists) {
              return const Center(child: Text('Customer Deleted'));
            }

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final docs = data['documents'] as Map<String, dynamic>? ?? {};
            final profilePhoto = data['profilePhoto'] ?? '';
            final batteryType =
                data['batteryType'] ?? 'Lead-Acid'; // Default is Lead-Acid

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // PROFILE PHOTO WITH ZOOM FEATURE
                Center(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _viewImageFullScreen(profilePhoto),
                        child: CircleAvatar(
                          radius: 55,
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: profilePhoto.isNotEmpty
                              ? NetworkImage(profilePhoto)
                              : null,
                          child: profilePhoto.isEmpty
                              ? const Icon(Icons.person,
                                  size: 50, color: Colors.grey)
                              : null,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(data['name'] ?? 'N/A',
                          style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87)),
                      Text(data['phone'] ?? '',
                          style: const TextStyle(
                              fontSize: 16, color: Colors.grey)),
                      if (profilePhoto.isNotEmpty)
                        const Text('(Tap photo to zoom)',
                            style: TextStyle(fontSize: 12, color: Colors.teal)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Registration & Specs',
                              style: TextStyle(
                                  color: Colors.teal,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                          IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _showFullEditDialog(data)),
                        ],
                      ),
                      const Divider(),
                      _buildInfoRow('Chassis No.', data['chassisNumber']),
                      _buildInfoRow('Father Name', data['fatherName']),
                      _buildInfoRow('Address', data['address']),
                      _buildInfoRow('Date of Purchase', data['purchaseDate']),
                      _buildInfoRow(
                          'Registration No (RC)', data['vehicleNumber']),
                      _buildInfoRow('Battery Type', batteryType,
                          isBold: true), // SHOWING BATTERY TYPE
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

                const Text('Identity Documents (Admin Access)',
                    style: TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                PhotoUploadCard(
                    title: 'Customer Photo (Profile)',
                    docKey: 'profilePhoto',
                    url: data['profilePhoto'],
                    canUpload: true,
                    customerId: widget.customerId),
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
                    title: 'DL / Electricity Receipt / Domicile',
                    docKey: 'address_proof',
                    url: docs['address_proof'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Signature',
                    docKey: 'signature',
                    url: docs['signature'],
                    canUpload: true,
                    customerId: widget.customerId),

                const SizedBox(height: 15),
                Text('Vehicle & $batteryType Docs',
                    style: const TextStyle(
                        color: Colors.teal, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                PhotoUploadCard(
                    title: 'Charger Photo',
                    docKey: 'charger_photo',
                    url: docs['charger_photo'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Charger Warranty Card',
                    docKey: 'charger_warranty',
                    url: docs['charger_warranty'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Battery Warranty Card',
                    docKey: 'battery_warranty',
                    url: docs['battery_warranty'],
                    canUpload: true,
                    customerId: widget.customerId),

                // CONDITIONAL BATTERY PHOTOS BASED ON TYPE
                if (batteryType == 'Lithium-Ion') ...[
                  PhotoUploadCard(
                      title: 'Lithium Battery Photo',
                      docKey: 'battery_1_photo',
                      url: docs['battery_1_photo'],
                      canUpload: true,
                      customerId: widget.customerId),
                ] else ...[
                  PhotoUploadCard(
                      title: 'Battery 1 Photo',
                      docKey: 'battery_1_photo',
                      url: docs['battery_1_photo'],
                      canUpload: true,
                      customerId: widget.customerId),
                  PhotoUploadCard(
                      title: 'Battery 2 Photo',
                      docKey: 'battery_2_photo',
                      url: docs['battery_2_photo'],
                      canUpload: true,
                      customerId: widget.customerId),
                  PhotoUploadCard(
                      title: 'Battery 3 Photo',
                      docKey: 'battery_3_photo',
                      url: docs['battery_3_photo'],
                      canUpload: true,
                      customerId: widget.customerId),
                  PhotoUploadCard(
                      title: 'Battery 4 Photo',
                      docKey: 'battery_4_photo',
                      url: docs['battery_4_photo'],
                      canUpload: true,
                      customerId: widget.customerId),
                ],

                PhotoUploadCard(
                    title: 'Chassis Photo',
                    docKey: 'chassis_photo',
                    url: docs['chassis_photo'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Delivery Photo (Front)',
                    docKey: 'delivery_front',
                    url: docs['delivery_front'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Delivery Photo (Back)',
                    docKey: 'delivery_back',
                    url: docs['delivery_back'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Delivery Photo (Left Side)',
                    docKey: 'delivery_left',
                    url: docs['delivery_left'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Delivery Photo (Right Side)',
                    docKey: 'delivery_right',
                    url: docs['delivery_right'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Invoice',
                    docKey: 'invoice',
                    url: docs['invoice'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'RC Document',
                    docKey: 'rc_doc',
                    url: docs['rc_doc'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Insurance',
                    docKey: 'insurance',
                    url: docs['insurance'],
                    canUpload: true,
                    customerId: widget.customerId),
              ],
            );
          }),
    );
  }

  Widget _buildInfoRow(String label, dynamic value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
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
