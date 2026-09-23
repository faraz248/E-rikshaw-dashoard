import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminOrdersPage extends StatelessWidget {
  const AdminOrdersPage({super.key});

  void _showStatusUpdateSheet(
    BuildContext context,
    String claimId,
    String currentStatus,
  ) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Update Claim Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _statusOption(
                ctx,
                claimId,
                'Pending',
                Icons.hourglass_top_rounded,
                Colors.amber.shade800,
              ),
              _statusOption(
                ctx,
                claimId,
                'Approved',
                Icons.check_circle_rounded,
                Colors.teal,
              ),
              _statusOption(
                ctx,
                claimId,
                'Completed',
                Icons.task_alt_rounded,
                Colors.blueAccent,
              ),
              _statusOption(
                ctx,
                claimId,
                'Rejected',
                Icons.cancel_rounded,
                Colors.redAccent,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusOption(
    BuildContext context,
    String claimId,
    String status,
    IconData icon,
    Color color,
  ) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        status,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        size: 14,
        color: Colors.grey,
      ),
      onTap: () async {
        Navigator.pop(context);
        await FirebaseFirestore.instance
            .collection('battery_claims')
            .doc(claimId)
            .update({'status': status});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F8FA),
      appBar: AppBar(
        title: const Text(
          'Battery Claims Management',
          style: TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E293B),
        elevation: 0.5,
        centerTitle: false,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('battery_claims')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2.5),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Sync Error: ${snapshot.error}',
                style: const TextStyle(color: Colors.redAccent),
              ),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 56,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No active claims found',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          final claims = snapshot.data!.docs;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            itemCount: claims.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final data = claims[index].data() as Map<String, dynamic>? ?? {};
              final claimId = claims[index].id;

              final customerName =
                  (data['customerName'] ?? 'Unknown Customer').toString();
              final vehicleNumber =
                  (data['vehicleNumber'] ?? 'Unknown Vehicle').toString();
              final issueCategory = (data['issueCategory'] ?? 'N/A').toString();
              final batterySerial = (data['batterySerial'] ?? 'N/A').toString();
              final issueDesc =
                  (data['issueDescription'] ?? 'No issue described').toString();
              final status = (data['status'] ?? 'Pending').toString();

              Color badgeBg;
              Color badgeText;
              switch (status.toLowerCase()) {
                case 'approved':
                  badgeBg = const Color(0xFFE6F4EA);
                  badgeText = const Color(0xFF137333);
                  break;
                case 'completed':
                  badgeBg = const Color(0xFFE8F0FE);
                  badgeText = const Color(0xFF1A73E8);
                  break;
                case 'rejected':
                  badgeBg = const Color(0xFFFCE8E6);
                  badgeText = const Color(0xFFC5221F);
                  break;
                default:
                  badgeBg = const Color(0xFFFEF7E0);
                  badgeText = const Color(0xFFB06000);
              }

              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.black.withValues(alpha: 0.06),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 18,
                              backgroundColor: const Color(0xFFF1F5F9),
                              child: Text(
                                customerName.isNotEmpty
                                    ? customerName[0].toUpperCase()
                                    : 'C',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF334155),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  customerName,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15,
                                    color: Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  vehicleNumber,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: badgeText,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Battery Details Section
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Battery Serial',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  batterySerial,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Issue Category',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.black54,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  issueCategory,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Description
                    if (issueDesc.isNotEmpty)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          issueDesc,
                          style: const TextStyle(
                            fontSize: 13.5,
                            color: Color(0xFF334155),
                            height: 1.35,
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),

                    // Action Buttons for Accept / Reject
                    if (status.toLowerCase() == 'pending')
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 18,
                              ),
                              label: const Text(
                                'Reject',
                                style: TextStyle(color: Colors.red),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.red),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _updateClaimStatus(
                                context,
                                claimId,
                                'Rejected',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              icon: const Icon(
                                Icons.check,
                                color: Colors.white,
                                size: 18,
                              ),
                              label: const Text(
                                'Accept',
                                style: TextStyle(color: Colors.white),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              onPressed: () => _updateClaimStatus(
                                context,
                                claimId,
                                'Approved',
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        child: TextButton.icon(
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Change Status'),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey.shade700,
                          ),
                          onPressed: () =>
                              _showStatusUpdateSheet(context, claimId, status),
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _updateClaimStatus(
    BuildContext context,
    String claimId,
    String status,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('battery_claims')
          .doc(claimId)
          .update({'status': status});
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Claim marked as $status')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating: $e')));
      }
    }
  }
}
