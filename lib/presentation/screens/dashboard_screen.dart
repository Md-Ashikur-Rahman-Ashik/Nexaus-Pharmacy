import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:pharmacy_app/presentation/providers/dashboard_provider.dart';
import 'package:pharmacy_app/database/database.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  Future<void> _backupDatabase(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final dbPath = '${dir.path}/nexaus_pharmacy.db';
      final file = File(dbPath);
      
      if (await file.exists()) {
        await Share.shareXFiles(
          [XFile(dbPath)],
          subject: 'Nexaus Pharmacy Backup - ${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}',
        );
      } else {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('কোনো ডাটাবেস পাওয়া যায়নি!')));
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('ব্যাকআপ ত্রুটি: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _restoreDatabase(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('সতর্কতা!'),
        content: const Text('ডাটাবেস রিস্টোর করলে বর্তমান সব ডেটা মুছে যাবে এবং ব্যাকআপ ফাইলের ডেটা বসবে। আপনি কি নিশ্চিত?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('না')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('হ্যাঁ, রিস্টোর করুন')),
        ],
      ),
    );

    if (confirm != true || !context.mounted) return;

    try {
      FilePickerResult? result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['db'],
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);
        final dir = await getApplicationDocumentsDirectory();
        final targetPath = '${dir.path}/nexaus_pharmacy.db';

        PharmacyDatabase.instance.close();
        await sourceFile.copy(targetPath);
        await PharmacyDatabase.instance.init();

        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('সফলভাবে ডাটাবেস রিস্টোর হয়েছে! অ্যাপ রিফ্রেশ করুন।'), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('রিস্টোর ত্রুটি: $e'), backgroundColor: Colors.red),
      );
    }
  }

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
            Text('আজকের সারসংক্ষেপ', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                _MetricCard(title: 'আজকের বিক্রয়', value: '৳${data.todaySales.toStringAsFixed(0)}', icon: Icons.attach_money, color: Colors.green),
                const SizedBox(width: 12),
                _MetricCard(title: 'মোট বাকি', value: '৳${data.totalOutstandingDue.toStringAsFixed(0)}', icon: Icons.account_balance_wallet, color: Colors.orange),
              ],
            ),
            const SizedBox(height: 24),

            if (data.expiringSoon.isNotEmpty) ...[
              Text('চিকিৎসা সতর্কতা', style: theme.textTheme.titleMedium?.copyWith(color: Colors.red, fontWeight: FontWeight.bold)),
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
               Card(color: Colors.green.shade50, child: const ListTile(leading: Icon(Icons.check_circle, color: Colors.green), title: Text('কোনো ওষুধ আগামী ৩০ দিনে মেয়াদোত্তীর্ণ হবে না।', style: TextStyle(color: Colors.green)))),
               const SizedBox(height: 24),
            ],

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

            const SizedBox(height: 40),
            const Divider(),
            const SizedBox(height: 16),
            Text('সিস্টেম মেইন্টেন্যান্স', style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.upload),
                    label: const Text('ব্যাকআপ (WhatsApp)'),
                    onPressed: () => _backupDatabase(context),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.blue, side: const BorderSide(color: Colors.blue)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.download),
                    label: const Text('রিস্টোর (ফাইল থেকে)'),
                    onPressed: () => _restoreDatabase(context),
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.purple, side: const BorderSide(color: Colors.purple)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('ডেটা লোড করতে ত্রুটি: $e')),
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 0,
        color: color.withValues(alpha: 0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.3))),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [Icon(icon, color: color, size: 20), const SizedBox(width: 8), Expanded(child: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500, fontSize: 13)))]),
              const SizedBox(height: 8),
              Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }
}
