import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'customer_details_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  void _showAddCustomerDialog() {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final chassisC = TextEditingController();
    final dateC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add New Customer',
            style: TextStyle(color: Colors.black87)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameC,
                  decoration:
                      const InputDecoration(labelText: 'Customer Name *')),
              TextField(
                  controller: phoneC,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Mobile No *')),
              TextField(
                  controller: chassisC,
                  decoration: const InputDecoration(labelText: 'Chassis No *')),
              TextField(
                  controller: dateC,
                  decoration:
                      const InputDecoration(labelText: 'Date of Purchase *')),
              const Padding(
                padding: EdgeInsets.only(top: 10),
                child: Text('* Compulsory fields',
                    style: TextStyle(color: Colors.red, fontSize: 12)),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              // 1. MANDATORY FIELDS CHECK
              if (nameC.text.trim().isEmpty ||
                  phoneC.text.trim().isEmpty ||
                  chassisC.text.trim().isEmpty ||
                  dateC.text.trim().isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Error: Name, Mobile No, Chassis No, and Date are COMPULSORY!'),
                    backgroundColor: Colors.red,
                  ),
                );
                return; // Code yahin ruk jayega, aage nahi badhega
              }

              // 2. SAVE TO DATABASE
              await FirebaseFirestore.instance.collection('customers').add({
                'name': nameC.text.trim(),
                'phone': phoneC.text.trim(),
                'chassisNumber': chassisC.text.trim(),
                'purchaseDate': dateC.text.trim(),
                'fatherName': '',
                'address': '',
                'vehicleNumber': '',
                'batteryModel': '',
                'batteryNo': '',
                'vehicleModel': '',
                'totalAmount': 0,
                'receivedAmount': 0,
                'pendingAmount': 0,
                'batteryType': 'Lead-Acid', // Default battery type
                'documents': {},
                'profilePhoto': '',
              });

              if (!context.mounted) return;
              Navigator.pop(context);
            },
            child: const Text('Add Customer',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Admin Dashboard',
            style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Logout',
              onPressed: () {
                Navigator.pop(context); // Logout routing
              })
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.teal,
        onPressed: _showAddCustomerDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('customers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
                child: Text('No customers found. Click + to add.'));
          }

          final customers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final doc = customers[index];
              final data = doc.data() as Map<String, dynamic>;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.teal.shade100,
                    backgroundImage: (data['profilePhoto'] != null &&
                            data['profilePhoto'].toString().isNotEmpty)
                        ? NetworkImage(data['profilePhoto'])
                        : null,
                    child: (data['profilePhoto'] == null ||
                            data['profilePhoto'].toString().isEmpty)
                        ? Text(
                            data['name']
                                    ?.toString()
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                'U',
                            style: const TextStyle(
                                color: Colors.teal,
                                fontWeight: FontWeight.bold))
                        : null,
                  ),
                  title: Text(data['name'] ?? 'Unknown',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text(
                      'Mob: ${data['phone'] ?? 'N/A'} | Bal: ₹${data['pendingAmount'] ?? 0}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AdminCustomerDetailView(
                          customerId: doc.id,
                          customerData: data,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
