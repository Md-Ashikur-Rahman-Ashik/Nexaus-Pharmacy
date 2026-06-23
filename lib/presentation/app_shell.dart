import 'package:shadcn_flutter/shadcn_flutter.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    Center(child: Text('ড্যাশবোর্ড (Dashboard)')),
    Center(child: Text('দ্রুত বিক্রয় (Fast Sale)')),
    Center(child: Text('ইনভেন্টরি (Inventory)')),
    Center(child: Text('বাকি খাতা (Due Khata)')),
  ];

  @override
  Widget build(BuildContext context) {
    // We use Shadcn's Scaffold, not Material's Scaffold
    return Scaffold(
      body: SafeArea(
        child: _screens[_currentIndex],
      ),
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
            label: 'ড্যাশবোর্ড',
          ),
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale),
            label: 'বিক্রয়',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'মালামাল',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'বাকি',
          ),
        ],
      ),
    );
  }
}
