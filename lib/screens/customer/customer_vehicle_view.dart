import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CustomerVehicleViewPage extends StatelessWidget {
  const CustomerVehicleViewPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login first.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('My E-Rickshaw')),
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
            return Center(
              child: Text('Error loading vehicle details: ${snapshot.error}'),
            );
          }

          final data = snapshot.data?.data() ?? {};

          final vehicleModel = data['vehicleModel']?.toString() ?? 'N/A';
          final vehicleNumber = data['vehicleNumber']?.toString() ?? 'N/A';
          final chassisNumber = data['chassisNumber']?.toString() ?? 'N/A';
          final batteryDetails = data['batteryDetails']?.toString() ?? 'N/A';

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _infoTile(Icons.electric_rickshaw, 'Vehicle Model', vehicleModel),
              _infoTile(
                Icons.confirmation_number,
                'Registration / Vehicle Number',
                vehicleNumber,
              ),
              _infoTile(Icons.numbers, 'Chassis Number', chassisNumber),
              _infoTile(
                Icons.battery_charging_full,
                'Battery Specifications',
                batteryDetails,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _infoTile(IconData icon, String title, String value) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.shade100,
          child: Icon(icon, color: Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        subtitle: Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
