import 'package:sqlite3/sqlite3.dart' as sqlite;

class PharmacyDatabase {
  static PharmacyDatabase? _instance;
  late sqlite.Database _db;

  // Private constructor for Singleton pattern
  PharmacyDatabase._internal();

  // Factory to return the same instance every time
  static PharmacyDatabase get instance {
    _instance ??= PharmacyDatabase._internal();
    return _instance!;
  }

  Future<void> init() async {
    // In a real app, we'd use path_provider here to get the documents directory.
    // For web/codespace testing, we use an in-memory database to bypass file permissions!
    // We will switch to file-based when we test on a physical phone.
    _db = sqlite.sqlite3.openInMemory(); 
    
    _createTables();
  }

  void _createTables() {
    // Batch execution for instant setup
    _db.execute('''
      CREATE TABLE IF NOT EXISTS products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        brand_name TEXT NOT NULL,
        generic_name TEXT NOT NULL,
        unit_type TEXT NOT NULL,
        selling_price REAL NOT NULL
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS batches (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_id INTEGER,
        batch_number TEXT NOT NULL,
        expiry_date INTEGER NOT NULL,
        cost_price REAL NOT NULL,
        quantity INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (product_id) REFERENCES products (id)
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS companies (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        total_due REAL NOT NULL DEFAULT 0
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phone TEXT,
        address TEXT,
        total_due REAL NOT NULL DEFAULT 0
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        company_id INTEGER NOT NULL,
        date INTEGER NOT NULL,
        total_bill REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        due_amount REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (company_id) REFERENCES companies (id)
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS purchase_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        batch_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES purchase_transactions (id),
        FOREIGN KEY (batch_id) REFERENCES batches (id)
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS sales_transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        date INTEGER NOT NULL,
        total_bill REAL NOT NULL,
        paid_amount REAL NOT NULL DEFAULT 0,
        due_amount REAL NOT NULL DEFAULT 0,
        FOREIGN KEY (customer_id) REFERENCES customers (id)
      );
    ''');

    _db.execute('''
      CREATE TABLE IF NOT EXISTS sale_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        batch_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        selling_price REAL NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES sales_transactions (id),
        FOREIGN KEY (batch_id) REFERENCES batches (id)
      );
    ''');
  }

  // Expose the raw database for our repositories to use
  sqlite.Database get database => _db;
}