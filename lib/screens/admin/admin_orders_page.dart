import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders & Warranty Claims'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        // Firestore 'claims' collection ko real-time me read kar raha hai
        stream: FirebaseFirestore.instance
            .collection('claims')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'Error loading claims.',
                style: TextStyle(color: Colors.red),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text(
                'No active claims or orders found.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final claims = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final data = claims[index].data() as Map<String, dynamic>;
              final claimId = claims[index].id;
              final customerName = data['customerName'] ?? 'Unknown Customer';
              final issue =
                  data['issueDescription'] ?? 'No description provided';
              final status = data['status'] ?? 'Pending';

              // Status ke hisaab se color logic
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
                    backgroundColor: statusColor.withValues(alpha: 0.2),
                    radius: 25,
                    child: Icon(
                      Icons.build_circle,
                      color: statusColor,
                      size: 30,
                    ),
                  ),
                  title: Text(
                    customerName,
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
                          'Issue: $issue',
                          style: const TextStyle(color: Colors.black87),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Status: $status',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Update Status',
                    onSelected: (newStatus) async {
                      // Status update in Firestore
                      await FirebaseFirestore.instance
                          .collection('claims')
                          .doc(claimId)
                          .update({'status': newStatus});
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'Pending',
                        child: Text('⏳ Mark as Pending'),
                      ),
                      const PopupMenuItem(
                        value: 'Approved',
                        child: Text('✅ Approve Claim'),
                      ),
                      const PopupMenuItem(
                        value: 'Completed',
                        child: Text('🛠️ Mark Completed'),
                      ),
                      const PopupMenuItem(
                        value: 'Rejected',
                        child: Text('❌ Reject Claim'),
                      ),
                    ],
                    child: const Icon(Icons.more_vert),
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
