import 'package:pharmacy_app/database/database.dart';
import 'package:pharmacy_app/presentation/providers/cart_provider.dart';

class SalesRepository {
  final PharmacyDatabase _db;

  SalesRepository(this._db);

  void processCashSale(List<CartItem> cart) {
    final db = _db.database;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final totalBill = cart.fold(0.0, (sum, item) => sum + item.subtotal);

    try {
      // 1. OPEN THE TRANSACTION BOUNDARY
      db.execute('BEGIN TRANSACTION');

      // 2. Create the Sales Header (Cash customer = null)
      db.execute(
        'INSERT INTO sales_transactions (customer_id, date, total_bill, paid_amount, due_amount) VALUES (?, ?, ?, ?, ?)',
        [null, currentTime, totalBill, totalBill, 0.0], // paid = total, due = 0
      );

      // Capture the ID of the sale we just created
      final transactionId = db.lastInsertRowId;

      // 3. Loop through cart to save items and deduct stock
      for (final item in cart) {
        // Save the line item
        db.execute(
          'INSERT INTO sale_items (transaction_id, batch_id, quantity, selling_price) VALUES (?, ?, ?, ?)',
          [transactionId, item.batchId, item.quantity, item.sellingPrice],
        );

        // Deduct from the specific FIFO batch
        db.execute(
          'UPDATE batches SET quantity = quantity - ? WHERE id = ?',
          [item.quantity, item.batchId],
        );
      }

      // 4. SUCCESS: Commit to the database forever
      db.execute('COMMIT');
      
    } catch (e) {
      // 5. FAILURE: Something went wrong (e.g., out of stock). Undo everything!
      db.execute('ROLLBACK');
      rethrow; // Throw the error back to the UI to show a warning
    }
  }
}
