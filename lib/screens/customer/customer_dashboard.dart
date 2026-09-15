import 'customer_emi_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'customer_documents_page.dart';
import 'customer_battery_warranty_page.dart';

class CustomerDashboard extends StatelessWidget {
  final String customerPhone;

  const CustomerDashboard({super.key, required this.customerPhone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .where('phone', isEqualTo: customerPhone)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'Aapka mobile number ($customerPhone) admin database me registered nahi hai. Kripya shop owner se sampark karein.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                ),
              ),
            );
          }

          final customerDoc = snapshot.data!.docs.first;
          final customerData = customerDoc.data() as Map<String, dynamic>;
          final customerId = customerDoc.id;

          final name = customerData['name'] ?? 'User';
          final vehicle = customerData['vehicleNumber'] ?? 'N/A';
          final chassis = customerData['chassisNumber'] ?? 'N/A';
          final pendingAmount = customerData['pendingAmount'] ?? 0;
          final address = customerData['address'] ?? 'N/A';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Welcome Card
              Card(
                color: Colors.blue[50],
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome, $name 👋',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text('Vehicle No: $vehicle'),
                      Text('Chassis No: $chassis'),
                      Text('Address: $address'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Dues & EMI Highlight
              Card(
                color: pendingAmount > 0 ? Colors.red[50] : Colors.green[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Financial Summary',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Pending Dues: ₹$pendingAmount',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: pendingAmount > 0 ? Colors.red : Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Button 1: E-Rickshaw Warranty
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.electric_rickshaw,
                    color: Colors.green,
                  ),
                  title: const Text(
                    'My E-Rickshaw',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerBatteryWarrantyPage(customerId: customerId),
                      ),
                    );
                  },
                ),
              ),

              // Button 2: EMI & Payments
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.currency_rupee,
                    color: Colors.purple,
                  ),
                  title: const Text(
                    'EMI & Payments',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CustomerEmiPage(
                          customerId: customerId,
                          customerData:
                              customerData, // FIXED: Now passing the correct Map
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Button 3: Documents
              Card(
                elevation: 2,
                child: ListTile(
                  leading: const Icon(Icons.folder, color: Colors.blue),
                  title: const Text(
                    'My Documents',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CustomerDocumentsPage(customerId: customerId),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
