import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  Future<void> _updateOrderStatus(String docId, String newStatus) async {
    await FirebaseFirestore.instance.collection('orders').doc(docId).update({
      'status': newStatus,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customer Orders & Claims')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No orders or claims found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final doc = orders[index];
              final data = doc.data() as Map<String, dynamic>;
              final docId = doc.id;

              final customerName = data['customerName'] ?? 'Unknown Customer';
              final issueDescription =
                  data['description'] ?? data['productName'] ?? 'N/A';
              final status = data['status'] ?? 'Pending';
              final type = data['type'] ?? 'Order/Claim';

              Color statusColor = Colors.orange;
              if (status == 'Approved' || status == 'Completed') {
                statusColor = Colors.green;
              } else if (status == 'Rejected') {
                statusColor = Colors.red;
              }

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(
                    '$customerName ($type)',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text('Details: $issueDescription'),
                      const SizedBox(height: 4),
                      Text(
                        'Status: $status',
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    onSelected: (newStatus) =>
                        _updateOrderStatus(docId, newStatus),
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Pending',
                        child: Text('Mark Pending'),
                      ),
                      const PopupMenuItem(
                        value: 'Approved',
                        child: Text('Mark Approved'),
                      ),
                      const PopupMenuItem(
                        value: 'Completed',
                        child: Text('Mark Completed'),
                      ),
                      const PopupMenuItem(
                        value: 'Rejected',
                        child: Text(
                          'Mark Rejected',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
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
