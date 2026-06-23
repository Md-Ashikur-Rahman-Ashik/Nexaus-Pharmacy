import 'package:pharmacy_app/database/database.dart';

class ProductRepository {
  final PharmacyDatabase _db;

  // We pass the database instance to the repository
  ProductRepository(this._db);

  // Search products by brand name or generic name (Bengali/English safe)
  List<Map<String, dynamic>> searchProducts(String query) {
    if (query.isEmpty) return [];

    // Using LIKE for simple, ultra-fast offline searching
    // The '%' acts as a wildcard (e.g., '%সে%' finds 'সেক্লো')
    final results = _db.database.select(
      'SELECT p.id, p.brand_name, p.selling_price, p.unit_type, '
      'SUM(b.quantity) as total_stock '
      'FROM products p '
      'LEFT JOIN batches b ON p.id = b.product_id '
      'WHERE p.brand_name LIKE ? OR p.generic_name LIKE ? '
      'GROUP BY p.id '
      'HAVING total_stock > 0 '
      'ORDER BY p.brand_name ASC',
      ['%$query%', '%$query%'],
    );

    // SQLite returns rows as Lists of Lists. We convert them to Maps for easy UI use.
    return results.map((row) {
      return <String, dynamic>{
        'id': row[0],
        'brand_name': row[1],
        'selling_price': row[2],
        'unit_type': row[3],
        'total_stock': row[4],
      };
    }).toList();
  }
}