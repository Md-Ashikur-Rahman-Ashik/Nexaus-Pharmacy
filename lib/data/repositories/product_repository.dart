import 'package:pharmacy_app/database/database.dart';
import 'package:sqlite3/sqlite3.dart' show Row;

class ProductSearchResult {
  final int id;
  final String brandName;
  final double sellingPrice;
  final String unitType;
  final int batchId; // NEW: We now know exactly which box to take from
  final int availableStock; // RENAMED: Stock specific to this batch

  ProductSearchResult({
    required this.id,
    required this.brandName,
    required this.sellingPrice,
    required this.unitType,
    required this.batchId,
    required this.availableStock,
  });
}

class ProductRepository {
  final PharmacyDatabase _db;

  ProductRepository(this._db);

  List<ProductSearchResult> searchProducts(String query) {
    if (query.isEmpty) return [];

    const sql = '''
      SELECT p.id, p.brand_name, p.selling_price, p.unit_type, 
             b.id as batch_id, b.quantity as available_stock
      FROM products p
      INNER JOIN batches b ON p.id = b.product_id
      WHERE (p.brand_name LIKE ? OR p.generic_name LIKE ?)
        AND b.quantity > 0
        AND b.expiry_date = (
            -- FIFO Logic: Find the earliest expiry date for this specific product
            SELECT MIN(b2.expiry_date) 
            FROM batches b2 
            WHERE b2.product_id = p.id AND b2.quantity > 0
        )
      ORDER BY p.brand_name ASC
    ''';

    final results = _db.database.select(sql, ['%$query%', '%$query%']);

    final List<ProductSearchResult> output = [];
    for (final Row row in results) {
      output.add(ProductSearchResult(
        id: row.columnAt(0) as int,
        brandName: row.columnAt(1) as String,
        sellingPrice: (row.columnAt(2) as num).toDouble(),
        unitType: row.columnAt(3) as String,
        batchId: row.columnAt(4) as int,
        availableStock: row.columnAt(5) as int,
      ));
    }
    
    return output;
  }
}
