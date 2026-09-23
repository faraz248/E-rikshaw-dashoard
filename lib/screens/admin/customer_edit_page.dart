import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomerEditPage extends StatefulWidget {
  final String customerId;

  const CustomerEditPage({super.key, required this.customerId});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final _formKey = GlobalKey<FormState>();

  // Personal Info
  late TextEditingController _nameController;
  late TextEditingController _fatherNameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;

  // Vehicle Info
  late TextEditingController _modelController;
  late TextEditingController _vehicleNoController;
  late TextEditingController _chassisController;
  late TextEditingController _batteryModelController;
  late TextEditingController _batteryNoController;
  late TextEditingController _purchaseDateController;

  // Ledger / Finance Info
  late TextEditingController _totalAmountController;
  late TextEditingController _pendingAmountController;
  late TextEditingController _monthlyEmiController;
  late TextEditingController _financerController;

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _fatherNameController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();

    _modelController = TextEditingController();
    _vehicleNoController = TextEditingController();
    _chassisController = TextEditingController();
    _batteryModelController = TextEditingController();
    _batteryNoController = TextEditingController();
    _purchaseDateController = TextEditingController();

    _totalAmountController = TextEditingController();
    _pendingAmountController = TextEditingController();
    _monthlyEmiController = TextEditingController();
    _financerController = TextEditingController();

    _loadCustomerData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _fatherNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _modelController.dispose();
    _vehicleNoController.dispose();
    _chassisController.dispose();
    _batteryModelController.dispose();
    _batteryNoController.dispose();
    _purchaseDateController.dispose();
    _totalAmountController.dispose();
    _pendingAmountController.dispose();
    _monthlyEmiController.dispose();
    _financerController.dispose();
    super.dispose();
  }

  String _getVal(Map<String, dynamic> data, String k1, String k2) {
    return (data[k1] ?? data[k2] ?? '').toString();
  }

  Future<void> _loadCustomerData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('Customers')
          .doc(widget.customerId)
          .get();
      if (doc.exists) {
        final data = doc.data() ?? {};
        _nameController.text = _getVal(data, 'name', 'Name');
        _fatherNameController.text = _getVal(data, 'fatherName', 'Father Name');
        _phoneController.text = _getVal(data, 'phone', 'Phone');
        _addressController.text = _getVal(data, 'address', 'Address');

        _modelController.text = _getVal(data, 'vehicleModel', 'Vehicle Model');
        _vehicleNoController.text =
            _getVal(data, 'vehicleNumber', 'Vehicle Number');
        _chassisController.text =
            _getVal(data, 'chassisNumber', 'Chassis Number');
        _batteryModelController.text =
            _getVal(data, 'batteryModel', 'batteryType');
        _batteryNoController.text =
            _getVal(data, 'batteryNo', 'batteryDetails');
        _purchaseDateController.text =
            _getVal(data, 'purchaseDate', 'purchase_date');

        _totalAmountController.text =
            _getVal(data, 'totalAmount', 'Total Amount');
        _pendingAmountController.text =
            _getVal(data, 'pendingAmount', 'Pending Amount');
        _monthlyEmiController.text = _getVal(data, 'monthlyEmi', 'Monthly EMI');
        _financerController.text = _getVal(data, 'financerName', 'Financer');
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final double total =
          double.tryParse(_totalAmountController.text.trim()) ?? 0.0;
      final double pending =
          double.tryParse(_pendingAmountController.text.trim()) ?? 0.0;
      final double monthly =
          double.tryParse(_monthlyEmiController.text.trim()) ?? 0.0;

      await FirebaseFirestore.instance
          .collection('Customers')
          .doc(widget.customerId)
          .set({
        'name': _nameController.text.trim(),
        'Name': _nameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'Phone': _phoneController.text.trim(),
        'address': _addressController.text.trim(),
        'Address': _addressController.text.trim(),
        'vehicleModel': _modelController.text.trim(),
        'Vehicle Model': _modelController.text.trim(),
        'vehicleNumber': _vehicleNoController.text.trim(),
        'Vehicle Number': _vehicleNoController.text.trim(),
        'chassisNumber': _chassisController.text.trim(),
        'Chassis Number': _chassisController.text.trim(),
        'batteryModel': _batteryModelController.text.trim(),
        'batteryNo': _batteryNoController.text.trim(),
        'purchaseDate': _purchaseDateController.text.trim(),
        'totalAmount': total,
        'pendingAmount': pending,
        'monthlyEmi': monthly,
        'financerName': _financerController.text.trim(),
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF0F766E),
          content: Text('Customer details update ho gayi!'),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(backgroundColor: Colors.red, content: Text('Error: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Color(0xFF0F172A)),
      ),
    );
  }

  Widget _editField(TextEditingController controller, String label,
      {bool isNumber = false, bool isRequired = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        validator: isRequired
            ? (v) => (v == null || v.trim().isEmpty) ? 'Zaroori field' : null
            : null,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: Colors.grey.shade300)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Edit Customer Record'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0F172A),
        elevation: 0.5,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _sectionTitle('Customer Details'),
            _editField(_nameController, 'Vehicle Owner Name', isRequired: true),
            _editField(_fatherNameController, 'Father / Husband Name'),
            _editField(_phoneController, 'Mobile Number',
                isNumber: true, isRequired: true),
            _editField(_addressController, 'Address / Village'),
            _sectionTitle('Vehicle & Battery Details'),
            _editField(_modelController, 'Vehicle Model'),
            _editField(_vehicleNoController, 'Vehicle Registration No (RC)'),
            _editField(_chassisController, 'Chassis Number', isRequired: true),
            Row(
              children: [
                Expanded(
                    child:
                        _editField(_batteryModelController, 'Battery Model')),
                const SizedBox(width: 8),
                Expanded(
                    child:
                        _editField(_batteryNoController, 'Battery Serial No')),
              ],
            ),
            _editField(
                _purchaseDateController, 'Date of Purchase (DD/MM/YYYY)'),
            _sectionTitle('Ledger / Financing Details'),
            _editField(_totalAmountController, 'Total Amount (₹)',
                isNumber: true),
            _editField(_pendingAmountController, 'Pending Amount / Balance (₹)',
                isNumber: true),
            Row(
              children: [
                Expanded(
                    child: _editField(_monthlyEmiController, 'Monthly EMI (₹)',
                        isNumber: true)),
                const SizedBox(width: 8),
                Expanded(
                    child: _editField(_financerController, 'Financer Name')),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F766E),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _isSaving ? null : _saveChanges,
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Update & Save Changes',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
