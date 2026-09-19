import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_service_history_page.dart';
import 'customer_edit_page.dart';
import '../customer/customer_emi_page.dart';

class CustomerDetailsPage extends StatefulWidget {
  final String customerId;
  final Map<String, dynamic> data;

  const CustomerDetailsPage({
    super.key,
    required this.customerId,
    required this.data,
  });

  @override
  State<CustomerDetailsPage> createState() => _CustomerDetailsPageState();
}

class _CustomerDetailsPageState extends State<CustomerDetailsPage> {
  late Map<String, dynamic> currentData;

  @override
  void initState() {
    super.initState();
    currentData = Map<String, dynamic>.from(widget.data);
  }

  String _value(String primaryKey, String fallbackKey) {
    final value = currentData[primaryKey] ?? currentData[fallbackKey];
    return value?.toString() ?? 'N/A';
  }

  Future<void> confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Customer'),
        content: const Text(
          'Are you sure you want to delete this customer? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId)
            .delete();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer deleted successfully.')),
        );
        Navigator.pop(context);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = _value('Name', 'name');

    return Scaffold(
      appBar: AppBar(
        title: Text(name == 'N/A' ? 'Customer Details' : name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Customer',
            onPressed: () async {
              final updated = await Navigator.push<Map<String, dynamic>>(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerEditPage(
                    customerId: widget.customerId,
                  ),
                ),
              );
              if (updated != null) {
                setState(() {
                  currentData.addAll(updated);
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            tooltip: 'Delete Customer',
            onPressed: confirmDelete,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _detail('Name', _value('Name', 'name')),
          _detail('Email', _value('Email', 'email')),
          _detail('Phone', _value('Phone', 'phone')),
          _detail('Address', _value('Address', 'address')),
          _detail('Vehicle Number', _value('Vehicle Number', 'vehicleNumber')),
          _detail('Chassis Number', _value('Chassis Number', 'chassisNumber')),
          _detail('Vehicle Model', _value('Vehicle Model', 'vehicleModel')),
          _detail(
            'Battery Details',
            _value('Battery Details', 'batteryDetails'),
          ),

          // Structured EMI Section Card
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.green.shade50,
            child: ListTile(
              leading: const Icon(
                Icons.currency_rupee,
                color: Colors.green,
                size: 30,
              ),
              title: const Text(
                'EMI & Finance Details',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Loan No: ${_value('loanNumber', 'Loan Number')}\n'
                'Paid: ${_value('paidEmi', 'Paid EMI')} / ${_value('totalEmi', 'Total EMI')} | '
                'Pending: ₹${_value('pendingAmount', 'Pending Amount')}',
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () async {
                final updatedEmi = await Navigator.push<Map<String, dynamic>>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CustomerEmiPage(
                      customerId: widget.customerId,
                      customerData: currentData,
                    ),
                  ),
                );
                if (updatedEmi != null) {
                  setState(() {
                    currentData.addAll(updatedEmi);
                  });
                }
              },
            ),
          ),

          // Structured Service History Card
          Card(
            margin: const EdgeInsets.only(bottom: 12),
            color: Colors.brown.shade50,
            child: ListTile(
              leading: const Icon(
                Icons.build_circle,
                color: Colors.brown,
                size: 30,
              ),
              title: const Text(
                'Service History',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('View and add service & repair records'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AdminServiceHistoryPage(
                      customerId: widget.customerId,
                      customerName: name,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _detail(String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(value),
      ),
    );
  }
}
