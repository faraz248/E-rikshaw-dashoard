import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEditCustomerPage extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic> customerData;

  const AdminEditCustomerPage({
    super.key,
    required this.customerId,
    required this.customerData,
  });

  @override
  State<AdminEditCustomerPage> createState() => _AdminEditCustomerPageState();
}

class _AdminEditCustomerPageState extends State<AdminEditCustomerPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController vehicleController;
  late TextEditingController chassisController;
  late TextEditingController addressController;
  late TextEditingController pendingDuesController;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // Purane data se controllers ko pre-fill kar rahe hain
    nameController = TextEditingController(
      text: widget.customerData['name'] ?? '',
    );
    phoneController = TextEditingController(
      text: widget.customerData['phone'] ?? '',
    );
    vehicleController = TextEditingController(
      text: widget.customerData['vehicleNumber'] ?? '',
    );
    chassisController = TextEditingController(
      text: widget.customerData['chassisNumber'] ?? '',
    );
    addressController = TextEditingController(
      text: widget.customerData['address'] ?? '',
    );
    pendingDuesController = TextEditingController(
      text: widget.customerData['pendingAmount']?.toString() ?? '0',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    vehicleController.dispose();
    chassisController.dispose();
    addressController.dispose();
    pendingDuesController.dispose();
    super.dispose();
  }

  Future<void> _updateCustomer() async {
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name aur Phone number zaroori hai!')),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update({
            'name': name,
            'phone': phone,
            'vehicleNumber': vehicleController.text.trim(),
            'chassisNumber': chassisController.text.trim(),
            'address': addressController.text.trim(),
            'pendingAmount':
                double.tryParse(pendingDuesController.text.trim()) ?? 0.0,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer Details Updated Successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Customer Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
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
              controller: chassisController,
              decoration: const InputDecoration(
                labelText: 'Chassis Number',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: pendingDuesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pending Dues Amount (₹)',
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
                onPressed: isLoading ? null : _updateCustomer,
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Update Customer',
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
