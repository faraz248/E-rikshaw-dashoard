import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class BatteryClaimsPage extends StatefulWidget {
  final String customerId;
  final String customerName;
  final String batterySerial;

  const BatteryClaimsPage({
    super.key,
    required this.customerId,
    required this.customerName,
    required this.batterySerial,
  });

  @override
  State<BatteryClaimsPage> createState() => _BatteryClaimsPageState();
}

class _BatteryClaimsPageState extends State<BatteryClaimsPage> {
  final _issueController = TextEditingController();
  String _status = 'Pending Inspection';

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  void _showNewClaimDialog() {
    _issueController.clear();
    _status = 'Pending Inspection';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('New Battery Warranty Claim',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Battery Serial: ${widget.batterySerial.isEmpty ? "N/A" : widget.batterySerial}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: _issueController,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Battery Issue / Problem Description',
                  hintText: 'e.g. Mileage dropped to 20km, cell dead',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _status,
                decoration: const InputDecoration(
                    labelText: 'Claim Status', border: OutlineInputBorder()),
                items: [
                  'Pending Inspection',
                  'Sent to Company',
                  'Replaced with New',
                  'Rejected'
                ]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDState(() => _status = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F766E),
                  foregroundColor: Colors.white),
              onPressed: () async {
                if (_issueController.text.trim().isEmpty) return;
                final messenger = ScaffoldMessenger.of(context);
                Navigator.pop(ctx);

                await FirebaseFirestore.instance
                    .collection('Customers')
                    .doc(widget.customerId)
                    .collection('BatteryClaims')
                    .add({
                  'batterySerial': widget.batterySerial,
                  'issue': _issueController.text.trim(),
                  'status': _status,
                  'createdAt': FieldValue.serverTimestamp(),
                });

                messenger.showSnackBar(const SnackBar(
                    backgroundColor: Color(0xFF0F766E),
                    content: Text('Battery Claim submit ho gaya!')));
              },
              child: const Text('Submit Claim'),
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
      appBar: AppBar(title: Text('${widget.customerName} - Battery Claims')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Claim',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _showNewClaimDialog,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('Customers')
            .doc(widget.customerId)
            .collection('BatteryClaims')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
                child: Text('Koi battery warranty claim record nahi hai.',
                    style: TextStyle(color: Colors.grey)));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final d = docs[i].data();
              final issue = (d['issue'] ?? '').toString();
              final status = (d['status'] ?? 'Pending').toString();
              final serial = (d['batterySerial'] ?? 'N/A').toString();

              Color badgeColor = Colors.orange;
              if (status == 'Replaced with New') badgeColor = Colors.green;
              if (status == 'Rejected') badgeColor = Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Color(0xFFE2E8F0),
                    child: Icon(Icons.battery_alert, color: Color(0xFF0F766E)),
                  ),
                  title: Text(issue,
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Serial: $serial'),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                        color: badgeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(status,
                        style: TextStyle(
                            color: badgeColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 12)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
