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
  List<int> selectedProducts = [];
  bool selectAll = false;
  bool isEditMode = false;

  @override
  void initState() {
    super.initState();
    _loadCartItems();
  }

  // Fungsi untuk memuat data keranjang
  void _loadCartItems() {
    _cartItemsFuture = CartService().getCartItems(context).then((cartItems) {
      // Pastikan setiap cartItem memiliki quantity yang benar
      for (var item in cartItems) {
        item.quantity =
            item.quantity; // Tidak perlu diubah jika data sudah benar
      }
      return cartItems;
    });
  }

  // Fungsi untuk refresh data
  Future<void> _refreshCartItems() async {
    setState(() {
      _loadCartItems();
      selectedProducts.clear(); // Hapus pilihan produk saat refresh
      selectAll = false;
    });
  }

  // Fungsi untuk memeriksa apakah semua produk terpilih
  bool _areAllProductsSelected(List<CartItem> cartItems) {
    return selectedProducts.length == cartItems.length &&
        selectedProducts
            .every((id) => cartItems.any((item) => item.product.id == id));
  }

  // Fungsi untuk menambah/menghapus produk ke daftar pilihan
  void _toggleProductSelection(int productId, List<CartItem> cartItems) {
    setState(() {
      if (selectedProducts.contains(productId)) {
        selectedProducts.remove(productId); // Hapus jika sudah dipilih
      } else {
        selectedProducts.add(productId); // Tambahkan jika belum dipilih
      }

      // Periksa apakah semua produk terpilih setelah mengubah seleksi
      selectAll = _areAllProductsSelected(cartItems);
    });
  }

  // Fungsi untuk toggle select all produk
  void _toggleSelectAll(List<CartItem> cartItems) {
    setState(() {
      if (selectAll) {
        selectedProducts.clear();
      } else {
        selectedProducts = cartItems.map((item) => item.product.id).toList();
      }
      selectAll = !selectAll;
    });
  }

  // Fungsi untuk menghitung total poin dari produk yang dipilih
  int getTotalPoin(List<CartItem> cartItems) {
    int totalPoin = 0;
    for (var item in cartItems) {
      if (selectedProducts.contains(item.product.id)) {
        totalPoin += item.product.hargaPoin * item.quantity;
      }
    }
    return totalPoin;
  }

  // Fungsi untuk menghitung total harga dari produk yang dipilih
  int getTotalHarga(List<CartItem> cartItems) {
    int totalHarga = 0;
    for (var item in cartItems) {
      if (selectedProducts.contains(item.product.id)) {
        totalHarga += item.product.hargaRp * item.quantity;
      }
    }
    return totalHarga;
  }

  int getQuantity(CartItem cartItem) {
    return cartItem.quantity > 0 ? cartItem.quantity : 1; // Minimal 1
  }

  // Fungsi update quantity (jumlah)
  void _updateProductQuantity(CartItem cartItem, bool isIncrement) async {
    int newQuantity = cartItem.quantity; // Gunakan nilai quantity langsung
    if (isIncrement) {
      newQuantity += 1;
    } else {
      if (newQuantity > 1) {
        newQuantity -= 1;
      }
    }

    setState(() {
      cartItem.quantity = newQuantity; // Update quantity di state
    });

    try {
      await CartService().updateCartItem(
        context,
        cartItem.userId.toString(),
        cartItem.productId.toString(),
        newQuantity, // Kirim nilai quantity langsung ke backend
      );
    } catch (e) {
      setState(() {
        cartItem.quantity = cartItem.quantity; // Kembalikan ke nilai sebelumnya
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
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.userId;

      if (userId == null) {
        throw Exception('User ID not available');
      }

      // Run all delete operations concurrently
      await Future.wait(
        cartIds.map((cartId) async {
          await CartService()
              .deleteCartItem(context, userId.toString(), cartId);
        }),
      );

      // Refresh cart after all items are deleted
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
    }
  }

  @override
  Widget build(BuildContext context) {
    // final userProvider = Provider.of<UserProvider>(context);
    // final userId = userProvider.userId;

    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
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
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEditMode = !isEditMode; // Toggle between Edit and Done mode
                if (!isEditMode) {
                  selectedProducts
                      .clear(); // Clear selection when exiting edit mode
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
              // Daftar produk keranjang dengan RefreshIndicator
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
                    } else {
                      List<CartItem> cartItems = snapshot.data!;

                      // Jika keranjang kosong, tampilkan teks "Tidak ada data"
                      if (cartItems.isEmpty) {
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

                      // Render daftar item keranjang jika ada data
                      return ListView.builder(
                        padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height * 0.21),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          if (snapshot.data == [] || snapshot.data!.isEmpty) {
                            // Tampilan saat data kosong
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment
                                    .center, // Opsional, untuk memastikan horisontal juga center
                                children: [
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

                          final cartItem = cartItems[index];
                          final product = cartItem.product;

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
                                // Checkbox
                                GestureDetector(
                                  onTap: () {
                                    _toggleProductSelection(
                                        product.id, cartItems);
                                  },
                                  child: Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                          selectedProducts.contains(product.id)
                                              ? const Color(0xFF589400)
                                              : Colors.transparent,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1,
                                      ),
                                    ),
                                    child: selectedProducts.contains(product.id)
                                        ? const Icon(
                                            Icons.check,
                                            size: 15,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Gambar produk
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
                                      imageUrl:
                                          '$baseUrlStatic/${product.image}',
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
                                              snapshot.data!.file
                                                  .existsSync()) {
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
                                // Informasi produk
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                          const Text("Jumlah",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                              )),
                                          // Tombol Minus
                                          Row(
                                            children: [
                                              GestureDetector(
                                                onTap: () async {
                                                  _updateProductQuantity(
                                                      cartItem, false);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF589400),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  child: const Icon(
                                                    Icons.remove,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              // Berat Produk
                                              Text(
                                                '${cartItem.quantity}', // Tampilkan nilai quantity langsung
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),

                                              const SizedBox(width: 10),
                                              // Tombol Plus
                                              GestureDetector(
                                                onTap: () async {
                                                  _updateProductQuantity(
                                                      cartItem, true);
                                                },
                                                child: Container(
                                                  decoration: BoxDecoration(
                                                    color:
                                                        const Color(0xFF589400),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            50),
                                                  ),
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  child: const Icon(
                                                    Icons.add,
                                                    size: 12,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                              ),
                                            ],
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
                    }
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
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // Tidak menampilkan bottom sheet jika data kosong
            return const SizedBox.shrink();
          } else {
            List<CartItem> cartItems = snapshot.data!;

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
                        onTap: () {
                          _toggleSelectAll(cartItems);
                        },
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: selectAll
                                ? const Color(0xFF589400)
                                : Colors
                                    .transparent, // Warna hijau jika selectAll aktif
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
                            numberFormat.format(getTotalPoin(
                                cartItems)), // Total harga dalam Poin
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
                        formatRupiah(getTotalHarga(cartItems)),
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
                    onPressed: selectedProducts.isEmpty
                        ? null
                        : () {
                            if (isEditMode) {
                              // Dapatkan daftar ID item yang akan dihapus
                              final List<String> cartIdsToDelete = cartItems
                                  .where((item) => selectedProducts
                                      .contains(item.product.id))
                                  .map((item) => item.id.toString())
                                  .toList();

                              // Hapus semua item yang dipilih
                              _deleteCartItems(cartIdsToDelete);
                            } else {
                              // Navigasi ke halaman pembayaran
                              final List<CartItem> selectedCartItems = cartItems
                                  .where((item) => selectedProducts
                                      .contains(item.product.id))
                                  .toList();

                              final int totalHarga = getTotalHarga(cartItems);
                              final int totalPoin = getTotalPoin(cartItems);

                              // Buat list quantity untuk setiap item yang dipilih
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
                    child: Text(
                      isEditMode
                          ? 'Hapus (${selectedProducts.length})'
                          : 'Checkout (${selectedProducts.length})',
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
          }
        },
      ),
    );
  }
}
