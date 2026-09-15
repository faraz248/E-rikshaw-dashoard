import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerBatteryWarrantyPage extends StatefulWidget {
  final String customerId;

  const CustomerBatteryWarrantyPage({super.key, required this.customerId});

  @override
  State<CustomerBatteryWarrantyPage> createState() =>
      _CustomerBatteryWarrantyPageState();
}

class _CustomerBatteryWarrantyPageState
    extends State<CustomerBatteryWarrantyPage> {
  final TextEditingController issueController = TextEditingController();
  bool isSubmitting = false;

  @override
  void dispose() {
    issueController.dispose();
    super.dispose();
  }

  Future<void> _submitClaim(String customerName) async {
    final description = issueController.text.trim();
    if (description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kripya issue ke baare me kuch likhein!')),
      );
      return;
    }

    setState(() => isSubmitting = true);

    try {
      // Orders/Claims collection me request bhej rahe hain jo admin panel par dikhegi
      await FirebaseFirestore.instance.collection('orders').add({
        'customerId': widget.customerId,
        'customerName': customerName,
        'type': 'Battery Claim',
        'description': description,
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      issueController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Claim Request Submitted Successfully!')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battery Warranty & Claims')),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Customer data not found.'));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final customerName = data['name'] ?? 'Customer';
          final batterySpecs = data['batteryDetails'] ?? 'N/A (Not Updated)';
          final vehicleNo = data['vehicleNumber'] ?? 'N/A';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Battery Information Card
              Card(
                color: Colors.amber[50],
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.bolt, color: Colors.amber, size: 28),
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
                      const SizedBox(height: 12),
                      Text('Specs / Serial: $batterySpecs'),
                      const SizedBox(height: 4),
                      Text('Registered Vehicle: $vehicleNo'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit Claim Section
              const Text(
                'Submit a Replacement / Service Claim',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: issueController,
                maxLines: 3,
                decoration: const InputDecoration(
                  hintText:
                      'Describe the issue (e.g. low backup, not charging)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () => _submitClaim(customerName),
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.send),
                  label: Text(
                    isSubmitting ? 'Submitting...' : 'Submit Claim Request',
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Past Claims History
              const Text(
                'Claim Status History',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SizedBox(
                height: 200,
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('orders')
                      .where('customerId', isEqualTo: widget.customerId)
                      .snapshots(),
                  builder: (context, claimSnapshot) {
                    if (!claimSnapshot.hasData ||
                        claimSnapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          'No past claim requests found.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    final claims = claimSnapshot.data!.docs;

                    return ListView.builder(
                      itemCount: claims.length,
                      itemBuilder: (context, index) {
                        final claimData =
                            claims[index].data() as Map<String, dynamic>;
                        final desc = claimData['description'] ?? 'N/A';
                        final status = claimData['status'] ?? 'Pending';

                        Color statusColor = Colors.orange;
                        if (status == 'Approved' || status == 'Completed') {
                          statusColor = Colors.green;
                        } else if (status == 'Rejected') {
                          statusColor = Colors.red;
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            title: Text(desc),
                            subtitle: Text(
                              'Status: $status',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
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
          );
        },
      ),
    );
  }
}
