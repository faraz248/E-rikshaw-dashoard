import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEmiPage extends StatelessWidget {
  const AdminEmiPage({super.key});

  void _showUpdateEmiDialog(
    BuildContext context,
    String customerId,
    Map<String, dynamic> data,
  ) {
    final pendingController = TextEditingController(
      text: (data['pendingAmount'] ?? '').toString(),
    );
    final emiDetailsController = TextEditingController(
      text: (data['emiDetails'] ?? '').toString(),
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update EMI & Payments'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pendingController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Pending Amount (₹)',
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emiDetailsController,
              decoration: const InputDecoration(
                labelText: 'EMI Details / Due Date',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final pendingAmount =
                  double.tryParse(pendingController.text.trim()) ?? 0.0;
              final emiDetails = emiDetailsController.text.trim();

              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(customerId)
                  .update({
                    'pendingAmount': pendingAmount,
                    'emiDetails': emiDetails,
                  });

              if (context.mounted) Navigator.pop(context);
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI & Payments Management'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('customers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final customers = snapshot.data?.docs ?? [];

          if (customers.isEmpty) {
            return const Center(
              child: Text(
                'No customer records found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final doc = customers[index];
              final data = doc.data();
              final name = data['name'] ?? data['Name'] ?? 'Unknown Customer';
              final phone = data['phone'] ?? data['Phone'] ?? 'N/A';
              final pendingAmount = data['pendingAmount'] ?? 0;
              final emiDetails = data['emiDetails'] ?? 'No EMI details set';

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purpleAccent,
                    child: Icon(Icons.payments, color: Colors.white),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Phone: $phone\nPending: ₹$pendingAmount\nDetails: $emiDetails',
                  ),
                  isThreeLine: true,
                  trailing: IconButton(
                    icon: const Icon(Icons.edit, color: Colors.purple),
                    onPressed: () =>
                        _showUpdateEmiDialog(context, doc.id, data),
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
