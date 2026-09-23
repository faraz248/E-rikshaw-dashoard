import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminAddCustomerPage extends StatefulWidget {
  const AdminAddCustomerPage({super.key});

  @override
  State<AdminAddCustomerPage> createState() => _AdminAddCustomerPageState();
}

class _AdminAddCustomerPageState extends State<AdminAddCustomerPage> {
  final _formKey = GlobalKey<FormState>();

  // Personal Details
  final _nameController = TextEditingController();
  final _fatherNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  // Vehicle Details
  final _modelController = TextEditingController();
  final _regNoController = TextEditingController();
  final _chassisNoController = TextEditingController();
  final _batteryModelController = TextEditingController();
  final _batteryNoController = TextEditingController();
  final _purchaseDateController = TextEditingController();

  // Financial / Ledger Details
  final _totalAmountController = TextEditingController();
  final _receivedAmountController = TextEditingController();
  final _monthlyEmiController = TextEditingController();
  final _financerController = TextEditingController();

  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _modelController.dispose();
    _regNoController.dispose();
    _chassisNoController.dispose();
    _batteryModelController.dispose();
    _batteryNoController.dispose();
    _purchaseDateController.dispose();
    _totalAmountController.dispose();
    _receivedAmountController.dispose();
    _monthlyEmiController.dispose();
    _financerController.dispose();
    super.dispose();
  }

  Future<void> _selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _purchaseDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<void> _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    // SaaS LOGIC: Fetch the current Admin's UID (Showroom ID)
    final adminUser = FirebaseAuth.instance.currentUser;
    if (adminUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text('Authentication Error: Showroom Admin not logged in.'),
        ),
      );
      return;
    }
    
    final showroomId = adminUser.uid;
    setState(() => _isSaving = true);

    try {
      final total = double.tryParse(_totalAmountController.text.trim()) ?? 0.0;
      final received = double.tryParse(_receivedAmountController.text.trim()) ?? 0.0;
      final pending = (total - received).clamp(0.0, double.infinity);
      final monthly = double.tryParse(_monthlyEmiController.text.trim()) ?? 0.0;

      // MULTI-TENANT ARCHITECTURE: Saving data under specific Showroom ID
      final docRef = await FirebaseFirestore.instance
          .collection('Showrooms')
          .doc(showroomId)
          .collection('Customers')
          .add({
        // Personal
        'name': _nameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'phone': '+91${_phoneController.text.trim()}', // Automatic +91 added here
        'address': _addressController.text.trim(),

        // Vehicle Specs
        'vehicleModel': _modelController.text.trim(),
        'vehicleNumber': _regNoController.text.trim(),
        'chassisNumber': _chassisNoController.text.trim(),
        'batteryModel': _batteryModelController.text.trim(),
        'batteryNo': _batteryNoController.text.trim(),
        'purchaseDate': _purchaseDateController.text.trim(),

        // Financials
        'totalAmount': total,
        'receivedAmount': received,
        'pendingAmount': pending,
        'monthlyEmi': monthly,
        'financerName': _financerController.text.trim().isEmpty
            ? 'In-house Ledger'
            : _financerController.text.trim(),

        'createdAt': FieldValue.serverTimestamp(),
      });

      // Initial Transaction Entry (If down payment exists)
      if (received > 0) {
        await docRef.collection('EmiTransactions').add({
          'amount': received,
          'paymentMode': 'Cash / Advance',
          'notes': 'Down payment on purchase',
          'date': FieldValue.serverTimestamp(),
          'remainingBalance': pending,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF0F766E),
            content: Text('Client record created successfully.'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text('System Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _sectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFF0F766E)),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
          ),
        ],
      ),
    );
  }

  Widget _inputBox({
    required TextEditingController controller,
    required String label,
    IconData? icon,
    bool isNumber = false,
    bool isRequired = false,
    VoidCallback? onTap,
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: isNumber ? TextInputType.phone : TextInputType.text,
        validator: isRequired
            ? (v) => (v == null || v.trim().isEmpty) ? '$label is required' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: icon != null ? Icon(icon, size: 20) : null,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Register New Client'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // 1. Personal Info
            _sectionTitle('Client Details', Icons.person),
            _inputBox(controller: _nameController, label: 'Vehicle Owner Name', icon: Icons.badge, isRequired: true),
            _inputBox(controller: _fatherNameController, label: 'Father / Husband Name', icon: Icons.people),
            _inputBox(controller: _phoneController, label: 'Mobile Number (10 digits only)', icon: Icons.phone, isNumber: true, isRequired: true), // User just inputs 10 digits
            _inputBox(controller: _addressController, label: 'Residential Address', icon: Icons.home),

            const Divider(height: 24),

            // 2. Vehicle Specs
            _sectionTitle('Vehicle & Battery Specifications', Icons.electric_rickshaw),
            _inputBox(controller: _modelController, label: 'E-Rickshaw Model (e.g., Mayuri, Saarthi)', icon: Icons.electric_rickshaw),
            _inputBox(controller: _regNoController, label: 'Registration No (RC No)', icon: Icons.confirmation_number),
            _inputBox(controller: _chassisNoController, label: 'Chassis Number', icon: Icons.fingerprint, isRequired: true),
            Row(
              children: [
                Expanded(child: _inputBox(controller: _batteryModelController, label: 'Battery Model')),
                const SizedBox(width: 10),
                Expanded(child: _inputBox(controller: _batteryNoController, label: 'Battery Serial No')),
              ],
            ),
            _inputBox(
              controller: _purchaseDateController,
              label: 'Date of Purchase',
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: _selectPurchaseDate,
            ),

            const Divider(height: 24),

            // 3. Billing / Ledger
            _sectionTitle('Billing & Ledger Details', Icons.account_balance_wallet),
            _inputBox(controller: _totalAmountController, label: 'Total Vehicle Price (₹)', icon: Icons.currency_rupee, isNumber: true, isRequired: true),
            _inputBox(controller: _receivedAmountController, label: 'Down Payment Received (₹)', icon: Icons.payments, isNumber: true),
            Row(
              children: [
                Expanded(child: _inputBox(controller: _monthlyEmiController, label: 'Monthly EMI (₹)', isNumber: true)),
                const SizedBox(width: 10),
                Expanded(child: _inputBox(controller: _financerController, label: 'Financer / Bank')),
              ],
            ),

            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSaving ? null : _saveCustomer,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Save Client Record', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}