import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  void _updateClaimStatus(
    BuildContext context,
    String docId,
    String currentStatus,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        String newStatus = currentStatus;
        return AlertDialog(
          title: const Text(
            'Update Claim Status',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: DropdownButtonFormField<String>(
            value: newStatus,
            decoration: const InputDecoration(border: OutlineInputBorder()),
            items: [
              'Pending',
              'Approved',
              'Completed',
              'Rejected',
            ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
            onChanged: (val) {
              if (val != null) newStatus = val;
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('orders')
                      .doc(docId)
                      .update({'status': newStatus});
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Status Updated Successfully!'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  debugPrint("Error updating status: $e");
                }
              },
              child: const Text('Update Status'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders & Claims'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('orders')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading data.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No active claims or orders found.',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          final claims = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final data = claims[index].data() as Map<String, dynamic>;
              final docId = claims[index].id;
              final type = data['type'] ?? 'Claim';
              final customerName = data['customerName'] ?? 'Unknown Customer';
              final desc = data['description'] ?? 'No description provided';
              final status = data['status'] ?? 'Pending';

              Color statusColor = Colors.orange;
              if (status == 'Approved' || status == 'Completed')
                statusColor = Colors.green;
              if (status == 'Rejected') statusColor = Colors.red;

              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  leading: CircleAvatar(
                    backgroundColor: statusColor.withOpacity(0.2),
                    child: Icon(Icons.build, color: statusColor),
                  ),
                  title: Text(
                    '$type - $customerName',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Issue: $desc',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Current Status: $status',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(
                      Icons.edit_note,
                      color: Colors.blue,
                      size: 30,
                    ),
                    tooltip: 'Change Status',
                    onPressed: () => _updateClaimStatus(context, docId, status),
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
