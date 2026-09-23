import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../models/customer_model.dart';
import '../services/customer_service.dart';

class AddCustomerScreen extends StatefulWidget {
  final String shopId;

  const AddCustomerScreen({super.key, required this.shopId});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final CustomerService _customerService = CustomerService();

  final _nameController = TextEditingController();
  final _fatherController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _chassisController = TextEditingController();
  final _motorController = TextEditingController();
  final _batteryController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();
  final _financerController = TextEditingController();
  final _totalAmountController = TextEditingController();
  final _emiController = TextEditingController();

  File? _imageFile;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _fatherController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _chassisController.dispose();
    _motorController.dispose();
    _batteryController.dispose();
    _vehicleNoController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _financerController.dispose();
    _totalAmountController.dispose();
    _emiController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 70);
    if (picked != null) {
      setState(() {
        _imageFile = File(picked.path);
      });
    }
  }

  Future<String?> _uploadImage(String phone) async {
    if (_imageFile == null) return null;
    try {
      final ref = FirebaseStorage.instance.ref().child(
        'customers/${widget.shopId}_${phone}_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      await ref.putFile(_imageFile!);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  void _saveCustomer() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    String? photoUrl;
    if (_imageFile != null) {
      photoUrl = await _uploadImage(_phoneController.text.trim());
    }

    final customer = CustomerModel(
      shopId: widget.shopId,
      name: _nameController.text.trim(),
      fatherName: _fatherController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
      photoUrl: photoUrl,
      chassisNo: _chassisController.text.trim(),
      motorNo: _motorController.text.trim(),
      batteryNo: _batteryController.text.trim(),
      vehicleNo: _vehicleNoController.text.trim(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim(),
      financerName: _financerController.text.trim(),
      totalAmount: double.tryParse(_totalAmountController.text.trim()) ?? 0.0,
      monthlyEmi: double.tryParse(_emiController.text.trim()) ?? 0.0,
      registrationDate: DateTime.now(),
    );

    try {
      await _customerService.addCustomer(customer);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Customer successfully add ho gaya!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo via Camera'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () {
                Navigator.pop(ctx);
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Customer / Invoice')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: _imageFile != null
                                ? FileImage(_imageFile!)
                                : null,
                            child: _imageFile == null
                                ? const Icon(
                                    Icons.person,
                                    size: 55,
                                    color: Colors.grey,
                                  )
                                : null,
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 18,
                              backgroundColor: Theme.of(context).primaryColor,
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  size: 18,
                                  color: Colors.white,
                                ),
                                onPressed: _showImagePickerSheet,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      _nameController,
                      'Customer Name',
                      Icons.person,
                    ),
                    _buildTextField(
                      _fatherController,
                      'Father / Husband Name',
                      Icons.person_outline,
                    ),
                    _buildTextField(
                      _phoneController,
                      'Mobile Number',
                      Icons.phone,
                      keyboard: TextInputType.phone,
                    ),
                    _buildTextField(
                      _addressController,
                      'Address / Village',
                      Icons.home,
                    ),
                    const Divider(height: 32),
                    _buildTextField(
                      _vehicleNoController,
                      'Registration No (e.g. UP73T...)',
                      Icons.confirmation_number,
                    ),
                    _buildTextField(
                      _chassisController,
                      'Chassis Number',
                      Icons.qr_code,
                    ),
                    _buildTextField(
                      _motorController,
                      'Motor Number',
                      Icons.settings,
                    ),
                    _buildTextField(
                      _batteryController,
                      'Battery Number',
                      Icons.battery_charging_full,
                    ),
                    _buildTextField(
                      _modelController,
                      'Model (e.g. APM Passenger)',
                      Icons.electric_rickshaw,
                    ),
                    _buildTextField(
                      _colorController,
                      'Color (e.g. O Blue / Green)',
                      Icons.color_lens,
                    ),
                    const Divider(height: 32),
                    _buildTextField(
                      _financerController,
                      'Financer / Bank (e.g. Akasa Finance)',
                      Icons.account_balance,
                    ),
                    _buildTextField(
                      _totalAmountController,
                      'Total Invoice Amount',
                      Icons.currency_rupee,
                      keyboard: TextInputType.number,
                    ),
                    _buildTextField(
                      _emiController,
                      'Monthly EMI Amount',
                      Icons.payments,
                      keyboard: TextInputType.number,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _saveCustomer,
                        child: const Text(
                          'Save Customer Record',
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            (value == null || value.isEmpty) ? 'Yeh field zaroori hai' : null,
      ),
    );
  }
}
