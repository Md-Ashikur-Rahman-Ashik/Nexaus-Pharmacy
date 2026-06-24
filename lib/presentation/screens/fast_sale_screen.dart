import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/data/repositories/product_repository.dart';
import 'package:pharmacy_app/presentation/providers/sale_provider.dart';
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
    
    // Insert Dummy Company
    db.execute("INSERT OR IGNORE INTO companies (id, name) VALUES (1, 'বেক্সিমকো ফার্মা')");

    // Insert Dummy Products
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (1, 'নাপা ৫০০mg', 'প্যারাসিটামল', 'স্ট্রিপ', 80.0)");
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (2, 'সেক্লো ২০mg', 'ওমেপ্রাজল', 'বক্স', 450.0)");
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (3, 'এমোক্সিল ৫০০mg', 'অ্যামোক্সিসিলিন', 'ক্যাপসুল', 120.0)");
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (4, 'অর্ভাস এম', 'অর্টিকাস্টেরয়েড', 'ইনহেলার', 850.0)");
    db.execute("INSERT OR IGNORE INTO products (id, brand_name, generic_name, unit_type, selling_price) VALUES (5, 'নেক্সাম সি.ভি', 'সেফালেক্সিন', 'ক্যাপসুল', 350.0)");

    // Insert Dummy Batches (So they have stock)
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (1, 1, 'NPA24A', 1735689600000, 65.0, 150)");
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (2, 2, 'SCL24B', 1767225600000, 380.0, 40)");
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (3, 3, 'AMX24C', 1735689600000, 95.0, 200)");
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (4, 4, 'ORV24D', 1767225600000, 700.0, 15)");
    db.execute("INSERT OR IGNORE INTO batches (id, product_id, batch_number, expiry_date, cost_price, quantity) VALUES (5, 5, 'NXC24E', 1735689600000, 280.0, 80)");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ডেমো ডেটা লোড সম্পন্ন! এখন খুঁজুন।')),
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // TEMPORARY DEMO BUTTON
          OutlinedButton.icon(
            onPressed: _loadDemoData,
            icon: const Icon(Icons.download),
            label: const Text('ডেমো মেডিসিন লোড করুন (Tap once)'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.orange,
              side: const BorderSide(color: Colors.orange),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: _searchController,
            onChanged: (query) {
              ref.read(searchProvider.notifier).updateQuery(query);
            },
            decoration: InputDecoration(
              hintText: 'ওষুধ খুঁজুন... (e.g., সেক্লো, নাপা)',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: searchResults.isEmpty
                ? const Center(
                    child: Text(
                      'কোনো ওষুধ পাওয়া যায়নি',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  )
                : ListView.builder(
                    itemCount: searchResults.length,
                    itemBuilder: (context, index) {
                      final product = searchResults[index];
                      return _ProductCard(product: product);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final ProductSearchResult product;

  const _ProductCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.brandName,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'স্টক: ${product.totalStock} ${product.unitType}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '৳${product.sellingPrice.toStringAsFixed(0)}',
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: () {
                    // TODO: Add to cart logic
                  },
                  child: const Text('যোগ করুন'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
