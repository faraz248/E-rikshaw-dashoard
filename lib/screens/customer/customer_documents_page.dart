import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class CustomerDocumentsPage extends StatelessWidget {
  final String customerId;
  const CustomerDocumentsPage({super.key, required this.customerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate100,
      appBar: AppBar(
        title: const Text('Vehicle Document Locker', style: AppText.heading),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(customerId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emerald600),
            );
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No documents registered yet.',
                style: AppText.caption,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final docs = (data['documents'] as Map<String, dynamic>?) ?? {};

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _docCard(
                title: 'Registration Certificate (RC)',
                subtitle: data['vehicleNo'] ?? 'Plate Not Assigned',
                fileUrl: docs['rc_url'],
                icon: Icons.badge_outlined,
                badgeColor: AppColors.blue600,
              ),
              _docCard(
                title: 'Vehicle Insurance Policy',
                subtitle: docs['insurance_expiry'] != null
                    ? 'Valid till: ${docs['insurance_expiry']}'
                    : 'Annual Comprehensive Policy',
                fileUrl: docs['insurance_url'],
                icon: Icons.shield_outlined,
                badgeColor: AppColors.emerald600,
              ),
              _docCard(
                title: 'Battery Warranty Card',
                subtitle: docs['battery_serial'] != null
                    ? 'SN: ${docs['battery_serial']}'
                    : 'Official Dealership Guarantee',
                fileUrl: docs['battery_card_url'],
                icon: Icons.battery_charging_full_outlined,
                badgeColor: AppColors.amber500,
              ),
              _docCard(
                title: 'Customer Aadhaar / Identity',
                subtitle: 'Government Verified ID',
                fileUrl: docs['aadhaar_url'],
                icon: Icons.person_pin_outlined,
                badgeColor: AppColors.slate800,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _docCard({
    required String title,
    required String subtitle,
    required String? fileUrl,
    required IconData icon,
    required Color badgeColor,
  }) {
    final bool isAvailable = fileUrl != null && fileUrl.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: badgeColor.withValues(alpha: 0.1),
            child: Icon(icon, color: badgeColor, size: 26),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppText.subHeading),
                const SizedBox(height: 3),
                Text(subtitle, style: AppText.caption),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: isAvailable
                  ? const Color(0xFFE6F4EA)
                  : const Color(0xFFFEF7E0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              isAvailable ? 'Verified' : 'Pending',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: isAvailable
                    ? const Color(0xFF137333)
                    : AppColors.amber500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
