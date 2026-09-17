import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../theme/app_theme.dart';

class CustomerEditPage extends StatefulWidget {
  final String? customerId;
  final Map<String, dynamic>? initialData;

  const CustomerEditPage({super.key, this.customerId, this.initialData});

  @override
  State<CustomerEditPage> createState() => _CustomerEditPageState();
}

class _CustomerEditPageState extends State<CustomerEditPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleNoController = TextEditingController();
  final _modelController = TextEditingController();
  final _pendingAmountController = TextEditingController();
  final _totalEmiController = TextEditingController();
  final _rcUrlController = TextEditingController();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    if (widget.customerId != null) {
      _loadExistingData();
    }
  }

  Future<void> _loadExistingData() async {
    final doc = await FirebaseFirestore.instance
        .collection('customers')
        .doc(widget.customerId)
        .get();

    if (doc.exists && mounted) {
      final data = doc.data() as Map<String, dynamic>;
      _nameController.text = (data['name'] ?? '').toString();
      _phoneController.text = (data['phone'] ?? '').toString();
      _vehicleNoController.text = (data['vehicleNo'] ?? '').toString();
      _modelController.text = (data['model'] ?? '').toString();
      _pendingAmountController.text = (data['pendingAmount'] ?? '0').toString();
      _totalEmiController.text = (data['totalEmi'] ?? '12').toString();
      final docs = data['documents'] as Map<String, dynamic>? ?? {};
      _rcUrlController.text = (docs['rc_url'] ?? '').toString();
      setState(() {});
    }
  }

  Future<void> _saveVehicleRecord() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final payload = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'vehicleNo': _vehicleNoController.text.trim().toUpperCase(),
        'model': _modelController.text.trim(),
        'pendingAmount':
            num.tryParse(_pendingAmountController.text.trim()) ?? 0,
        'totalEmi': int.tryParse(_totalEmiController.text.trim()) ?? 12,
        'documents': {
          'rc_url': _rcUrlController.text.trim(),
          'insurance_url': '',
          'battery_card_url': '',
          'aadhaar_url': '',
        },
      };

      if (widget.customerId != null) {
        await FirebaseFirestore.instance
            .collection('customers')
            .doc(widget.customerId)
            .update(payload);
      } else {
        payload['paidEmi'] = 0;
        payload['createdAt'] = FieldValue.serverTimestamp();
        await FirebaseFirestore.instance.collection('customers').add(payload);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: AppColors.emerald600,
            content: Text('Customer & Vehicle details saved!'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.red500,
            content: Text('Error: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.slate100,
      appBar: AppBar(
        title: Text(
          widget.customerId != null
              ? 'Edit Customer Details'
              : 'New Vehicle Onboarding',
          style: AppText.heading,
        ),
        backgroundColor: Colors.white,
        elevation: 0.5,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionHeader('DRIVER & VEHICLE DETAILS'),
              _buildInputCard([
                _buildField(
                  'Driver Full Name',
                  _nameController,
                  Icons.person_outline,
                ),
                const SizedBox(height: 12),
                _buildField(
                  'Phone Number',
                  _phoneController,
                  Icons.phone_outlined,
                  keyboard: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                _buildField(
                  'Vehicle Registration No (RC)',
                  _vehicleNoController,
                  Icons.pin_outlined,
                ),
                const SizedBox(height: 12),
                _buildField(
                  'Model (e.g. Mayuri Deluxe / Yatri)',
                  _modelController,
                  Icons.electric_rickshaw_outlined,
                ),
              ]),
              const SizedBox(height: 20),
              _sectionHeader('EMI & BALANCE KHATA'),
              _buildInputCard([
                _buildField(
                  'Due Balance (₹)',
                  _pendingAmountController,
                  Icons.currency_rupee_rounded,
                  keyboard: TextInputType.number,
                ),
                const SizedBox(height: 12),
                _buildField(
                  'Total Installments (Tenure)',
                  _totalEmiController,
                  Icons.calendar_month_outlined,
                  keyboard: TextInputType.number,
                ),
              ]),
              const SizedBox(height: 20),
              _sectionHeader('CLOUD DOCUMENT LINK (Cloudinary/Storage)'),
              _buildInputCard([
                _buildField(
                  'RC Document Image URL',
                  _rcUrlController,
                  Icons.link_rounded,
                ),
              ]),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.slate900,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _isSaving ? null : _saveVehicleRecord,
                  child: _isSaving
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save & Update Record',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11.5,
          fontWeight: FontWeight.w700,
          color: AppColors.slate500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInputCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      validator: (val) =>
          (val == null || val.trim().isEmpty) ? 'Required field' : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.slate500, size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
      ),
    );
  }
}
