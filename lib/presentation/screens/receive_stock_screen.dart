import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharmacy_app/data/repositories/purchase_repository.dart';
import 'package:pharmacy_app/database/database.dart';

class ReceiveStockScreen extends StatefulWidget {
  const ReceiveStockScreen({super.key});

  @override
  State<ReceiveStockScreen> createState() => _ReceiveStockScreenState();
}

class _ReceiveStockScreenState extends State<ReceiveStockScreen> {
  final _formKey = GlobalKey<FormState>();
  final PurchaseRepository _repo = PurchaseRepository(PharmacyDatabase.instance);
  
  // Controllers
  final _companyCtrl = TextEditingController();
  final _brandCtrl = TextEditingController();
  final _genericCtrl = TextEditingController();
  final _batchCtrl = TextEditingController();
  final _costCtrl = TextEditingController();
  final _sellCtrl = TextEditingController();
  final _qtyCtrl = TextEditingController();
  
  String _unitType = 'স্ট্রিপ'; // Default
  DateTime? _expiryDate;

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)), // Meds usually expire 1-3 years out
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _expiryDate = picked);
  }

  void _submit() {
    if (!_formKey.currentState!.validate() || _expiryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('সব তথ্য সঠিকভাবে পূরণ করুন (তারিখ সহ)')));
      return;
    }

    try {
      _repo.processInboundStock(
        companyName: _companyCtrl.text.trim(),
        brandName: _brandCtrl.text.trim(),
        genericName: _genericCtrl.text.trim(),
        unitType: _unitType,
        sellingPrice: double.parse(_sellCtrl.text),
        batchNumber: _batchCtrl.text.trim(),
        expiryDateMs: _expiryDate!.millisecondsSinceEpoch,
        costPrice: double.parse(_costCtrl.text),
        quantity: int.parse(_qtyCtrl.text),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('সফলভাবে মালামাল গ্রহণ করা হয়েছে!'), backgroundColor: Colors.green),
      );
      
      _formKey.currentState!.reset();
      setState(() => _expiryDate = null); // Reset date picker
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ত্রুটি: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _companyCtrl.dispose();
    _brandCtrl.dispose();
    _genericCtrl.dispose();
    _batchCtrl.dispose();
    _costCtrl.dispose();
    _sellCtrl.dispose();
    _qtyCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('নতুন মালামাল গ্রহণ করুন', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            // Company Info
            TextFormField(controller: _companyCtrl, decoration: const InputDecoration(labelText: 'কোম্পানির নাম *', hintText: 'যেমন: স্কয়ার', prefixIcon: Icon(Icons.business))),// Product Info
            const SizedBox(height: 12),
            TextFormField(controller: _brandCtrl, decoration: const InputDecoration(labelText: 'ব্র্যান্ড নাম *', hintText: 'যেমন: নাপা ৫০০mg', prefixIcon: Icon(Icons.medication))),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _genericCtrl, decoration: const InputDecoration(labelText: 'জেনেরিক নাম', hintText: 'প্যারাসিটামল'))),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _unitType,
                    decoration: const InputDecoration(labelText: 'ইউনিট'),
                    items: const [
                      DropdownMenuItem(value: 'স্ট্রিপ', child: Text('স্ট্রিপ')),
                      DropdownMenuItem(value: 'বক্স', child: Text('বক্স')),
                      DropdownMenuItem(value: 'ক্যাপসুল', child: Text('ক্যাপসুল')),
                      DropdownMenuItem(value: 'ভায়াল', child: Text('ভায়াল')),
                      DropdownMenuItem(value: 'টিউব', child: Text('টিউব')),
                    ],
                    onChanged: (val) => setState(() => _unitType = val!),
                  ),
                ),
              ],
            ),
            
            // Batch & Expiry
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _batchCtrl, decoration: const InputDecoration(labelText: 'ব্যাচ নম্বর *', hintText: 'NPA24A'))),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: _selectDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'মেয়াদ উত্তীর্ণ *', prefixIcon: Icon(Icons.calendar_today)),
                      child: Text(
                        _expiryDate == null ? 'তারিখ নির্বাচন করুন' : '${_expiryDate!.day}/${_expiryDate!.month}/${_expiryDate!.year}',
                        style: TextStyle(color: _expiryDate == null ? Colors.grey : Colors.black),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Pricing & Quantity
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: TextFormField(controller: _costCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^0-9.]'))], decoration: const InputDecoration(labelText: 'ক্রয়মূল্য (প্রতি ইউনিট) *', prefixText: '৳ '))),
                const SizedBox(width: 12),
                Expanded(child: TextFormField(controller: _sellCtrl, keyboardType: const TextInputType.numberWithOptions(decimal: true), inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[^0-9.]'))], decoration: const InputDecoration(labelText: 'বিক্রয়মূল্য (প্রতি ইউনিট) *', prefixText: '৳ '))),
              ],
            ),
            const SizedBox(height: 12),
            TextFormField(controller: _qtyCtrl, keyboardType: TextInputType.number, inputFormatters: [FilteringTextInputFormatter.digitsOnly], decoration: const InputDecoration(labelText: 'পরিমাণ *', prefixIcon: Icon(Icons.format_list_numbered))),

            const SizedBox(height: 24),
            
            SizedBox(
              height: 50,
              child: FilledButton.icon(
                onPressed: _submit,
                icon: const Icon(Icons.inventory),
                label: const Text('ইনভেন্টরিতে যোগ করুন', style: TextStyle(fontSize: 16)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
