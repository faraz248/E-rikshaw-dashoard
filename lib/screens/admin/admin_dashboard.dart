import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'admin_customer_list_page.dart';
import 'admin_products_page.dart';
import 'admin_orders_page.dart';
import 'admin_emi_page.dart';
import 'customer_details_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  List<Map<String, dynamic>> allCustomers = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCustomers();
  }

  Future<void> fetchCustomers() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('customers')
          .get();
      setState(() {
        allCustomers = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetching customers: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Dashboard 🔐',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red.shade700,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Autocomplete<Map<String, dynamic>>(
                    optionsBuilder: (TextEditingValue textEditingValue) {
                      if (textEditingValue.text.isEmpty) {
                        return const Iterable<Map<String, dynamic>>.empty();
                      }
                      final String query = textEditingValue.text.toLowerCase();
                      return allCustomers.where((customer) {
                        final String name = (customer['name'] ?? '')
                            .toString()
                            .toLowerCase();
                        final String phone = (customer['phone'] ?? '')
                            .toString()
                            .toLowerCase();
                        return name.contains(query) || phone.contains(query);
                      });
                    },
                    displayStringForOption: (option) =>
                        '${option['name'] ?? 'Unknown'} - ${option['phone'] ?? 'No Phone'}',
                    onSelected: (selection) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CustomerDetailsPage(
                            customerId: selection['id'],
                            data: selection,
                          ),
                        ),
                      );
                    },
                    fieldViewBuilder:
                        (context, controller, focusNode, onEditingComplete) {
                          return TextField(
                            controller: controller,
                            focusNode: focusNode,
                            decoration: InputDecoration(
                              labelText: 'Search Customer by Name or Mobile',
                              prefixIcon: const Icon(Icons.search),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          );
                        },
                  ),
          ),
          const SizedBox(height: 5),
          const Text(
            'ADMIN ACCESS GRANTED ✅',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildListCard(
                  context,
                  title: 'Customer Details',
                  icon: Icons.people,
                  color: Colors.blue,
                  page: const AdminCustomerListPage(),
                ),
                const SizedBox(height: 12),
                _buildListCard(
                  context,
                  title: 'EMI & Payments',
                  icon: Icons.payments_outlined,
                  color: Colors.purple,
                  page: const AdminEmiPage(),
                ),
                const SizedBox(height: 12),
                _buildListCard(
                  context,
                  title: 'Inventory & Products',
                  icon: Icons.inventory,
                  color: Colors.orange,
                  page: const AdminProductsPage(),
                ),
                const SizedBox(height: 12),
                _buildListCard(
                  context,
                  title: 'Battery Claims',
                  icon: Icons.battery_alert,
                  color: Colors.green,
                  page: const AdminOrdersPage(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required Widget page,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: Colors.white),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 18),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (_) => page));
        },
      ),
    );
  }
}
