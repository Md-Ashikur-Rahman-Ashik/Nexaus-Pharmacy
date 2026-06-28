import 'package:pharmacy_app/database/database.dart';
import 'package:sqlite3/sqlite3.dart' show Row;

class PurchaseRepository {
  final PharmacyDatabase _db;

  PurchaseRepository(this._db);

  void processInboundStock({
    required String companyName,
    required String brandName,
    required String genericName,
    required String unitType,
    required double sellingPrice,
    required String batchNumber,
    required int expiryDateMs,
    required double costPrice,
    required int quantity,
  }) {
    final db = _db.database;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final totalBill = costPrice * quantity;

    try {
      db.execute('BEGIN TRANSACTION');

      // 1. Get or Create Company
      var companyResult = db.select('SELECT id FROM companies WHERE name = ?', [companyName]);
      int companyId;
      if (companyResult.isEmpty) {
        db.execute('INSERT INTO companies (name, total_due) VALUES (?, ?)', [companyName, 0.0]);
        companyId = db.lastInsertRowId;
      } else {
        companyId = companyResult.first.columnAt(0) as int;
      }

      // 2. Get or Create Product
      var productResult = db.select('SELECT id FROM products WHERE brand_name = ?', [brandName]);
      int productId;
      if (productResult.isEmpty) {
        db.execute(
          'INSERT INTO products (brand_name, generic_name, unit_type, selling_price) VALUES (?, ?, ?, ?)',
          [brandName, genericName, unitType, sellingPrice],
        );
        productId = db.lastInsertRowId;
      } else {
        productId = productResult.first.columnAt(0) as int;
      }

      // 3. Create Purchase Transaction Header (We owe the company money)
      db.execute(
        'INSERT INTO purchase_transactions (company_id, date, total_bill, paid_amount, due_amount) VALUES (?, ?, ?, ?, ?)',
        [companyId, currentTime, totalBill, 0.0, totalBill], // Assuming 100% credit from company
      );
      final transactionId = db.lastInsertRowId;

      // 4. Create the Batch on the Shelf
      db.execute(
        'INSERT INTO batches (product_id, batch_number, expiry_date, cost_price, quantity) VALUES (?, ?, ?, ?, ?)',
        [productId, batchNumber, expiryDateMs, costPrice, quantity],
      );
      final batchId = db.lastInsertRowId;

      // 5. Link Transaction to Batch
      db.execute(
        'INSERT INTO purchase_items (transaction_id, batch_id, quantity) VALUES (?, ?, ?)',
        [transactionId, batchId, quantity],
      );

      // 6. Update Company Total Due
      db.execute(
        'UPDATE companies SET total_due = total_due + ? WHERE id = ?',
        [totalBill, companyId],
      );

      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}
