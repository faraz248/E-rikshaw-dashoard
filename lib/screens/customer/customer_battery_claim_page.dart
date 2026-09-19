import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../theme/app_theme.dart';

class CustomerBatteryClaimPage extends StatefulWidget {
  final String? customerId;
  const CustomerBatteryClaimPage({super.key, this.customerId});

  @override
  State<CustomerBatteryClaimPage> createState() =>
      _CustomerBatteryClaimPageState();
}

class _CustomerBatteryClaimPageState extends State<CustomerBatteryClaimPage> {
  final _issueController = TextEditingController();
  final _batterySerialController = TextEditingController();
  String _selectedIssueType = 'Mileage / Low Backup';
  bool _isSubmitting = false;

  final List<String> _issueCategories = [
    'Mileage / Low Backup',
    'Charging Issue (Not Charging)',
    'Voltage Drop Under Load',
    'Heating / Swelling Problem',
    'Complete Dead Battery',
  ];

  Future<void> _submitClaim(String customerUid) async {
    if (_batterySerialController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.red500,
          content: Text('Please enter battery serial number'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final userDoc = await FirebaseFirestore.instance.collection('customers').doc(customerUid).get();
      final userData = userDoc.data() ?? {};

      await FirebaseFirestore.instance.collection('battery_claims').add({
        'customerId': customerUid,
        'customerName': userData['name'] ?? 'Unknown Customer',
        'vehicleNumber': userData['vehicleNumber'] ?? 'Unknown Vehicle',
        'claimType': 'Battery Warranty',
        'issueCategory': _selectedIssueType,
        'batterySerial': _batterySerialController.text.trim().toUpperCase(),
        'issueDescription': _issueController.text.trim(),
        'status': 'Pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        _issueController.clear();
        _batterySerialController.clear();
        Navigator.pop(context); // Close bottom sheet
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emerald600,
            content: Text('Battery claim ticket submitted successfully!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red500,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showNewClaimModal(BuildContext context, String customerUid) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setModalState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'File Battery Warranty Claim',
                    style: AppText.heading,
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Battery Serial Number', style: AppText.caption),
              const SizedBox(height: 6),
              TextField(
                controller: _batterySerialController,
                decoration: InputDecoration(
                  hintText: 'e.g. EXIDE-ER-98421',
                  prefixIcon: const Icon(
                    Icons.qr_code_2_rounded,
                    color: AppColors.slate500,
                  ),
                  filled: true,
                  fillColor: AppColors.slate100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text('Issue Type', style: AppText.caption),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  color: AppColors.slate100,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedIssueType,
                    items: _issueCategories.map((type) {
                      return DropdownMenuItem(
                        value: type,
                        child: Text(type, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => _selectedIssueType = val);
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Additional Problem Details (Optional)',
                style: AppText.caption,
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _issueController,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText:
                      'Kitne kilometer chalne ke baad band ho rahi hai...',
                  filled: true,
                  fillColor: AppColors.slate100,
                  contentPadding: const EdgeInsets.all(12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slate900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isSubmitting
                      ? null
                      : () => _submitClaim(customerUid),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Claim Ticket',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerUid =
        widget.customerId ?? FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.slate100,
      appBar: AppBar(
        title: const Text('Battery Warranty & Claims', style: AppText.heading),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.slate900,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_task_rounded),
        label: const Text('Raise New Claim'),
        onPressed: () => _showNewClaimModal(context, customerUid),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('battery_claims')
            .where('customerId', isEqualTo: customerUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.emerald600),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.verified_user_outlined,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'No Active Warranty Claims',
                    style: AppText.subHeading,
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Agar battery me koi problem hai toh neeche diye button se claim register karein.',
                    textAlign: TextAlign.center,
                    style: AppText.caption,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final claim = docs[index].data() as Map<String, dynamic>;
              final status = (claim['status'] ?? 'Pending Verification')
                  .toString();
              final batterySerial = (claim['batterySerial'] ?? 'N/A')
                  .toString();
              final issue = (claim['issueCategory'] ?? 'Battery Fault')
                  .toString();

              Color badgeColor = AppColors.amber500;
              if (status.toLowerCase().contains('approved') ||
                  status.toLowerCase().contains('resolved')) {
                badgeColor = AppColors.emerald600;
              } else if (status.toLowerCase().contains('rejected')) {
                badgeColor = AppColors.red500;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'SN: $batterySerial',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColors.slate900,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      issue,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.slate800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if ((claim['issueDescription'] ?? '').toString().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        claim['issueDescription'],
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.slate500,
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
