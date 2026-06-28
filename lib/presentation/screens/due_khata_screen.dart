import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy_app/data/repositories/due_repository.dart';
import 'package:pharmacy_app/database/database.dart';

class DueKhataScreen extends StatefulWidget {
  const DueKhataScreen({super.key});

  @override
  State<DueKhataScreen> createState() => _DueKhataScreenState();
}

class _DueKhataScreenState extends State<DueKhataScreen> {
  final DueRepository _dueRepo = DueRepository(PharmacyDatabase.instance);
  late List<CustomerDue> _debtors;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDebtors();
  }

  void _loadDebtors() {
    setState(() => _isLoading = true);
    _debtors = _dueRepo.getActiveDebtors();
    setState(() => _isLoading = false);
  }

  void _showPaymentDialog(CustomerDue debtor) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('${debtor.name} - পেমেন্ট'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('বর্তমান বাকি: ৳${debtor.totalDue.toStringAsFixed(2)}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^0-9.]'))],
              decoration: const InputDecoration(
                labelText: 'গ্রহণকৃত টাকা',
                prefixText: '৳ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('বাতিল')),
          FilledButton(
            onPressed: () {
              final paid = double.tryParse(amountController.text) ?? 0.0;
              if (paid <= 0 || paid > debtor.totalDue) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('অবৈধ পরিমাণ!')));
                return;
              }
              _dueRepo.recordPayment(debtor.id, paid);
              Navigator.pop(context);
              _loadDebtors(); // Refresh the list
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('৳${paid.toStringAsFixed(0)} পেমেন্ট সম্পন্ন!'), backgroundColor: Colors.green),
              );
            },
            child: const Text('জমা দিন'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : _debtors.isEmpty
            ? const Center(child: Text('কারো কোনো বাকি নেই!', style: TextStyle(color: Colors.grey, fontSize: 16)))
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _debtors.length,
                itemBuilder: (context, index) {
                  final debtor = _debtors[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: theme.colorScheme.surfaceContainerLow,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Left: Customer Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(debtor.name, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                                if (debtor.phone != null)
                                  Text(debtor.phone!, style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey)),
                              ],
                            ),
                          ),
                          // Right: Amount & Pay Button
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '৳${debtor.totalDue.toStringAsFixed(0)}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  color: Colors.deepOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              OutlinedButton.icon(
                                onPressed: () => _showPaymentDialog(debtor),
                                icon: const Icon(Icons.receive_money, size: 18),
                                label: const Text('জমা', style: TextStyle(fontSize: 12)),
                                style: OutlinedButton.styleFrom(foregroundColor: Colors.green, side: const BorderSide(color: Colors.green)),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
  }
}
