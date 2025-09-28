import 'package:flutter/material.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:getsayor/data/services/favorite_service.dart';

class FavoritesProvider with ChangeNotifier {
  final FavoriteService _service = FavoriteService();
  final Map<int, Produk> _favorites = {};
  bool isLoading = true;
  String? errorMessage;

  Map<int, Produk> get favorites => _favorites;
  bool isFavorite(int productId) => _favorites.containsKey(productId);

  Future<void> loadFavorites(BuildContext context) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      final favorites = await _service.getFavorites(context);

      if (favorites.isNotEmpty) {
        final newFavorites = <int, Produk>{};
        for (var product in favorites) {
          // Pastikan produk memiliki minimal satu ProductItem
          if (product.productItems.isEmpty) {
            product.productItems.add(ProductItem(
              id: 0,
              productId: product.id,
              stok: 0,
              hargaPoin: 0,
              hargaRp: 0,
              jumlah: 0,
              satuan: 'N/A',
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            ));
          }
          newFavorites[product.id] = product;
        }

        // Pertahankan data sementara untuk produk yang sedang di-load
        for (var key in _favorites.keys) {
          if (!newFavorites.containsKey(key) &&
              _favorites[key]?.nama == "Loading...") {
            newFavorites[key] = _favorites[key]!;
          }
        }

        _favorites.clear();
        _favorites.addAll(newFavorites);
      }
    } catch (e) {
      errorMessage = e.toString();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> toggleFavorite(BuildContext context, int productId) async {
    try {
      final newStatus = await _service.toggleFavorite(context, productId);

      if (newStatus) {
        // Tambahkan placeholder sementara dengan ProductItem default
        _favorites[productId] = Produk(
          id: productId,
          nama: "Loading...",
          deskripsi: "",
          kategori: "",
          image: null,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          productItems: [
            ProductItem(
              id: 0,
              productId: productId,
              stok: 0,
              hargaPoin: 0,
              hargaRp: 0,
              jumlah: 0,
              satuan: "N/A",
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            )
          ],
        );
      } else {
        _favorites.remove(productId);
      }

      notifyListeners();

      // Muat ulang data dari server
      if (context.mounted) {
        await loadFavorites(context);
      }

      return newStatus;
    } catch (e) {
      debugPrint("Error toggling favorite: $e");
      rethrow;
    }
  }
}
