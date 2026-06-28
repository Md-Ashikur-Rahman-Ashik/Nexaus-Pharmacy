import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/data/repositories/dashboard_repository.dart';
import 'package:pharmacy_app/database/database.dart';

final dashboardProvider = FutureProvider<DashboardData>((ref) async {
  final repo = DashboardRepository(PharmacyDatabase.instance);
  return repo.getDashboardData();
});
