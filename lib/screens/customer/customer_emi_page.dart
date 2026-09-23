import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/ledger_service.dart';

class CustomerEmiPage extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic> customerData;

  const CustomerEmiPage({
    super.key,
    required this.customerId,
    required this.customerData,
  });

  @override
  State<CustomerEmiPage> createState() => _CustomerEmiPageState();
}

class _CustomerEmiPageState extends State<CustomerEmiPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();
  String _selectedMode = 'Cash';
  bool _isSaving = false;

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddPaymentDialog(double currentPending) {
    _amountController.clear();
    _notesController.clear();
    _selectedMode = 'Cash';

    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Kisht / Payment Jama Karein',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Amount Paid (₹)',
                  prefixIcon: const Icon(Icons.currency_rupee),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedMode,
                decoration: InputDecoration(
                  labelText: 'Payment Mode',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Cash', 'UPI', 'Bank Transfer']
                    .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => _selectedMode = val);
                  }
                },
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Remarks / Receipt No (Optional)',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
              ),
              onPressed: _isSaving
                  ? null
                  : () async {
                      final double? amt =
                          double.tryParse(_amountController.text.trim());
                      if (amt == null || amt <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sahi amount daalein')),
                        );
                        return;
                      }

                      setDialogState(() => _isSaving = true);
                      final messenger = ScaffoldMessenger.of(context);
                      Navigator.pop(dialogCtx);

                      await LedgerService.addPayment(
                        customerId: widget.customerId,
                        amountPaid: amt,
                        paymentMode: _selectedMode,
                        notes: _notesController.text.trim(),
                        currentPending: currentPending,
                      );

                      messenger.showSnackBar(
                        const SnackBar(
                          backgroundColor: Color(0xFF0F766E),
                          content:
                              Text('Payment passbook me entry save ho gayi!'),
                        ),
                      );
                    },
              child: const Text('Save Entry'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Customers')
          .doc(widget.customerId)
          .snapshots(),
      builder: (context, snapshot) {
        final data = (snapshot.hasData && snapshot.data!.exists)
            ? (snapshot.data!.data() ?? widget.customerData)
            : widget.customerData;

        final double pending =
            double.tryParse((data['pendingAmount'] ?? 0).toString()) ?? 0.0;
        final double monthly =
            double.tryParse((data['monthlyEmi'] ?? 0).toString()) ?? 0.0;
        final double total =
            double.tryParse((data['totalAmount'] ?? 0).toString()) ?? 0.0;
        final String financer =
            (data['financerName'] ?? 'Self / Showroom Khata').toString();

        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          appBar: AppBar(
            title: const Text('EMI & Khata Ledger'),
          ),
          floatingActionButton: FloatingActionButton.extended(
            backgroundColor: const Color(0xFF0F766E),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text('Collect Payment',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
            onPressed: () => _showAddPaymentDialog(pending),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF115E59)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Pending Balance',
                        style: TextStyle(color: Colors.white70, fontSize: 13)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${pending.toStringAsFixed(0)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold),
                    ),
                    const Divider(color: Colors.white24, height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Monthly EMI',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                            Text('₹${monthly.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total Vehicle Value',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                            Text('₹${total.toStringAsFixed(0)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Financer',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 11)),
                            Text(financer,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Payment History & Receipts',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 10),
              StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('Customers')
                    .doc(widget.customerId)
                    .collection('EmiTransactions')
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, transSnap) {
                  if (transSnap.connectionState == ConnectionState.waiting) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator()));
                  }

                  final records = transSnap.data?.docs ?? [];
                  if (records.isEmpty) {
                    return Container(
                      padding: const EdgeInsets.all(30),
                      alignment: Alignment.center,
                      child: const Text('Abhi tak koi payment jama nahi hui.',
                          style: TextStyle(color: Colors.grey)),
                    );
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: records.length,
                    itemBuilder: (context, i) {
                      final r = records[i].data();
                      final double amt =
                          double.tryParse((r['amount'] ?? 0).toString()) ?? 0.0;
                      final String mode =
                          (r['paymentMode'] ?? 'Cash').toString();
                      final String notes = (r['notes'] ?? '').toString();
                      final double bal = double.tryParse(
                              (r['remainingBalance'] ?? 0).toString()) ??
                          0.0;
                      final ts = r['date'] as Timestamp?;
                      final String dateStr = ts != null
                          ? '${ts.toDate().day}/${ts.toDate().month}/${ts.toDate().year}'
                          : 'Recent';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.green.shade100,
                            child: const Icon(Icons.arrow_downward,
                                color: Colors.green),
                          ),
                          title: Text('₹${amt.toStringAsFixed(0)} ($mode)',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text(
                            '$dateStr ${notes.isNotEmpty ? "• $notes" : ""}\nRemaining: ₹${bal.toStringAsFixed(0)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
