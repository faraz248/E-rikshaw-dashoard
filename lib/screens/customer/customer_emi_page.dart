import 'package:flutter/material.dart';

class CustomerEmiPage extends StatelessWidget {
  final String customerId;
  final Map<String, dynamic> customerData;

  const CustomerEmiPage({
    super.key,
    required this.customerId,
    required this.customerData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer EMI Details'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Text('Customer EMI Page'),
      ),
    );
  }
}
