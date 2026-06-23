import 'package:flutter/material.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  // Placeholder screens for now
  final List<Widget> _screens = [
    const Center(child: Text('ড্যাশবোর্ড (Dashboard)')),
    const Center(child: Text('দ্রুত বিক্রয় (Fast Sale)')),
    const Center(child: Text('ইনভেন্টরি (Inventory)')),
    const Center(child: Text('বাকি খাতা (Due Khata)')),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = ShadcnTheme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
      // Shadcn provides a NavigationBar widget that adheres to our design tokens
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'ড্যাশবোর্ড', // Dashboard
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'বিক্রয়', // Sale
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'মালামাল', // Inventory/Goods
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'বাকি', // Due
          ),
        ],
      ),
    );
  }
}