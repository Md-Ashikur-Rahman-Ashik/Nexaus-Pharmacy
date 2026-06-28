import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy_app/presentation/providers/cart_provider.dart';

class CheckoutSheet extends StatefulWidget {
  final double grandTotal;
  final Function(double paidAmount, String? customerName) onConfirm;

  const CheckoutSheet({
    super.key,
    required this.grandTotal,
    required this.onConfirm,
  });

  @override
  State<CheckoutSheet> createState() => _CheckoutSheetState();
}

class _CheckoutSheetState extends State<CheckoutSheet> {
  final TextEditingController _paidController = TextEditingController();
  final TextEditingController _customerController = TextEditingController();
  double dueAmount = 0.0;

  @override
  void initState() {
    super.initState();
    // Default to full cash payment
    _paidController.text = widget.grandTotal.toStringAsFixed(0);
    dueAmount = 0.0;
  }

  void _calculateDue() {
    final paid = double.tryParse(_paidController.text) ?? 0.0;
    setState(() {
      dueAmount = widget.grandTotal - paid;
      if (dueAmount < 0) dueAmount = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('বিক্রয় নিশ্চিত করুন', style: theme.textTheme.titleLarge),
            const SizedBox(height: 20),
            
            // Grand Total Display
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: theme.colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('মোট বিল', style: TextStyle(fontSize: 18)),
                  Text('৳${widget.grandTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Cash Received Input
            TextField(
              controller: _paidController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^0-9.]'))],
              decoration: InputDecoration(
                labelText: 'গ্রহণকৃত ক্যাশ (Cash Received)',
                prefixText: '৳ ',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => _calculateDue(),
            ),
            const SizedBox(height: 16),

            // Due Display (Only show if > 0)
            if (dueAmount > 0) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.orange.shade50, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.orange)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('বাকি (Due)', style: TextStyle(color: Colors.orangeAccent, fontWeight: FontWeight.bold)),
                    Text('৳${dueAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.deepOrange, fontWeight: FontWeight.bold, fontSize: 18)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Customer Name Input (Only ask if there is Due)
              TextField(
                controller: _customerController,
                decoration: InputDecoration(
                  labelText: 'গ্রাহকের নাম (Customer Name)',
                  hintText: 'যেমন: করিম সাহেব',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.person_outline),
                ),
              ),
              const SizedBox(height: 8),
              const Text('নতুন গ্রাহক হলে নাম লিখলেই অটো তৈরি হবে।', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),
            ],

            // Confirm Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton.icon(
                onPressed: () {
                  final paid = double.tryParse(_paidController.text) ?? 0.0;
                  if (paid > widget.grandTotal) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ক্যাশ মোট বিলের বেশি হতে পারে না!')));
                    return;
                  }
                  if (dueAmount > 0 && _customerController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('বাকি থাকলে গ্রাহকের নাম আবশ্যক!')));
                    return;
                  }
                  
                  widget.onConfirm(paid, dueAmount > 0 ? _customerController.text.trim() : null);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('চূড়ান্ত বিক্রয়', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
