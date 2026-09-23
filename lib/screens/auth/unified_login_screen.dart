import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../admin/admin_dashboard.dart';
import '../customer/customer_passbook_view.dart';

class HubLoginPortal extends StatefulWidget {
  const HubLoginPortal({super.key});
  @override
  State<HubLoginPortal> createState() => _HubLoginPortalState();
}

class _HubLoginPortalState extends State<HubLoginPortal> {
  bool isCustomerTab = true;
  final phoneCtrl = TextEditingController();
  final adminEmailCtrl = TextEditingController();
  final adminPassCtrl = TextEditingController();
  bool loading = false;

  Future<void> handleCustomerLogin() async {
    final phone = phoneCtrl.text.trim();
    if (phone.isEmpty) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      final query = await FirebaseFirestore.instance
          .collection('customers')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();
      if (query.docs.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Mobile number nahi mila.')));
        }
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (_) =>
                    CustomerPassbookView(customerId: query.docs.first.id)));
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> handleAdminLogin() async {
    final email = adminEmailCtrl.text.trim();
    final pass = adminPassCtrl.text.trim();
    if (email.isEmpty || pass.isEmpty) {
      return;
    }
    setState(() {
      loading = true;
    });
    try {
      final cred = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: pass);
      final adminDoc = await FirebaseFirestore.instance
          .collection('admins')
          .doc(cred.user!.uid)
          .get();
      if (!adminDoc.exists) {
        await FirebaseAuth.instance.signOut();
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text('Access Denied.')));
        }
        return;
      }
      if (mounted) {
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (_) => const AdminDashboard()));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              children: [
                const Icon(Icons.local_shipping,
                    size: 50, color: Colors.white70),
                const SizedBox(height: 10),
                const Text('E-RICKSHAW KHATA HUB',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                Container(
                  decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isCustomerTab = true),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                  color: isCustomerTab
                                      ? const Color(0xFF1E5631)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Text('Customer Portal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() => isCustomerTab = false),
                          child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                  color: !isCustomerTab
                                      ? const Color(0xFF1E5631)
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12)),
                              child: const Text('Admin Portal',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold))),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                      color: const Color(0xFF2A2A2A),
                      borderRadius: BorderRadius.circular(16)),
                  child:
                      isCustomerTab ? _buildCustomerForm() : _buildAdminForm(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomerForm() {
    return Column(
      children: [
        TextField(
            controller: phoneCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Mobile Number',
                prefixText: '+91 ',
                labelStyle: TextStyle(color: Colors.grey))),
        const SizedBox(height: 25),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5631)),
                onPressed: loading ? null : handleCustomerLogin,
                child: const Text('View Passbook',
                    style: TextStyle(color: Colors.white)))),
      ],
    );
  }

  Widget _buildAdminForm() {
    return Column(
      children: [
        TextField(
            controller: adminEmailCtrl,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Admin Email',
                labelStyle: TextStyle(color: Colors.grey))),
        const SizedBox(height: 15),
        TextField(
            controller: adminPassCtrl,
            obscureText: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.grey))),
        const SizedBox(height: 25),
        SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E5631)),
                onPressed: loading ? null : handleAdminLogin,
                child: const Text('Admin Login',
                    style: TextStyle(color: Colors.white)))),
      ],
    );
  }
}
