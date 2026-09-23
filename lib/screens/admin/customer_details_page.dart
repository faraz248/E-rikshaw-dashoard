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

    // Auto-calculate Balance Logic
    void updateBalance() {
      final total = double.tryParse(totalC.text) ?? 0;
      final rcv = double.tryParse(rcvC.text) ?? 0;
      balC.text = (total - rcv).toString();
    }

    totalC.addListener(updateBalance);
    rcvC.addListener(updateBalance);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
                  decoration: const InputDecoration(labelText: 'Father Name')),
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
                  decoration: const InputDecoration(labelText: 'Total Amount')),
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
                'fatherName': fnameC.text.trim(),
                'phone': phoneC.text.trim(),
                'address': addrC.text.trim(),
                'purchaseDate': dateC.text.trim(),
                'vehicleNumber': rcC.text.trim(),
                'batteryModel': bModelC.text.trim(),
                'batteryNo': bNumC.text.trim(),
                'vehicleModel': vModelC.text.trim(),
                'totalAmount': double.tryParse(totalC.text) ?? 0,
                'receivedAmount': double.tryParse(rcvC.text) ?? 0,
                'pendingAmount': double.tryParse(balC.text) ?? 0,
              });
              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Save Details',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
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
              if (!mounted) return;
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to dashboard
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
        title: Text(widget.customerData['name'] ?? 'N/A',
            style: const TextStyle(color: Colors.black87)),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
            tooltip: 'Delete Customer',
            onPressed: _confirmDeleteCustomer,
          )
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
            if (!snapshot.data!.exists)
              return const Center(child: Text('Customer Deleted'));

            final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final docs = data['documents'] as Map<String, dynamic>? ?? {};

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
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
                const Text('All Documents (Admin Access)',
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
                    title: 'Charger Photo',
                    docKey: 'charger_photo',
                    url: docs['charger_photo'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Battery Photo',
                    docKey: 'battery_photo',
                    url: docs['battery_photo'],
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
                PhotoUploadCard(
                    title: 'Chassis Photo',
                    docKey: 'chassis_photo',
                    url: docs['chassis_photo'],
                    canUpload: true,
                    customerId: widget.customerId),
                PhotoUploadCard(
                    title: 'Delivery Photo',
                    docKey: 'delivery_photo',
                    url: docs['delivery_photo'],
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
                    title: 'DL/Bijli Bill/Niwas',
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
