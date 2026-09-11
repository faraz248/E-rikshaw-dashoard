import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerEditPage extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic> initialData;

  const CustomerEditPage({
    super.key,
    required this.customerId,
    required this.initialData,
  });

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  late TextEditingController nameController;
  late TextEditingController phoneController;
  late TextEditingController addressController;
  late TextEditingController vehicleNumberController;
  late TextEditingController chassisNumberController;
  late TextEditingController vehicleModelController;
  late TextEditingController batteryDetailsController;
  late TextEditingController emiDetailsController;
  late TextEditingController serviceHistoryController;

  bool saving = false;

  @override
  void initState() {
    super.initState();
    final d = widget.initialData;
    nameController = TextEditingController(text: d['name'] ?? d['Name'] ?? '');
    phoneController = TextEditingController(
      text: d['phone'] ?? d['Phone'] ?? '',
    );
    addressController = TextEditingController(
      text: d['address'] ?? d['Address'] ?? '',
    );
    vehicleNumberController = TextEditingController(
      text: d['vehicleNumber'] ?? d['Vehicle Number'] ?? '',
    );
    chassisNumberController = TextEditingController(
      text: d['chassisNumber'] ?? d['Chassis Number'] ?? '',
    );
    vehicleModelController = TextEditingController(
      text: d['vehicleModel'] ?? d['Vehicle Model'] ?? '',
    );
    batteryDetailsController = TextEditingController(
      text: d['batteryDetails'] ?? d['Battery Details'] ?? '',
    );
    emiDetailsController = TextEditingController(
      text: d['emiDetails'] ?? d['Emi Details'] ?? '',
    );
    serviceHistoryController = TextEditingController(
      text: d['serviceHistory'] ?? d['Service History'] ?? '',
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    vehicleNumberController.dispose();
    chassisNumberController.dispose();
    vehicleModelController.dispose();
    batteryDetailsController.dispose();
    emiDetailsController.dispose();
    serviceHistoryController.dispose();
    super.dispose();
  }

  Future<void> saveChanges() async {
    setState(() => saving = true);

    try {
      final updatedData = {
        'name': nameController.text.trim(),
        'phone': phoneController.text.trim(),
        'address': addressController.text.trim(),
        'vehicleNumber': vehicleNumberController.text.trim(),
        'chassisNumber': chassisNumberController.text.trim(),
        'vehicleModel': vehicleModelController.text.trim(),
        'batteryDetails': batteryDetailsController.text.trim(),
        'emiDetails': emiDetailsController.text.trim(),
        'serviceHistory': serviceHistoryController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(widget.customerId)
          .update(updatedData);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Customer details updated successfully!')),
      );
      Navigator.pop(context, updatedData);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update failed: $e')));
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  InputDecoration inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: saving ? null : saveChanges,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: inputDeco('Name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: phoneController,
              decoration: inputDeco('Phone'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: addressController,
              decoration: inputDeco('Address'),
              maxLines: 2,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vehicleNumberController,
              decoration: inputDeco('Vehicle Number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: chassisNumberController,
              decoration: inputDeco('Chassis Number'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: vehicleModelController,
              decoration: inputDeco('Vehicle Model'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: batteryDetailsController,
              decoration: inputDeco('Battery Details'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: emiDetailsController,
              decoration: inputDeco('EMI Details'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: serviceHistoryController,
              decoration: inputDeco('Service History'),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saving ? null : saveChanges,
                child: saving
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Save Changes',
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
