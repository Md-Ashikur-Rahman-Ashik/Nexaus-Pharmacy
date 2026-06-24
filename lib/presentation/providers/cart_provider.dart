import 'package:flutter_riverpod/flutter_riverpod.dart';

// A clean data model for an item in the cart
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

// The StateNotifier that manages the cart list
class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  // Add item or increment quantity if it already exists
  void addItem(CartItem newItem) {
    final existingIndex = state.indexWhere((item) => item.batchId == newItem.batchId);
    
    if (existingIndex >= 0) {
      // Item already in cart, just increase quantity
      state[existingIndex].quantity += newItem.quantity;
      // Force UI update by creating a new list instance
      state = [...state];
    } else {
      // New item, add to cart
      state = [...state, newItem];
    }
  }

  // Remove item completely
  void removeItem(int batchId) {
    state = state.where((item) => item.batchId != batchId).toList();
  }

  // Update quantity (e.g., plus/minus buttons)
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

  // Calculate grand total
  double get grandTotal => state.fold(0.0, (sum, item) => sum + item.subtotal);

  // Clear cart after sale
  void clearCart() {
    state = [];
  }
}

// Expose to UI
final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  return CartNotifier();
});
