import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'presentation/app_shell.dart';

void main() {
  // Ensures Flutter binding is initialized before we run the app
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    // ProviderScope is the root of our Riverpod state tree
    const ProviderScope(
      child: PharmacyApp(),
    ),
  );
}

class PharmacyApp extends StatelessWidget {
  const PharmacyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ShadcnApp(
      title: 'Nexaus Pharmacy',
      // ShadcnApp uses a highly customizable theme system.
      // We start with the default light theme and will customize tokens later.
      theme: ShadcnThemeData(
        colorScheme: const ShadcnColorScheme(
          // A calm, medical, professional blue baseline
          primary: Color(0xFF0284C7), 
          primaryForeground: Colors.white,
          // Destructive red for expired items
          destructive: Color(0xFFDC2626),
          // Muted background for the main app
          background: Color(0xFFF8FAFC),
          card: Colors.white,
        ),
        // Force Bengali font rendering priority
        typography: const ShadcnTypography(
          family: 'Noto Sans Bengali',
        ),
      ),
      // We use web for fast Codespace UI iteration
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}