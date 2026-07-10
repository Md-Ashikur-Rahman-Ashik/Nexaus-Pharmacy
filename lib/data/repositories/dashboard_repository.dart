import 'package:pharmacy_app/database/database.dart';
import 'package:intl/intl.dart';

class DashboardData {
  final double todaySales;
  final double todayProfit;
  final double totalOutstandingDue;
  final List<DebtorSummary> topDebtors;
  final List<ExpiringBatch> expiringSoon;

  DashboardData({
    required this.todaySales,
    required this.todayProfit,
    required this.totalOutstandingDue,
    required this.topDebtors,
    required this.expiringSoon,
  });
}

class DebtorSummary {
  final String name;
  final double due;
  DebtorSummary({required this.name, required this.due});
}

class ExpiringBatch {
  final String brandName;
  final String batchNumber;
  final String expiryDateFormatted;
  ExpiringBatch({
    required this.brandName,
    required this.batchNumber,
    required this.expiryDateFormatted,
  });
}

class DashboardRepository {
  final PharmacyDatabase _db;

  DashboardRepository(this._db);

  Future<DashboardData> getDashboardData() async {
    final db = _db.database;

    final now = DateTime.now();
    final startOfDay = DateTime(
      now.year,
      now.month,
      now.day,
    ).millisecondsSinceEpoch;

    final expiryThreshold = now
        .add(const Duration(days: 30))
        .millisecondsSinceEpoch;


    final salesResult = db.select(
      'SELECT COALESCE(SUM(total_bill), 0) FROM sales_transactions WHERE date >= ?',
      [startOfDay],
    );
    final todaySales = (salesResult.first.columnAt(0) as num).toDouble();


    final cogsResult = db.select('''
      SELECT COALESCE(SUM(si.quantity * b.cost_price), 0)
      FROM sale_items si
      JOIN sales_transactions st ON si.transaction_id = st.id
      JOIN batches b ON si.batch_id = b.id
      WHERE st.date >= ?
    ''', [startOfDay]);
    final todayCogs = (cogsResult.first.columnAt(0) as num).toDouble();


    final todayProfit = todaySales - todayCogs;


    final dueResult = db.select(
      'SELECT COALESCE(SUM(total_due), 0) FROM customers WHERE total_due > 0',
    );
    final totalOutstandingDue = (dueResult.first.columnAt(0) as num).toDouble();


    final debtorsResult = db.select(
      'SELECT name, total_due FROM customers WHERE total_due > 0 ORDER BY total_due DESC LIMIT 3',
    );
    final topDebtors = debtorsResult
        .map(
          (row) => DebtorSummary(
            name: row.columnAt(0) as String,
            due: (row.columnAt(1) as num).toDouble(),
          ),
        )
        .toList();


    final expiringResult = db.select(
      '''
      SELECT p.brand_name, b.batch_number, b.expiry_date 
      FROM batches b
      JOIN products p ON b.product_id = p.id
      WHERE b.expiry_date <= ? AND b.quantity > 0
      ORDER BY b.expiry_date ASC
    ''',
      [expiryThreshold],
    );

    final formatter = DateFormat('dd-MM-yyyy');
    final expiringSoon = expiringResult.map((row) {
      final expiryMs = row.columnAt(2) as int;
      final date = DateTime.fromMillisecondsSinceEpoch(expiryMs);
      return ExpiringBatch(
        brandName: row.columnAt(0) as String,
        batchNumber: row.columnAt(1) as String,
        expiryDateFormatted: formatter.format(date),
      );
    }).toList();

    return DashboardData(
      todaySales: todaySales,
      todayProfit: todayProfit,
      totalOutstandingDue: totalOutstandingDue,
      topDebtors: topDebtors,
      expiringSoon: expiringSoon,
    );
  }
}