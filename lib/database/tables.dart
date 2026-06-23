import 'package:drift/drift.dart';

// Part directive tells Dart to look for generated code in the next file.
part 'tables.g.dart';

// ==========================================
// 1. PRODUCTS (Master Catalog)
// ==========================================
class Products extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get brandName => text().withLength(min: 1, max: 100)();
  TextColumn get genericName => text().withLength(min: 1, max: 100)();
  TextColumn get unitType =>
      text().withLength(min: 1, max: 50)(); // Box, Strip, etc.
  RealColumn get sellingPrice => real()();
}

// ==========================================
// 2. BATCHES (Inventory Vault)
// ==========================================
class Batches extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get productId => integer().nullable().references(Products, #id)();
  // Nullable because we might add a batch before the product is perfectly cataloged

  TextColumn get batchNumber => text()();
  IntColumn get expiryDate => integer()(); // Unix timestamp in milliseconds
  RealColumn get costPrice => real()();
  IntColumn get quantity => integer().withDefault(const Constant(0))();
}

// ==========================================
// 3. COMPANIES (Suppliers)
// ==========================================
class Companies extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get phone => text().nullable()();
  RealColumn get totalDue => real().withDefault(const Constant(0))();
}

// ==========================================
// 4. CUSTOMERS (Buyers / বাকি খাতা)
// ==========================================
class Customers extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();
  RealColumn get totalDue => real().withDefault(const Constant(0))();
}

// ==========================================
// 5. PURCHASE TRANSACTIONS (Inbound)
// ==========================================
class PurchaseTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get companyId => integer().references(Companies, #id)();
  IntColumn get date => integer()(); // Unix timestamp
  RealColumn get totalBill => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  RealColumn get dueAmount => real().withDefault(const Constant(0))();
}

// ==========================================
// 6. PURCHASE ITEMS (Link Purchases to Batches)
// ==========================================
class PurchaseItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId =>
      integer().references(PurchaseTransactions, #id)();
  IntColumn get batchId => integer().references(Batches, #id)();
  IntColumn get quantity => integer()();
}

// ==========================================
// 7. SALES TRANSACTIONS (Outbound)
// ==========================================
class SalesTransactions extends Table {
  IntColumn get id => integer().autoIncrement()();
  // Nullable because walk-in cash customers don't need a profile
  IntColumn get customerId => integer().nullable().references(Customers, #id)();
  IntColumn get date => integer()(); // Unix timestamp
  RealColumn get totalBill => real()();
  RealColumn get paidAmount => real().withDefault(const Constant(0))();
  RealColumn get dueAmount => real().withDefault(const Constant(0))();
}

// ==========================================
// 8. SALE ITEMS (Link Sales to Batches)
// ==========================================
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get transactionId => integer().references(SalesTransactions, #id)();
  IntColumn get batchId => integer().references(Batches, #id)();
  IntColumn get quantity => integer()();
  // We lock the selling price here at the time of sale for accurate historical accounting
  RealColumn get sellingPrice => real()();
}
