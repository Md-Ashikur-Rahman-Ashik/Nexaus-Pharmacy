import 'package:pharmacy_app/database/database.dart';
import 'package:sqlite3/sqlite3.dart' show Row;

class ProductSearchResult {
  final int id;
  final String brandName;
  final double sellingPrice;
  final String unitType;
  final int totalStock;

  ProductSearchResult({
    required this.id,
    required this.brandName,
    required this.sellingPrice,
    required this.unitType,
    required this.totalStock,
  });
}

class ProductRepository {
  final PharmacyDatabase _db;

  ProductRepository(this._db);

  List<ProductSearchResult> searchProducts(String query) {
    if (query.isEmpty) return [];

    const sql = '''
      SELECT p.id, p.brand_name, p.selling_price, p.unit_type, 
      SUM(b.quantity) as total_stock 
      FROM products p 
      LEFT JOIN batches b ON p.id = b.product_id 
      WHERE p.brand_name LIKE ? OR p.generic_name LIKE ? 
      GROUP BY p.id 
      HAVING total_stock > 0 
      ORDER BY p.brand_name ASC
    ''';

    final results = _db.database.select(sql, ['%$query%', '%$query%']);

    final List<ProductSearchResult> output = [];
    for (final Row row in results) {
      output.add(
        ProductSearchResult(
          id: row.columnAt(0) as int,
          brandName: row.columnAt(1) as String,
          sellingPrice: (row.columnAt(2) as num).toDouble(),
          unitType: row.columnAt(3) as String,
          totalStock: row.columnAt(4) as int,
        ),
      );
    }

    return output;
  }
}
