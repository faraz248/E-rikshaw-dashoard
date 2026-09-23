import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/auth/unified_login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const ERickshawKhataHubApp());
}

class ERickshawKhataHubApp extends StatelessWidget {
  const ERickshawKhataHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'E-Rickshaw Khata Hub',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF1E5631),
        scaffoldBackgroundColor: const Color(0xFF121212),
      ),
      home: const HubLoginPortal(),
    );
  }
}
