import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../auth/unified_login_screen.dart';
import 'customer_details_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String searchQuery = "";
  final TextEditingController _searchController = TextEditingController();

  void _showAddCustomerDialog(BuildContext context) {
    final nameC = TextEditingController();
    final phoneC = TextEditingController();
    final fnameC = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: const Text('Add New Customer',
            style: TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                  controller: nameC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Vehicle Owner Name',
                      labelStyle: TextStyle(color: Colors.grey))),
              TextField(
                  controller: phoneC,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                      labelText: 'Mobile Number',
                      labelStyle: TextStyle(color: Colors.grey))),
              TextField(
                  controller: fnameC,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                      labelText: 'Father Name',
                      labelStyle: TextStyle(color: Colors.grey))),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
            onPressed: () async {
              if (nameC.text.trim().isNotEmpty &&
                  phoneC.text.trim().isNotEmpty) {
                await FirebaseFirestore.instance.collection('customers').add({
                  'name': nameC.text.trim(),
                  'phone': phoneC.text.trim(),
                  'fatherName': fnameC.text.trim(),
                  'createdAt': FieldValue.serverTimestamp(),
                  'documents': {},
                });

                if (!mounted) return;
                Navigator.pop(context);
              }
            },
            child: const Text('Save Record',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E5631),
        title: const Text('E-Rickshaw Hub Admin',
            style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const HubLoginPortal()));
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('customers')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.teal));
          }

          final allCustomers = snapshot.data!.docs;

          final filteredCustomers = allCustomers.where((doc) {
            final data = doc.data();
            final name = (data['name'] ?? '').toString().toLowerCase();
            final phone = (data['phone'] ?? '').toString().toLowerCase();
            final query = searchQuery.toLowerCase();
            return name.contains(query) || phone.contains(query);
          }).toList();

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                      color: const Color(0xFF1E1E1E),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      const Icon(Icons.people_alt,
                          color: Colors.teal, size: 30),
                      const SizedBox(width: 15),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Customers',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 14)),
                          Text('${allCustomers.length}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: _searchController,
                  style: const TextStyle(color: Colors.white),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search by Name, Phone...',
                    hintStyle: const TextStyle(color: Colors.grey),
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    filled: true,
                    fillColor: const Color(0xFF1E1E1E),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: filteredCustomers.isEmpty
                      ? const Center(
                          child: Text('No customers found',
                              style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: filteredCustomers.length,
                          itemBuilder: (context, index) {
                            final doc = filteredCustomers[index];
                            final data = doc.data();

                            final String safeName = (data['name'] != null &&
                                    data['name'].toString().trim().isNotEmpty)
                                ? data['name'].toString().trim()
                                : 'Unknown';
                            final String initial = safeName[0].toUpperCase();

                            return Card(
                              color: const Color(0xFF1E1E1E),
                              margin: const EdgeInsets.only(bottom: 10),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade900,
                                  backgroundImage:
                                      (data['profilePhoto'] != null &&
                                              data['profilePhoto']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? NetworkImage(data['profilePhoto'])
                                          : null,
                                  child: (data['profilePhoto'] == null ||
                                          data['profilePhoto']
                                              .toString()
                                              .isEmpty)
                                      ? Text(initial,
                                          style: const TextStyle(
                                              color: Colors.tealAccent))
                                      : null,
                                ),
                                title: Text(safeName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                subtitle: Text('Phone: ${data['phone'] ?? '-'}',
                                    style: const TextStyle(
                                        color: Colors.grey, fontSize: 13)),
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (_) =>
                                              AdminCustomerDetailView(
                                                  customerId: doc.id,
                                                  customerData: data)));
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.teal,
        onPressed: () {
          _showAddCustomerDialog(context);
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label:
            const Text('Add Customer', style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
