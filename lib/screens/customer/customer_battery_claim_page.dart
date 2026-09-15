import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomerBatteryClaimPage extends StatefulWidget {
  const CustomerBatteryClaimPage({super.key});

  @override
  State<CustomerBatteryClaimPage> createState() =>
      _CustomerBatteryClaimPageState();
}

class _CustomerBatteryClaimPageState extends State<CustomerBatteryClaimPage> {
  final _issueController = TextEditingController();
  bool _isSubmitting = false;
  String? userId;
  String userName = 'Customer';
  String vehicleNo = 'N/A';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userId = user?.uid;
    _fetchCustomerDetails();
  }

  Future<void> _fetchCustomerDetails() async {
    if (userId == null) return;
    try {
      final doc = await FirebaseFirestore.instance
          .collection('customers')
          .doc(userId)
          .get();
      if (doc.exists && mounted) {
        setState(() {
          userName = doc.data()?['name'] ?? 'Customer';
          vehicleNo = doc.data()?['vehicleNumber'] ?? 'N/A';
        });
      }
    } catch (e) {
      debugPrint("Error fetching details: $e");
    }
  }

  @override
  void dispose() {
    _issueController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim() async {
    final issue = _issueController.text.trim();
    if (issue.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bhai, pehle problem toh likh!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (userId == null) return;

    setState(() => _isSubmitting = true);

    try {
      await FirebaseFirestore.instance.collection('claims').add({
        'customerId': userId,
        'customerName': userName,
        'vehicleNumber': vehicleNo,
        'issueDescription': issue,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      _issueController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Claim Submitted Successfully! Admin will review it.'),
          backgroundColor: Colors.green,
        ),
      );
      FocusScope.of(context).unfocus(); // Keyboard band karne ke liye
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting claim: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (userId == null) {
      return const Scaffold(body: Center(child: Text('Please login first')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Battery Warranty & Claims'),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Vehicle Info Card
            Card(
              color: Colors.orange.shade50,
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.electric_rickshaw, color: Colors.orange),
                        SizedBox(width: 10),
                        Text(
                          'Vehicle Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text('Registered Name: $userName'),
                    Text(
                      'Vehicle No: $vehicleNo',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Claim Submission Form
            const Text(
              'Submit a New Claim',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _issueController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText:
                    'Describe the issue (e.g., Battery not charging, low mileage...)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isSubmitting ? null : _submitClaim,
                icon: _isSubmitting ? const SizedBox() : const Icon(Icons.send),
                label: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Submit Claim',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Past Claims History
            const Text(
              'Your Claim History',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('claims')
                    .where('customerId', isEqualTo: userId)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No past claims found.'));
                  }

                  final claims = snapshot.data!.docs;

                  return ListView.builder(
                    itemCount: claims.length,
                    itemBuilder: (context, index) {
                      final data = claims[index].data() as Map<String, dynamic>;
                      final status = data['status'] ?? 'Pending';
                      final issue = data['issueDescription'] ?? '';

                      Color statusColor = Colors.orange;
                      if (status == 'Approved' || status == 'Completed')
                        statusColor = Colors.green;
                      if (status == 'Rejected') statusColor = Colors.red;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          title: Text(
                            issue,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status,
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
