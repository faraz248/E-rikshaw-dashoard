import 'package:flutter/material.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';
import 'add_customer_screen.dart';

class ShopCustomerListScreen extends StatelessWidget {
  final String shopId;
  final String shopName;

  const ShopCustomerListScreen({
    super.key,
    required this.shopId,
    required this.shopName,
  });

  @override
  Widget build(BuildContext context) {
    final customerService = CustomerService();

    return Scaffold(
      appBar: AppBar(title: Text('$shopName - Customers')),
      body: StreamBuilder<List<CustomerModel>>(
        stream: customerService.getCustomersByShop(shopId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final customers = snapshot.data ?? [];

          if (customers.isEmpty) {
            return const Center(
              child: Text(
                'Is shop me abhi koi customer add nahi hai.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: customer.photoUrl != null
                        ? NetworkImage(customer.photoUrl!)
                        : null,
                    child: customer.photoUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  title: Text(
                    customer.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    'Vehicle: ${customer.vehicleNo} | Chassis: ${customer.chassisNo}\nFinancer: ${customer.financerName}',
                  ),
                  trailing: Text(
                    '₹${customer.monthlyEmi.toStringAsFixed(0)}/m',
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  isThreeLine: true,
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddCustomerScreen(shopId: shopId),
            ),
          );
        },
        child: const Icon(Icons.person_add),
      ),
    );
  }
}
