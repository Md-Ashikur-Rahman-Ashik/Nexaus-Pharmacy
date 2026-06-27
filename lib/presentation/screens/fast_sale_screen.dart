import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/presentation/providers/sale_provider.dart';
import 'package:pharmacy_app/presentation/providers/cart_provider.dart';
import 'package:pharmacy_app/database/database.dart';

class FastSaleScreen extends ConsumerStatefulWidget {
  const FastSaleScreen({super.key});

  @override
  ConsumerState<FastSaleScreen> createState() => _FastSaleScreenState();
}

class _FastSaleScreenState extends ConsumerState<FastSaleScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _loadDemoData() {
    final db = PharmacyDatabase.instance.database;
    db.execute("INSERT OR IGNORE INTO companies (id, name) VALUES (1, 'বেক্সিমকো ফার্মা')");
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (1, 'নাপা ৫০০mg', 'প্যারাসিটামল', 'স্ট্রিপ', 80.0)");
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (2, 'সেক্লো ২০mg', 'ওমেপ্রাজল', 'বক্স', 450.0)");
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (3, 'এমোক্সিল ৫০০mg', 'অ্যামোক্সিসিলিন', 'ক্যাপসুল', 120.0)");
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (1, 1, 'NPA24A', 1735689600000, 65.0, 150)");
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (2, 2, 'SCL24B', 1767225600000, 380.0, 40)");
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (3, 3, 'AMX24C', 1735689600000, 95.0, 200)");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ডেমো ডেটা লোড সম্পন্ন!')),
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
        // Top Section: Search & Results
        Expanded(
          flex: 2, // Takes up roughly half the screen
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                OutlinedButton.icon(
                  onPressed: _loadDemoData,
                  icon: const Icon(Icons.download, size: 16),
                  label: const Text('ডেমো মেডিসিন লোড করুন', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(foregroundColor: Colors.orange, side: const BorderSide(color: Colors.orange)),
                ),
                const SizedBox(height: 12),
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
                              subtitle: Text('স্টক: ${product.totalStock} ${product.unitType} | ৳${product.sellingPrice.toStringAsFixed(0)}'),
                              trailing: FilledButton.tonal(
                                onPressed: () {
                                  cartNotifier.addItem(CartItem(
                                    productId: product.id,
                                    batchId: 0, // Simplified for UI demo
                                    brandName: product.brandName,
                                    unitType: product.unitType,
                                    sellingPrice: product.sellingPrice,
                                    quantity: 1,
                                  ));
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

        // Divider
        const Divider(height: 1, thickness: 2),

        // Bottom Section: The Cart
        Expanded(
          flex: 2, // Takes up the other half
          child: Column(
            children: [
              // Cart Header
              Container(
                padding: const EdgeInsets.all(12),
                color: theme.colorScheme.primaryContainer,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('কার্ট (${cart.length} আইটেম)', style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (cart.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => cartNotifier.clearCart(),
                        tooltip: 'কার্ট মুছুন',
                      )
                  ],
                ),
              ),

              // Cart Items List
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
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline, size: 20),
                                  onPressed: () => cartNotifier.updateQuantity(item.productId, item.quantity - 1),
                                ),
                                Text('${item.quantity}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline, size: 20),
                                  onPressed: () => cartNotifier.updateQuantity(item.productId, item.quantity + 1),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),

              // Grand Total & Checkout Button
              if (cart.isNotEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4, offset: const Offset(0, -2))
                    ],
                  ),
                  child: SafeArea(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('মোট বিল', style: TextStyle(color: Colors.grey)),
                            Text(
                              '৳${cartNotifier.grandTotal.toStringAsFixed(2)}',
                              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                            ),
                          ],
                        ),
                        FilledButton.icon(
                          onPressed: () {
                            // TODO: Checkout Logic
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('চেকআউট পরবর্তী ধাপে যোগ হবে!')),
                            );
                          },
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('বিক্রয় সম্পন্ন করুন'),
                        ),
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
