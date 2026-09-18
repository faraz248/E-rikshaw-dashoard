import 'screens/admin/admin_add_customer_page.dart';
import 'screens/customer/customer_battery_claim_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';
import 'screens/admin/customer_details_page.dart';
import 'screens/customer/customer_emi_view.dart';
import 'screens/admin/admin_dashboard.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ERickshawShop());
}

// ============================================================
// APP
// ============================================================

class ERickshawShop extends StatelessWidget {
  const ERickshawShop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Rickshaw Shop',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          primary: const Color(0xFF0F172A),
          surface: Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF0F172A),
          elevation: 0,
          scrolledUnderElevation: 1,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 18,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            backgroundColor: const Color(0xFF0F172A),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            textStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFF1F5F9),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF0F766E), width: 1.5),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

// ============================================================
// AUTH GATE
// ============================================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          final user = snapshot.data!;

          return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
            future: FirebaseFirestore.instance
                .collection('admins')
                .doc(user.uid)
                .get(),
            builder: (context, adminSnapshot) {
              if (adminSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              if (adminSnapshot.hasError) {
                return const CustomerDashboard();
              }

              if (adminSnapshot.hasData && adminSnapshot.data!.exists) {
                final adminData = adminSnapshot.data!.data();

                if (adminData?['role'] == 'admin') {
                  return const AdminDashboard();
                }
              }

              return const CustomerDashboard();
            },
          );
        }

        return const LoginPage();
      },
    );
  }
}

