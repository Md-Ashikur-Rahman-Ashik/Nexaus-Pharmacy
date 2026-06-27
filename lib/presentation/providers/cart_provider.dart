import 'package:flutter_riverpod/flutter_riverpod.dart';

class CartItem {
  final int productId;
  final int batchId;
  final String brandName;
  final String unitType;
  final double sellingPrice;
  int quantity;

  CartItem({
    required this.productId,
    required this.batchId,
    required this.brandName,
    required this.unitType,
    required this.sellingPrice,
    required this.quantity,
  });

  double get subtotal => sellingPrice * quantity;
}

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  void addItem(CartItem newItem) {
    // FIX: Check by productId instead of batchId
    final existingIndex = state.indexWhere((item) => item.productId == newItem.productId);
    
    if (existingIndex >= 0) {
      state[existingIndex].quantity += newItem.quantity;
      state = [...state];
    } else {
      state = [...state, newItem];
    }
  }

  void removeItem(int productId) { // FIX: changed argument
    state = state.where((item) => item.productId != productId).toList(); // FIX: changed logic
  }

  void updateQuantity(int productId, int newQuantity) { // FIX: changed argument
    if (newQuantity <= 0) {
      removeItem(productId);
      return;
    }
    state = state.map((item) {
      if (item.productId == productId) { // FIX: changed logic
        return CartItem(
          productId: item.productId,
          batchId: item.batchId,
          brandName: item.brandName,
          unitType: item.unitType,
          sellingPrice: item.sellingPrice,
          quantity: newQuantity,
        );
      }
      return item;
    }).toList();
  }

  double get grandTotal => state.fold(0.0, (sum, item) => sum + item.subtotal);

  void clearCart() {
    state = [];
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
