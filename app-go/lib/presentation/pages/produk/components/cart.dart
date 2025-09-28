import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/cart_item.dart';
import 'package:getsayor/presentation/pages/produk/components/pesanan_selection_cart.dart';
import 'package:getsayor/data/services/cart_service.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  CartScreenState createState() => CartScreenState();
}

class CartScreenState extends State<CartScreen> {
  late Future<List<CartItem>> _cartItemsFuture;
  List<CartItem> _currentCartItems = [];
  List<int> selectedCartItemIds =
      []; // Menggunakan ID item keranjang, bukan produk
  bool selectAll = false;
  bool isEditMode = false;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  void _loadCartItems() {
    _cartItemsFuture = CartService().getCartItems(context).then((cartItems) {
      _currentCartItems = cartItems;
      return cartItems;
    });
  }

  Future<void> _refreshCartItems() async {
    setState(() {
      _loadCartItems();
      selectedCartItemIds.clear();
      selectAll = false;
    });
  }

  bool _areAllProductsSelected() {
    if (_currentCartItems.isEmpty) return false;
    return selectedCartItemIds.length == _currentCartItems.length;
  }

  void _toggleCartItemSelection(int cartItemId) {
    setState(() {
      if (selectedCartItemIds.contains(cartItemId)) {
        selectedCartItemIds.remove(cartItemId);
      } else {
        selectedCartItemIds.add(cartItemId);
      }
      selectAll = _areAllProductsSelected();
    });
  }

  void _toggleSelectAll() {
    setState(() {
      if (selectAll) {
        selectedCartItemIds.clear();
      } else {
        selectedCartItemIds = _currentCartItems.map((item) => item.id).toList();
      }
      selectAll = !selectAll;
    });
  }

  int getTotalPoin() {
    int totalPoin = 0;
    for (var item in _currentCartItems) {
      if (selectedCartItemIds.contains(item.id)) {
        totalPoin += item.productItem.hargaPoin * item.quantity;
      }
    }
    return totalPoin;
  }

  int getTotalHarga() {
    int totalHarga = 0;
    for (var item in _currentCartItems) {
      if (selectedCartItemIds.contains(item.id)) {
        totalHarga += item.productItem.hargaRp * item.quantity;
      }
    }
    return totalHarga;
  }

  int getQuantity(CartItem cartItem) {
    return cartItem.quantity > 0 ? cartItem.quantity : 1;
  }

