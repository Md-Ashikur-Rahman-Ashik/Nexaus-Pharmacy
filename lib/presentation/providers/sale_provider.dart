import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pharmacy_app/data/repositories/product_repository.dart';
import 'package:pharmacy_app/database/database.dart';


final productRepositoryProvider = Provider<ProductRepository>((ref) {
  return ProductRepository(PharmacyDatabase.instance);
});


class SearchNotifier extends StateNotifier<List<Map<String, dynamic>>> {
  final ProductRepository _repository;

  SearchNotifier(this._repository) : super([]);

  void updateQuery(String query) {
    state = _repository.searchProducts(query);
  }

  void clearSearch() {
    state = [];
  }
}


final searchProvider = StateNotifierProvider<SearchNotifier, List<Map<String, dynamic>>>((ref) {
  final repo = ref.watch(productRepositoryProvider);
  return SearchNotifier(repo);
});