import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';
import 'customer_documents_page.dart';
import 'customer_battery_claim_page.dart';

class CustomerVehicleView extends StatelessWidget {
  final String? customerId;
  const CustomerVehicleView({super.key, this.customerId});

  @override
  Widget build(BuildContext context) {
    final effectiveId = customerId ?? FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      backgroundColor: AppColors.slate100,
      appBar: AppBar(
        title: const Text('My E-Rickshaw Hub', style: AppText.heading),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: (effectiveId != null && effectiveId.isNotEmpty)
            ? FirebaseFirestore.instance
                  .collection('customers')
                  .doc(effectiveId)
                  .snapshots()
            : null,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emerald600),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text(
                'No vehicle allocated to this account.',
                style: AppText.caption,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final vehicleNo = (data['vehicleNo'] ?? 'UP-XX-XXXX').toString();
          final model = (data['model'] ?? 'Standard Electric Rickshaw')
              .toString();
          final name = (data['name'] ?? 'Owner').toString();
          final pendingAmount =
              num.tryParse(data['pendingAmount']?.toString() ?? '0') ?? 0;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vehicle Digital Identification Card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.slate900,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white12,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'COMMERCIAL EV',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.electric_rickshaw_rounded,
                            color: Colors.white,
                            size: 32,
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      Text(
                        vehicleNo,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        model,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Divider(color: Colors.white12, height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Registered To',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text(
                                'Khata Status',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 11,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                pendingAmount > 0 ? 'EMI Active' : 'All Clear',
                                style: TextStyle(
                                  color: pendingAmount > 0
                                      ? const Color(0xFFFBBF24)
                                      : const Color(0xFF34D399),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Fast Quick-Action Tiles
                const Text(
                  'VEHICLE MANAGEMENT',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.slate500,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 10),

                _actionTile(
                  icon: Icons.folder_shared_rounded,
                  title: 'Document Vault',
                  subtitle: 'RC Book, Insurance, Battery Card',
                  color: AppColors.blue600,
                  onTap: () {
                    if (effectiveId != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              CustomerDocumentsPage(customerId: effectiveId),
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                _actionTile(
                  icon: Icons.battery_charging_full_rounded,
                  title: 'Battery Health & Warranty',
                  subtitle: 'Serial number, warranty claim status',
                  color: AppColors.emerald600,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CustomerBatteryClaimPage(customerId: effectiveId),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Emergency Dealership Support Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.cardBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.amber500.withValues(
                          alpha: 0.15,
                        ),
                        child: const Icon(
                          Icons.handyman_rounded,
                          color: AppColors.amber500,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Breakdown / Dealership Support',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Kisi bhi mechanical ya motor issue ke liye shop par contact karein.',
                              style: AppText.caption,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _actionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppText.subHeading),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppText.caption),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: AppColors.slate500,
            ),
          ],
        ),
      ),
    );
  }
}
