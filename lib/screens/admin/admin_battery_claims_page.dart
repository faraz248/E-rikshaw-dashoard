import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AdminBatteryClaimsPage extends StatelessWidget {
  const AdminBatteryClaimsPage({super.key});

  Future<void> updateStatus(
    BuildContext context,
    String claimId,
    String currentStatus,
  ) async {
    final newStatus = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Update Claim Status'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'Pending'),
            child: const Text('Pending (Orange)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'In Review'),
            child: const Text('In Review (Blue)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'Approved'),
            child: const Text('Approved (Green)'),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, 'Rejected'),
            child: const Text('Rejected (Red)'),
          ),
        ],
      ),
    );

    if (newStatus != null && newStatus != currentStatus) {
      await FirebaseFirestore.instance
          .collection('battery_claims')
          .doc(claimId)
          .update({'status': newStatus});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Battery Warranty & Claims')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('battery_claims')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final claims = snapshot.data?.docs ?? [];
          if (claims.isEmpty) {
            return const Center(
              child: Text(
                'No battery claims submitted yet.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: claims.length,
            itemBuilder: (context, index) {
              final claim = claims[index];
              final data = claim.data();

              final customerName = data['customerName'] ?? 'Unknown Customer';
              final vehicleNumber = data['vehicleNumber'] ?? 'N/A';
              final issue = data['issueDescription'] ?? '';
              final status = data['status'] ?? 'Pending';

              Color statusColor = Colors.orange;
              if (status == 'In Review') statusColor = Colors.blue;
              if (status == 'Approved') statusColor = Colors.green;
              if (status == 'Rejected') statusColor = Colors.red;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    customerName.toString(),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Vehicle: $vehicleNumber\nIssue: $issue\nStatus: $status',
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                    ),
                    onPressed: () => updateStatus(context, claim.id, status),
                    child: Text(
                      status,
                      style: const TextStyle(color: Colors.white),
                    ),
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
