import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEmiPage extends StatelessWidget {
  const AdminEmiPage({super.key});

  void _showCollectPaymentDialog(
    BuildContext context,
    String docId,
    String customerName,
    num currentPending,
    num currentPaid,
  ) {
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Collect EMI: $customerName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Current Pending: ₹$currentPending',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Payment Received (₹)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.currency_rupee),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              final paidAmount =
                  num.tryParse(amountController.text.trim()) ?? 0;
              if (paidAmount <= 0) return;

              final newPending = (currentPending - paidAmount) < 0
                  ? 0
                  : (currentPending - paidAmount);
              final newPaidEmi = currentPaid + 1;

              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(docId)
                  .update({
                    'pendingAmount': newPending,
                    'paidEmi': newPaidEmi,
                    'lastPaymentDate': FieldValue.serverTimestamp(),
                  });

              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('Confirm Payment'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI & Payments'),
        backgroundColor: Colors.purple.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No customers on EMI found.'));
          }

          final customers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final doc = customers[index];
              final data = doc.data() as Map<String, dynamic>;
              final name = data['name'] ?? data['Name'] ?? 'Customer';
              final phone = data['phone'] ?? data['Phone'] ?? 'N/A';
              final pending =
                  num.tryParse(data['pendingAmount']?.toString() ?? '0') ?? 0;
              final paidEmi =
                  num.tryParse(data['paidEmi']?.toString() ?? '0') ?? 0;
              final totalEmi =
                  num.tryParse(data['totalEmi']?.toString() ?? '0') ?? 0;

              return Card(
                elevation: 2,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: const CircleAvatar(
                    backgroundColor: Colors.purple,
                    child: Icon(Icons.currency_rupee, color: Colors.white),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Phone: $phone'),
                        Text('Installments: $paidEmi / $totalEmi Paid'),
                        Text(
                          'Pending Balance: ₹$pending',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: pending > 0 ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade50,
                      foregroundColor: Colors.purple,
                    ),
                    onPressed: () => _showCollectPaymentDialog(
                      context,
                      doc.id,
                      name,
                      pending,
                      paidEmi,
                    ),
                    child: const Text('Collect'),
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
