import 'package:pharmacy_app/database/database.dart';
import 'package:sqlite3/sqlite3.dart' show Row;

class CustomerDue {
  final int id;
  final String name;
  final String? phone;
  final double totalDue;

  CustomerDue({
    required this.id,
    required this.name,
    this.phone,
    required this.totalDue,
  });
}

class DueRepository {
  final PharmacyDatabase _db;

  DueRepository(this._db);

  // Get all customers who owe money, sorted by highest debt first
  List<CustomerDue> getActiveDebtors() {
    const sql = '''
      SELECT id, name, phone, total_due 
      FROM customers 
      WHERE total_due > 0 
      ORDER BY total_due DESC
    ''';

    final results = _db.database.select(sql);
    final List<CustomerDue> output = [];

    for (final Row row in results) {
      output.add(CustomerDue(
        id: row.columnAt(0) as int,
        name: row.columnAt(1) as String,
        phone: row.columnAt(2) as String?,
        totalDue: (row.columnAt(3) as num).toDouble(),
      ));
    }

    return output;
  }

  // Deduct debt when customer pays
  void recordPayment(int customerId, double paymentAmount) {
    final db = _db.database;
    try {
      db.execute('BEGIN TRANSACTION');
      
      // Deduct from customer's total due
      db.execute(
        'UPDATE customers SET total_due = total_due - ? WHERE id = ?',
        [paymentAmount, customerId],
      );

      // Optional but good practice: Record a simple ledger entry for the payment
      // For now, we just update the balance to keep it simple and fast.
      
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}
