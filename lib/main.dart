import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/database/database.dart';
import 'presentation/app_shell.dart';

void main() async {
  // Required for async calls in main
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the SQLite database file on the physical device
  await PharmacyDatabase.instance.init();
  
  runApp(
    const ProviderScope(
      child: PharmacyApp(),
    ),
  );
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nexaus Pharmacy',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0284C7),
      ),
      home: const AppShell(),
    );
  }
}
