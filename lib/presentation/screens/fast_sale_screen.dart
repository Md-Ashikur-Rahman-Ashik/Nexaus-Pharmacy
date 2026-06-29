import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/presentation/providers/sale_provider.dart';
import 'package:pharmacy_app/presentation/providers/cart_provider.dart';
import 'package:pharmacy_app/presentation/screens/checkout_sheet.dart';

class FastSaleScreen extends ConsumerStatefulWidget {
  const FastSaleScreen({super.key});

  @override
  ConsumerState<FastSaleScreen> createState() => _FastSaleScreenState();
}

class _FastSaleScreenState extends ConsumerState<FastSaleScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _openCheckout() {
    final cart = ref.read(cartProvider);
    if (cart.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => CheckoutSheet(
        grandTotal: ref.read(cartProvider.notifier).grandTotal,
        onConfirm: (paidAmount, customerName) {
          try {
            ref.read(salesRepositoryProvider).processSale(cart, paidAmount, customerName);
            ref.read(cartProvider.notifier).clearCart();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('বিক্রয় সফলভাবে সম্পন্ন হয়েছে!', style: TextStyle(color: Colors.white)), backgroundColor: Colors.green),
            );
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('ত্রুটি: $e', style: const TextStyle(color: Colors.white)), backgroundColor: Colors.red),
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchResults = ref.watch(searchProvider);
    final cart = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);

    return Column(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  onChanged: (query) => ref.read(searchProvider.notifier).updateQuery(query),
                  decoration: InputDecoration(
                    hintText: 'ওষুধ খুঁজুন...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: searchResults.isEmpty
                      ? const Center(child: Text('কোনো ওষুধ পাওয়া যায়নি', style: TextStyle(color: Colors.grey)))
                      : ListView.builder(
                          itemCount: searchResults.length,
                          itemBuilder: (context, index) {
                            final product = searchResults[index];
                            return ListTile(
                              title: Text(product.brandName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('স্টক: ${product.availableStock} ${product.unitType} | ৳${product.sellingPrice.toStringAsFixed(0)}'),
                              trailing: FilledButton.tonal(
                                onPressed: () {
                                  cartNotifier.addItem(CartItem(productId: product.id, batchId: product.batchId, brandName: product.brandName, unitType: product.unitType, sellingPrice: product.sellingPrice, quantity: 1));
                                  _searchController.clear();
                                  ref.read(searchProvider.notifier).clearSearch();
                                },
                                child: const Text('যোগ'),
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
        const Divider(height: 1, thickness: 2),
        Expanded(
          flex: 2,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('কার্ট (${cart.length} আইটেম)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (cart.isNotEmpty) IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => cartNotifier.clearCart(), tooltip: 'কার্ট মুছুন')
                  ],
                ),
              ),
              Expanded(
                child: cart.isEmpty
                    ? const Center(child: Text('কার্ট খালি', style: TextStyle(color: Colors.grey)))
                    : ListView.builder(
                        itemCount: cart.length,
                        itemBuilder: (context, index) {
                          final item = cart[index];
                          return ListTile(
                            dense: true,
                            title: Text(item.brandName, style: const TextStyle(fontSize: 14)),
                            subtitle: Text('৳${item.sellingPrice.toStringAsFixed(0)} × ${item.quantity} = ৳${item.subtotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(icon: const Icon(Icons.remove_circle_outline, size: 20), onPressed: () => cartNotifier.updateQuantity(item.batchId, item.quantity - 1)),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(icon: const Icon(Icons.add_circle_outline, size: 20), onPressed: () => cartNotifier.updateQuantity(item.batchId, item.quantity + 1)),
                              ],
                            ),
                          );
                        },
                      ),
              ),
              if (cart.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: theme.colorScheme.surface, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, -2))]),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('মোট বিল', style: TextStyle(color: Colors.grey)),
                            Text('৳${cartNotifier.grandTotal.toStringAsFixed(2)}', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                          ],
                        ),
                        FilledButton.icon(onPressed: _openCheckout, icon: const Icon(Icons.receipt_long), label: const Text('বিক্রয় সম্পন্ন করুন')),
                      ],
                    ),
                  ),
                )
            ],
          ),
        ),
      ],
    );
  }
}
