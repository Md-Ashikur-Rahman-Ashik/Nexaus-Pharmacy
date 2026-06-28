import 'package:pharmacy_app/database/database.dart';
import 'package:pharmacy_app/presentation/providers/cart_provider.dart';

class SalesRepository {
  final PharmacyDatabase _db;

  SalesRepository(this._db);

  void processSale(List<CartItem> cart, double paidAmount, String? customerName) {
    final db = _db.database;
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final totalBill = cart.fold(0.0, (sum, item) => sum + item.subtotal);
    final dueAmount = totalBill - paidAmount;

    try {
      db.execute('BEGIN TRANSACTION');

      int? customerId;
      
      // Handle Customer Logic (Cash vs Credit)
      if (customerName != null && customerName.isNotEmpty && dueAmount > 0) {
        // Try to find existing customer by name
        final result = db.select('SELECT id FROM customers WHERE name = ?', [customerName]);
        
        if (result.isNotEmpty) {
          customerId = result.first.columnAt(0) as int;
        } else {
          // Auto-create new customer on the fly (Magic Ink UX)
          db.execute('INSERT INTO customers (name, total_due) VALUES (?, ?)', [customerName, 0.0]);
          customerId = db.lastInsertRowId;
        }
      }

      // Create the Sales Header
      db.execute(
        'INSERT INTO sales_transactions (customer_id, date, total_bill, paid_amount, due_amount) VALUES (?, ?, ?, ?, ?)',
        [customerId, currentTime, totalBill, paidAmount, dueAmount],
      );
      final transactionId = db.lastInsertRowId;

      // Loop through cart to save items and deduct stock
      for (final item in cart) {
        db.execute(
          'INSERT INTO sale_items (transaction_id, batch_id, quantity, selling_price) VALUES (?, ?, ?, ?)',
          [transactionId, item.batchId, item.quantity, item.sellingPrice],
        );
        db.execute(
          'UPDATE batches SET quantity = quantity - ? WHERE id = ?',
          [item.quantity, item.batchId],
        );
      }

      // If it was a credit sale, update the Customer's total_due
      if (customerId != null && dueAmount > 0) {
        db.execute(
          'UPDATE customers SET total_due = total_due + ? WHERE id = ?',
          [dueAmount, customerId],
        );
      }

      db.execute('COMMIT');
      
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}