  void _updateProductQuantity(CartItem cartItem, bool isIncrement) async {
    int newQuantity = cartItem.quantity;
    if (isIncrement) {
      newQuantity += 1;
    } else {
      if (newQuantity > 1) {
        newQuantity -= 1;
      }
    }

    setState(() {
      cartItem.quantity = newQuantity;
    });

    try {
      await CartService().updateCartItem(
        context,
        cartItem.userId,
        cartItem.productItemId,
        newQuantity,
      );
    } catch (e) {
      setState(() {
        cartItem.quantity = cartItem.quantity;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
      debugPrint('Error updating cart item: $e');
    }
  }

  void _deleteCartItems(List<String> cartIds) async {
    setState(() {
      _isDeleting = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId == null) {
        throw Exception('User ID not available');
      }

      await Future.wait(
        cartIds.map((cartId) async {
          await CartService().deleteCartItem(context, userId, cartId);
        }),
      );

      await _refreshCartItems();

      if (mounted) {
        Fluttertoast.showToast(
          msg: "Item berhasil dihapus dari keranjang.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: const Color(0xFF74B11A),
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } on DioException catch (e) {
      String errorMessage;

      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.sendTimeout:
          errorMessage = "Waktu koneksi habis, silakan coba lagi";
          break;
        case DioExceptionType.connectionError:
          errorMessage = "Tidak ada koneksi internet, periksa jaringan Anda";
          break;
        default:
          if (e.response?.statusCode == 401) {
            errorMessage = "Sesi telah berakhir, silakan login kembali";
          } else if (e.response?.statusCode == 404) {
            errorMessage = "Item keranjang tidak ditemukan";
          } else if (e.response?.statusCode == 500) {
            errorMessage = "Server sedang sibuk, silakan coba lagi nanti";
          } else {
            errorMessage = "Gagal menghapus item dari keranjang";
          }
      }

      if (mounted) {
        Fluttertoast.showToast(
          msg: errorMessage,
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } catch (e) {
      if (mounted) {
        Fluttertoast.showToast(
          msg: "Terjadi kesalahan tak terduga",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
      debugPrint('Error deleting cart items: $e');
    } finally {
      setState(() {
        _isDeleting = false; // Selesai proses penghapusan
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Keranjang',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode;
                if (!isEditMode) {
                  selectedCartItemIds.clear();
                }
              });
            },
            child: Text(
              isEditMode ? 'Done' : 'Edit',
              style: const TextStyle(
                fontFamily: 'Poppins',
                color: Color(0xFF589400),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _refreshCartItems,
        color: const Color(0xFF74B11A),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: FutureBuilder<List<CartItem>>(
                  future: _cartItemsFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text(
                          'Terjadi kesalahan: ${snapshot.error}',
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      );
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.remove_shopping_cart_outlined,
                              size: 48.0,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 10),
                            Text(
                              'Tidak ada data',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                color: Colors.grey,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).size.height * 0.21),
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        final cartItem = snapshot.data![index];
                        final product = cartItem.productItem;

                        return Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  // Menggunakan cartItem.id sebagai identifier
                                  _toggleCartItemSelection(cartItem.id);
                                },
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: selectedCartItemIds
                                            .contains(cartItem.id)
                                        ? const Color(0xFF589400)
                                        : Colors.transparent,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1,
                                    ),
                                  ),
                                  child:
                                      selectedCartItemIds.contains(cartItem.id)
                                          ? const Icon(
                                              Icons.check,
                                              size: 15,
                                              color: Colors.white,
                                            )
                                          : null,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 70,
                                height: 70,
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: const Color(0XFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: '$baseUrlStatic/${product.image}',
                                    width: double.infinity,
                                    height: double.infinity,
                                    fit: BoxFit.cover,
                                    memCacheHeight: 150,
                                    memCacheWidth: 150,
                                    maxHeightDiskCache: 150,
                                    maxWidthDiskCache: 150,
                                    fadeInDuration: Duration.zero,
                                    placeholder: (context, url) =>
                                        FutureBuilder<FileInfo?>(
                                      future: AppCacheManager()
                                          .getFileFromCache(url),
                                      builder: (context, snapshot) {
                                        if (snapshot.hasData &&
                                            snapshot.data!.file.existsSync()) {
                                          return Image.file(
                                            snapshot.data!.file,
                                            fit: BoxFit.cover,
                                          );
                                        }
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1.5,
                                          ),
                                        );
                                      },
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/placeholder.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${product.nameProduk} (${product.jumlah} ${product.satuan == "Kilogram" ? "kg" : product.satuan == "Gram" ? "gr" : product.satuan == "Biji" ? "biji" : product.satuan})',
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Image.asset(
                                          'assets/images/poin.png',
                                          width: 15,
                                          height: 15,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          '${numberFormat.format(product.hargaPoin)} / ${formatRupiah(product.hargaRp)}',
                                          style: const TextStyle(
                                            fontFamily: 'Poppins',
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Jumlah",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF1D1D1F),
                                          ),
                                        ),
                                        Container(
                                          width: 115,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFF2F2F7),
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment
                                                .spaceBetween, // Distribusi ruang secara merata
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  // HapticFeedback.lightImpact();
                                                  _updateProductQuantity(
                                                      cartItem, false);
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.05),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 16,
                                                    color: Color(0xFF589400),
                                                  ),
                                                ),
                                              ),
                                              // Gunakan SizedBox dengan lebar tetap untuk teks
                                              SizedBox(
                                                width:
                                                    40, // Lebar tetap untuk area angka
                                                child: Center(
                                                  child: Text(
                                                    '${cartItem.quantity}',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF1D1D1F),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () async {
                                                  // HapticFeedback.lightImpact();
                                                  _updateProductQuantity(
                                                      cartItem, true);
                                                },
                                                child: Container(
                                                  margin:
                                                      const EdgeInsets.all(4),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.black
                                                            .withOpacity(0.05),
                                                        blurRadius: 4,
                                                        offset:
                                                            const Offset(0, 1),
                                                      ),
                                                    ],
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 16,
                                                    color: Color(0xFF589400),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 10)
            ],
          ),
        ),
      ),
      bottomSheet: FutureBuilder<List<CartItem>>(
        future: _cartItemsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox.shrink();
          } else if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return const SizedBox.shrink();
          }

          return Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: _toggleSelectAll,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: selectAll
                              ? const Color(0xFF589400)
                              : Colors.transparent,
                          border: Border.all(
                            color: Colors.grey,
                            width: 1,
                          ),
                        ),
                        child: selectAll
                            ? const Icon(
                                Icons.check,
                                size: 15,
                                color: Colors.white,
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Select All',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Divider(
                  color: Color(0xFFE9ECEF),
                  thickness: 1,
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Poin:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/poin.png',
                          width: 16,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          numberFormat.format(getTotalPoin()),
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Harga:',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Colors.grey,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      formatRupiah(getTotalHarga()),
                      style: const TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: (_isDeleting || selectedCartItemIds.isEmpty)
                      ? null
                      : () {
                          if (isEditMode) {
                            final List<String> cartIdsToDelete = snapshot.data!
                                .where((item) =>
                                    selectedCartItemIds.contains(item.id))
                                .map((item) => item.id.toString())
                                .toList();

                            _deleteCartItems(cartIdsToDelete);
                          } else {
                            final List<CartItem> selectedCartItems = snapshot
                                .data!
                                .where((item) =>
                                    selectedCartItemIds.contains(item.id))
                                .toList();

                            final int totalHarga = getTotalHarga();
                            final int totalPoin = getTotalPoin();

                            final List<int> quantities = selectedCartItems
                                .map((item) => getQuantity(item))
                                .toList();

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentSelectionCart(
                                  selectedProducts: selectedCartItems,
                                  quantities: quantities,
                                  totalHarga: totalHarga,
                                  totalPoin: totalPoin,
                                ),
                              ),
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: const Color(0xFF74B11A),
                  ),
                  child: _isDeleting
                      ? const Text(
                          "Menghapus...",
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        )
                      : Text(
                          isEditMode
                              ? 'Hapus (${selectedCartItemIds.length})'
                              : 'Checkout (${selectedCartItemIds.length})',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
