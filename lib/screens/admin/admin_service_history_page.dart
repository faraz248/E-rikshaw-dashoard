import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminServiceHistoryPage extends StatelessWidget {
  final String customerId;
  final String customerName;

  const AdminServiceHistoryPage({
    super.key,
    required this.customerId,
    required this.customerName,
  });

  Future<void> _addServiceRecord(BuildContext context) async {
    final dateController = TextEditingController();
    final detailsController = TextEditingController();
    final costController = TextEditingController();
    final nextServiceController = TextEditingController();

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add Service Record'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: dateController,
                decoration: const InputDecoration(
                  labelText: 'Service Date (DD/MM/YYYY)',
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: detailsController,
                decoration: const InputDecoration(
                  labelText: 'Details / Parts Changed',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: costController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost (₹)'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: nextServiceController,
                decoration: const InputDecoration(
                  labelText: 'Next Service Date',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (dateController.text.isEmpty ||
                  detailsController.text.isEmpty) {
                return;
              }
              await FirebaseFirestore.instance
                  .collection('customers')
                  .doc(customerId)
                  .collection('services')
                  .add({
                    'date': dateController.text.trim(),
                    'details': detailsController.text.trim(),
                    'cost': costController.text.trim(),
                    'nextService': nextServiceController.text.trim(),
                    'timestamp': FieldValue.serverTimestamp(),
                  });
              if (!ctx.mounted) return;
              Navigator.pop(ctx);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('$customerName - Services')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addServiceRecord(context),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .collection('services')
            .orderBy('timestamp', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final records = snapshot.data?.docs ?? [];

          if (records.isEmpty) {
            return const Center(child: Text('No service records found.'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: records.length,
            itemBuilder: (context, index) {
              final data = records[index].data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.brown,
                    child: Icon(Icons.build, color: Colors.white),
                  ),
                  title: Text(
                    'Date: ${data['date'] ?? 'N/A'}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Details: ${data['details']}\nCost: ₹${data['cost']}',
                  ),
                  trailing: Text(
                    'Next Due:\n${data['nextService']}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
    );
  }
}
