import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminServiceHistoryPage extends StatefulWidget {
  final String customerId;
  final String customerName;

  const AdminServiceHistoryPage({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  @override
  State<AdminServiceHistoryPage> createState() =>
      _AdminServiceHistoryPageState();
}

class _AdminServiceHistoryPageState extends State<AdminServiceHistoryPage> {
  final _serviceTypeController = TextEditingController(text: 'Routine Service');
  final _descriptionController = TextEditingController();
  final _mechanicController = TextEditingController();
  final _costController = TextEditingController(text: '0');

  bool _isBatteryClaim = false;
  final _oldBatteryNoController = TextEditingController();
  final _newBatteryNoController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _serviceTypeController.dispose();
    _descriptionController.dispose();
    _mechanicController.dispose();
    _costController.dispose();
    _oldBatteryNoController.dispose();
    _newBatteryNoController.dispose();
    super.dispose();
  }

  void _openAddServiceDialog() {
    _descriptionController.clear();
    _mechanicController.clear();
    _costController.text = '0';
    _oldBatteryNoController.clear();
    _newBatteryNoController.clear();
    _isBatteryClaim = false;

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New Service & Repair Entry',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _serviceTypeController.text,
                  decoration: InputDecoration(
                    labelText: 'Service Category',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  items: [
                    'Routine Service',
                    'Battery Warranty Replacement',
                    'Motor / Controller Repair',
                    'Brake / Suspension Work',
                    'Accidental / Body Repair',
                    'Other'
                  ]
                      .map((s) => DropdownMenuItem(
                          value: s,
                          child: Text(s, style: const TextStyle(fontSize: 13))))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() {
                        _serviceTypeController.text = val;
                        _isBatteryClaim =
                            (val == 'Battery Warranty Replacement');
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),
                if (_isBatteryClaim) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade300),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Battery Replacement Protocol',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                              color: Colors.brown),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _oldBatteryNoController,
                          decoration: const InputDecoration(
                            labelText: 'Defective / Old Battery Serial No',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: _newBatteryNoController,
                          decoration: const InputDecoration(
                            labelText: 'New Replaced Battery Serial No',
                            isDense: true,
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                TextField(
                  controller: _descriptionController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Work Done / Parts Replaced',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _mechanicController,
                  decoration: InputDecoration(
                    labelText: 'Mechanic Name / Technician',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Total Bill Amount (₹) [0 if Free Warranty]',
                    prefixIcon: const Icon(Icons.currency_rupee),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: _isSaving
                  ? null
                  : () async {
                      if (_descriptionController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Work details bharna zaroori hai')),
                        );
                        return;
                      }

                      setDialogState(() => _isSaving = true);
                      Navigator.pop(dialogCtx);

                      final double cost =
                          double.tryParse(_costController.text.trim()) ?? 0.0;

                      await FirebaseFirestore.instance
                          .collection('Customers')
                          .doc(widget.customerId)
                          .collection('ServiceHistory')
                          .add({
                        'serviceType': _serviceTypeController.text,
                        'description': _descriptionController.text.trim(),
                        'mechanic': _mechanicController.text.trim().isEmpty
                            ? 'Showroom Tech'
                            : _mechanicController.text.trim(),
                        'cost': cost,
                        'isBatteryClaim': _isBatteryClaim,
                        'oldBatterySerial': _oldBatteryNoController.text.trim(),
                        'newBatterySerial': _newBatteryNoController.text.trim(),
                        'createdAt': FieldValue.serverTimestamp(),
                      });

                      if (_isBatteryClaim &&
                          _newBatteryNoController.text.trim().isNotEmpty) {
                        await FirebaseFirestore.instance
                            .collection('Customers')
                            .doc(widget.customerId)
                            .set({
                          'batteryNo': _newBatteryNoController.text.trim(),
                        }, SetOptions(merge: true));
                      }

                      if (!mounted) return;
                      ScaffoldMessenger.of(this.context).showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF0F766E),
                          content: Text('Service record add ho gaya!'),
                        ),
                      );
                    },
              child: const Text('Save Record'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text('Service Tracker: ${widget.customerName}'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        icon: const Icon(Icons.build, color: Colors.white),
        label: const Text('Add Service Entry',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _openAddServiceDialog,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Customers')
            .doc(widget.customerId)
            .collection('ServiceHistory')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = snapshot.data?.docs ?? [];
          if (records.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.handyman_outlined, size: 54, color: Colors.grey),
                  SizedBox(height: 12),
                  Text(
                    'Abhi tak koi service record darj nahi hai.',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final item = records[index].data();
              final type = item['serviceType'] ?? 'Service';
              final desc = item['description'] ?? 'N/A';
              final mechanic = item['mechanic'] ?? 'Showroom Staff';
              final double cost =
                  double.tryParse((item['cost'] ?? 0).toString()) ?? 0.0;
              final bool isBatt = item['isBatteryClaim'] == true;
              final oldBatt = item['oldBatterySerial'] ?? '';
              final newBatt = item['newBatterySerial'] ?? '';

              final ts = item['createdAt'] as Timestamp?;
              final dateStr = ts != null
                  ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
                  : 'Recent';

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color:
                        isBatt ? Colors.amber.shade400 : Colors.grey.shade300,
                    width: isBatt ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isBatt
                                  ? Icons.battery_alert
                                  : Icons.build_circle_outlined,
                              color: isBatt
                                  ? Colors.amber.shade800
                                  : const Color(0xFF0F766E),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              type,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                        Text(
                          dateStr,
                          style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const Divider(height: 18),
                    Text(
                      desc,
                      style: const TextStyle(
                          fontSize: 13, color: Color(0xFF0F172A)),
                    ),
                    if (isBatt) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.amber.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Old Serial: $oldBatt ➔ New Replacement: $newBatt',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Mechanic: $mechanic',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                        Text(
                          cost == 0
                              ? 'FREE (Warranty)'
                              : 'Charge: ₹${cost.toStringAsFixed(0)}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: cost == 0
                                ? Colors.green.shade700
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
