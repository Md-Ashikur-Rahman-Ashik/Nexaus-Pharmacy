import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/presentation/providers/dashboard_provider.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardProvider);
    final theme = Theme.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(dashboardProvider.future),
      child: dashboardAsync.when(
        data: (data) => ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Header
            Text('আজকের সারসংক্ষেপ', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Top Metrics Row
            Row(
              children: [
                _MetricCard(
                  title: 'আজকের বিক্রয়',
                  value: '৳${data.todaySales.toStringAsFixed(0)}',
                  icon: Icons.attach_money,
                  color: Colors.green,
                ),
                const SizedBox(width: 12),
                _MetricCard(
                  title: 'মোট বাকি',
                  value: '৳${data.totalOutstandingDue.toStringAsFixed(0)}',
                  icon: Icons.account_balance_wallet,
                  color: Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Expiry Warnings (Critical!)
            if (data.expiringSoon.isNotEmpty) ...[
              Text('চিকিৎসা সতর্কতা: মেয়াদ উত্তীর্ণের আগে', style: theme.textTheme.titleMedium?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              ...data.expiringSoon.map((exp) => Card(
                color: Colors.red.shade50,
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.warning_amber, color: Colors.red),
                  title: Text(exp.brandName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  subtitle: Text('ব্যাচ: ${exp.batchNumber}'),
                  trailing: Text(exp.expiryDateFormatted, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              )),
              const SizedBox(height: 24),
            ] else ...[
               Card(
                 color: Colors.green.shade50,
                 child: const ListTile(
                   leading: Icon(Icons.check_circle, color: Colors.green),
                   title: Text('কোনো ওষুধ আগামী ৩০ দিনে মেয়াদোত্তীর্ণ হবে না।', style: TextStyle(color: Colors.green)),
                 ),
               ),
               const SizedBox(height: 24),
            ],

            // Top Debtors
            Text('শীর্ষ ঋণগ্রহীতা', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (data.topDebtors.isEmpty)
              const Card(child: ListTile(title: Text('কারো কোনো বাকি নেই!', style: TextStyle(color: Colors.grey))))
            else
              ...data.topDebtors.map((debtor) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(child: Text(debtor.name[0])),
                  title: Text(debtor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: Text('৳${debtor.due.toStringAsFixed(0)}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              )),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ডেটা লোড করতে ত্রুটি: $e')),
      ),
    );
  }
}

// Helper Widget for the Top Cards
class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withOpacity(0.3))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: color, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13))),
                ],
              ),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
