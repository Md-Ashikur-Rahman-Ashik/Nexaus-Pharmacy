import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' hide Colors, RepeatMode;
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
    // Stripped down to bare minimum to guarantee compilation.
    // shadcn's default theme is already modern and beautiful.
    return ShadcnApp(
      title: 'Nexaus Pharmacy',
      debugShowCheckedModeBanner: false,
      home: const AppShell(),
    );
  }
}