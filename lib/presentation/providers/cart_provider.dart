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
    // Reverted to batchId: One cart line = One physical batch being deducted
    final existingIndex = state.indexWhere((item) => item.batchId == newItem.batchId);
    
    if (existingIndex >= 0) {
      state[existingIndex].quantity += newItem.quantity;
      state = [...state];
    } else {
      state = [...state, newItem];
    }
  }

  void removeItem(int batchId) {
    state = state.where((item) => item.batchId != batchId).toList();
  }

  void updateQuantity(int batchId, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(batchId);
      return;
    }
    state = state.map((item) {
      if (item.batchId == batchId) {
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