// ============================================================
// LOGIN PAGE
// ============================================================

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Email aur password dono bharna hai.');
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      showMessage(authError(e.code));
    } catch (e) {
      showMessage('Login failed. Dobara try karo.');
    }

    if (mounted) {
      setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  String authError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Is email se account nahi mila.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email ya password galat hai.';
      case 'invalid-email':
        return 'Email address check karo.';
      case 'too-many-requests':
        return 'Bahut attempts ho gaye. Thodi der baad try karo.';
      default:
        return 'Login nahi ho paya.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  const Icon(
                    Icons.electric_rickshaw,
                    size: 90,
                    color: Colors.green,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'E-Rickshaw Shop 🛺',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text('Customer Login', style: TextStyle(fontSize: 17)),
                  const SizedBox(height: 35),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: loading ? null : login,
                      child: loading
                          ? const CircularProgressIndicator()
                          : const Text('Login', style: TextStyle(fontSize: 17)),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RegisterPage()),
                      );
                    },
                    child: const Text('New customer? Create Account'),
                  ),
                  const SizedBox(height: 8),
                  TextButton.icon(
                    onPressed: loading
                        ? null
                        : () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminLoginPage(),
                              ),
                            );
                          },
                    icon: const Icon(
                      Icons.admin_panel_settings,
                      color: Colors.red,
                    ),
                    label: const Text(
                      'Admin Login',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ADMIN LOGIN PAGE
// ============================================================

class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> adminLogin() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showMessage('Admin email aur password dono bharna hai.');
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AuthGate()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      showMessage(e.message ?? 'Admin login failed.');
    } catch (e) {
      showMessage('Admin login failed. Dobara try karo.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    size: 90,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Admin Login',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Admin Email',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextField(
                    controller: passwordController,
                    obscureText: hidePassword,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        onPressed: () =>
                            setState(() => hidePassword = !hidePassword),
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: loading ? null : adminLogin,
                      icon: const Icon(Icons.login),
                      label: loading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(),
                            )
                          : const Text(
                              'Admin Login',
                              style: TextStyle(fontSize: 17),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// REGISTER PAGE
// ============================================================

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final vehicleNumberController = TextEditingController();
  final chassisNumberController = TextEditingController();
  final vehicleModelController = TextEditingController();
  final batteryDetailsController = TextEditingController();
  final emiDetailsController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    phoneController.dispose();
    addressController.dispose();
    vehicleNumberController.dispose();
    chassisNumberController.dispose();
    vehicleModelController.dispose();
    batteryDetailsController.dispose();
    emiDetailsController.dispose();
    super.dispose();
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final phone = phoneController.text.trim();
    final address = addressController.text.trim();
    final vehicleNumber = vehicleNumberController.text.trim();
    final chassisNumber = chassisNumberController.text.trim();
    final vehicleModel = vehicleModelController.text.trim();
    final batteryDetails = batteryDetailsController.text.trim();
    final emiDetails = emiDetailsController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        phone.isEmpty ||
        address.isEmpty ||
        vehicleNumber.isEmpty ||
        chassisNumber.isEmpty ||
        vehicleModel.isEmpty) {
      showMessage('Saari zaroori details bharna hai.');
      return;
    }

    if (password.length < 6) {
      showMessage('Password kam se kam 6 characters ka rakho.');
      return;
    }

    setState(() => loading = true);

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      final user = credential.user;
      if (user == null) {
        showMessage('Account create nahi ho paya.');
        return;
      }

      await user.updateDisplayName(name);

      await FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .set({
            'name': name,
            'email': email,
            'phone': phone,
            'address': address,
            'vehicleNumber': vehicleNumber,
            'chassisNumber': chassisNumber,
            'vehicleModel': vehicleModel,
            'batteryDetails': batteryDetails,
            'emiDetails': emiDetails,
            'serviceHistory': 'No service record',
            'createdAt': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      showMessage('Account successfully create ho gaya 🎉');
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      showMessage(e.code);
    } catch (e) {
      showMessage('Account create nahi ho paya.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  InputDecoration fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Customer Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 450),
            child: Column(
              children: [
                const Icon(
                  Icons.person_add_alt_1,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: nameController,
                  decoration: fieldDecoration(
                    'Full Name',
                    Icons.person_outline,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: fieldDecoration('Email', Icons.email_outlined),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: fieldDecoration(
                    'Phone Number',
                    Icons.phone_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: addressController,
                  maxLines: 2,
                  decoration: fieldDecoration('Address', Icons.home_outlined),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: vehicleNumberController,
                  decoration: fieldDecoration(
                    'E-Rickshaw Vehicle Number',
                    Icons.confirmation_number_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: chassisNumberController,
                  decoration: fieldDecoration(
                    'E-Rickshaw Chassis Number',
                    Icons.numbers_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: vehicleModelController,
                  decoration: fieldDecoration(
                    'E-Rickshaw Model',
                    Icons.electric_rickshaw_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: batteryDetailsController,
                  decoration: fieldDecoration(
                    'Battery Details',
                    Icons.battery_charging_full_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: emiDetailsController,
                  decoration: fieldDecoration(
                    'EMI Details',
                    Icons.payments_outlined,
                  ),
                ),
                const SizedBox(height: 15),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: fieldDecoration('Password', Icons.lock_outline),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: loading ? null : register,
                    child: loading
                        ? const CircularProgressIndicator()
                        : const Text(
                            'Create Account',
                            style: TextStyle(fontSize: 17),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER DASHBOARD
// ============================================================

class CustomerDashboard extends StatelessWidget {
  const CustomerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Please login again')));
    }

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('customers')
          .doc(user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final data = snapshot.data?.data();
        final name = (data?['name'] ?? user.displayName ?? '')
            .toString()
            .trim();
        final email = (data?['email'] ?? user.email ?? '').toString().trim();
        final phone = (data?['phone'] ?? '').toString().trim();
        final vehicleNumber = (data?['vehicleNumber'] ?? '').toString().trim();
        final vehicleModel = (data?['vehicleModel'] ?? '').toString().trim();

        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'E-Rickshaw Shop 🛺',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                tooltip: 'Logout',
                onPressed: () async => await FirebaseAuth.instance.signOut(),
                icon: const Icon(Icons.logout),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hello ${name.isNotEmpty ? name : 'Customer'} 👋',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  email.isNotEmpty ? email : phone,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Customer Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (phone.isNotEmpty) Text('Phone: $phone'),
                        if (vehicleNumber.isNotEmpty)
                          Text('Vehicle No: $vehicleNumber'),
                        if (vehicleModel.isNotEmpty)
                          Text('Model: $vehicleModel'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.electric_rickshaw),
                    ),
                    title: const Text(
                      'My E-Rickshaw',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerBatteryClaimPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.payments_outlined),
                    ),
                    title: const Text(
                      'EMI & Payments',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CustomerEmiViewPage(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(Icons.description_outlined),
                    ),
                    title: const Text(
                      'My Documents',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DocumentsPage()),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ============================================================
// DOCUMENTS
// ============================================================

class DocumentsPage extends StatelessWidget {
  const DocumentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Documents')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.badge),
              title: Text('Aadhaar Card'),
              subtitle: Text('[Document Redacted]'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.credit_card),
              title: Text('PAN Card'),
              subtitle: Text('Not uploaded'),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ADMIN CUSTOMER LIST
// ============================================================

class CustomerListPage extends StatelessWidget {
  const CustomerListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Customers',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AdminAddCustomerPage()),
        ),
        icon: const Icon(Icons.person_add),
        label: const Text('Add Offline'),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection('customers').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final customers = snapshot.data?.docs ?? [];
          if (customers.isEmpty) {
            return const Center(
              child: Text('No customers found', style: TextStyle(fontSize: 18)),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: customers.length,
            itemBuilder: (context, index) {
              final customer = customers[index];
              final data = customer.data();
              final name = (data['Name'] ?? data['name'] ?? 'Unknown')
                  .toString();
              final phone = (data['Phone'] ?? data['phone'] ?? 'N/A')
                  .toString();

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text('Phone: $phone'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerDetailsPage(
                        customerId: customer.id,
                        data: data,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
