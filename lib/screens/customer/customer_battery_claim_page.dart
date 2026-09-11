import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerBatteryClaimPage extends StatefulWidget {
  const CustomerBatteryClaimPage({super.key});

  @override
  State<CustomerBatteryClaimPage> createState() =>
      _CustomerBatteryClaimPageState();
}

class _CustomerBatteryClaimPageState extends State<CustomerBatteryClaimPage> {
  final issueController = TextEditingController();
  bool submitting = false;

  @override
  void dispose() {
    issueController.dispose();
    super.dispose();
  }

  Future<void> submitClaim(String customerName, String vehicleNumber) async {
    final issue = issueController.text.trim();
    if (issue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please describe the battery issue.')),
      );
      return;
    }

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => submitting = true);

    try {
      await FirebaseFirestore.instance.collection('battery_claims').add({
        'customerId': user.uid,
        'customerName': customerName,
        'vehicleNumber': vehicleNumber,
        'issueDescription': issue,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      issueController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Battery claim submitted successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to submit claim: $e')));
    } finally {
      if (mounted) setState(() => submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Battery Warranty & Claims')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data?.data() ?? {};
          final customerName = data['name']?.toString() ?? 'Customer';
          final vehicleNumber = data['vehicleNumber']?.toString() ?? 'N/A';
          final batteryDetails = data['batteryDetails']?.toString() ?? 'N/A';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: Colors.amber.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.battery_charging_full,
                            color: Colors.amber,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Battery Information',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text('Specs / Serial: $batteryDetails'),
                      const SizedBox(height: 4),
                      Text('Registered Vehicle: $vehicleNumber'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'Submit a Replacement / Service Claim',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: issueController,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText:
                      'Describe the issue (e.g. low backup, not charging)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: submitting
                      ? null
                      : () => submitClaim(customerName, vehicleNumber),
                  icon: const Icon(Icons.send),
                  label: submitting
                      ? const CircularProgressIndicator()
                      : const Text('Submit Claim Request'),
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'Claim Status History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('battery_claims')
                    .where('customerId', isEqualTo: user.uid)
                    .snapshots(),
                builder: (context, claimSnap) {
                  if (claimSnap.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final claims = claimSnap.data?.docs ?? [];
                  if (claims.isEmpty) {
                    return const Text(
                      'No past claim requests found.',
                      style: TextStyle(color: Colors.grey),
                    );
                  }

                  return Column(
                    children: claims.map((doc) {
                      final cData = doc.data();
                      final status = cData['status']?.toString() ?? 'Pending';
                      final issue = cData['issueDescription']?.toString() ?? '';

                      Color statusColor = Colors.orange;
                      if (status == 'Approved') statusColor = Colors.green;
                      if (status == 'Rejected') statusColor = Colors.red;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(issue),
                          subtitle: Text('Status: $status'),
                          trailing: Icon(
                            Icons.circle,
                            color: statusColor,
                            size: 14,
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
