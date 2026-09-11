import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerEmiViewPage extends StatelessWidget {
  const CustomerEmiViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('EMI & Payments')),
      body: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error loading EMI: ${snapshot.error}'));
          }

          final data = snapshot.data?.data() ?? {};

          final financeCompany = data['financeCompany']?.toString() ?? 'N/A';
          final loanNumber = data['loanNumber']?.toString() ?? 'N/A';
          final totalEmi = data['totalEmi']?.toString() ?? '0';
          final paidEmi = data['paidEmi']?.toString() ?? '0';
          final pendingEmi = data['pendingEmi']?.toString() ?? '0';
          final emiAmount = data['emiAmount']?.toString() ?? '0';
          final pendingAmount = data['pendingAmount']?.toString() ?? '0';
          final nextDueDate = data['nextDueDate']?.toString() ?? 'N/A';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Finance Partner',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                      Text(
                        financeCompany,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Loan Account No: $loanNumber'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _emiCard(
                Icons.calendar_month,
                'Next Due Date',
                nextDueDate,
                Colors.blue,
              ),
              _emiCard(
                Icons.currency_rupee,
                'Monthly EMI Amount',
                '₹ $emiAmount',
                Colors.teal,
              ),
              _emiCard(
                Icons.check_circle_outline,
                'Paid EMIs',
                '$paidEmi of $totalEmi Installments',
                Colors.green,
              ),
              _emiCard(
                Icons.pending_actions,
                'Pending EMIs',
                '$pendingEmi Installments',
                Colors.orange,
              ),
              _emiCard(
                Icons.account_balance_wallet_outlined,
                'Total Remaining Balance',
                '₹ $pendingAmount',
                Colors.red,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _emiCard(IconData icon, String title, String value, Color iconColor) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: iconColor.withValues(alpha: 0.15),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
