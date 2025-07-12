import 'package:getsayor/data/services/cart_service.dart';
import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  int _cartItemCount = 0;

  int get cartItemCount => _cartItemCount;

  Future<void> loadCartItemCount(BuildContext context) async {
    try {
      final count = await CartService().getCartItemCount(context);
      _cartItemCount = count;
      notifyListeners();
    } catch (e) {
      debugPrint('Error loading cart item count: $e');
    }
  }

  void setCartItemCount(int count) {
    _cartItemCount = count;
    notifyListeners();
  }
}
