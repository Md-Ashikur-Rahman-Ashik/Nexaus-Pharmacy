import 'package:pharmacy_app/database/database.dart';
import 'package:sqlite3/sqlite3.dart' show Row;

class CompanyDue {
  final int id;
  final String name;
  final double totalDue;

  CompanyDue({
    required this.id,
    required this.name,
    required this.totalDue,
  });
}

class CompanyDueRepository {
  final PharmacyDatabase _db;

  CompanyDueRepository(this._db);

  List<CompanyDue> getActiveDebtors() {
    const sql = '''
      SELECT id, name, total_due 
      FROM companies 
      WHERE total_due > 0 
      ORDER BY total_due DESC
    ''';

    final results = _db.database.select(sql);
    final List<CompanyDue> output = [];

    for (final Row row in results) {
      output.add(CompanyDue(
        id: row.columnAt(0) as int,
        name: row.columnAt(1) as String,
        totalDue: (row.columnAt(2) as num).toDouble(),
      ));
    }

    return output;
  }

  void recordPayment(int companyId, double paymentAmount) {
    final db = _db.database;
    try {
      db.execute('BEGIN TRANSACTION');
      db.execute(
        'UPDATE companies SET total_due = total_due - ? WHERE id = ?',
        [paymentAmount, companyId],
      );
      db.execute('COMMIT');
    } catch (e) {
      db.execute('ROLLBACK');
      rethrow;
    }
  }
}
