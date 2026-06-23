import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'presentation/app_shell.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
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
      // Material 3 is the modern standard. The colorSchemeSeed generates a beautiful UI automatically.
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF0284C7), // Medical Blue
        fontFamily: 'NotoSansBengali', // Will fallback gracefully if not installed yet
      ),
      home: const AppShell(),
    );
  }
}
