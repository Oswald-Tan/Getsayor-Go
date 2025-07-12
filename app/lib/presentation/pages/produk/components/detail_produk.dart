import 'package:flutter/material.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/presentation/pages/produk/components/cart.dart';
import 'package:getsayor/presentation/providers/cart_provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/presentation/pages/produk/components/buy_now_modal.dart';
import 'package:getsayor/data/services/cart_service.dart';
import 'package:getsayor/data/services/favorite_service.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart'; // Add this import for Dio error handling

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class DetailProduk extends StatefulWidget {
  final String? id;
  final String nama;
  final int hargaPoin;
  final String imagePath;
  final int hargaRp;
  final int berat;
  final String satuan;
  final String deskripsi;
  final bool isFavorite;
  final VoidCallback? onFavoriteChanged;

  const DetailProduk({
    super.key,
    this.id,
    required this.nama,
    required this.hargaPoin,
    required this.imagePath,
    required this.hargaRp,
    required this.berat,
    required this.satuan,
    required this.deskripsi,
    this.isFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<DetailProduk> createState() => _DetailProdukState();
}

class _DetailProdukState extends State<DetailProduk>
    with SingleTickerProviderStateMixin {
  int quantity = 1;
  final GlobalKey _cartKey = GlobalKey();
  final GlobalKey _addToCartKey = GlobalKey();
  late AnimationController _animationController;
  OverlayEntry? _overlayEntry;
  late bool _isFavorite;
  bool _isFavoriteLoading = false;
  bool _isAddingToCart = false; // Add loading state for add to cart

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _isFavorite = widget.isFavorite;
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.dispose();
    super.dispose();
  }

  // Function to get user-friendly error message
  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Koneksi timeout. Silakan coba lagi.";
        case DioExceptionType.connectionError:
          return "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
        case DioExceptionType.badResponse:
          if (error.response?.statusCode == 401) {
            return "Silakan login terlebih dahulu.";
          } else if (error.response?.statusCode == 500) {
            return "Terjadi kesalahan pada server. Silakan coba lagi nanti.";
          } else if (error.response?.statusCode == 404) {
            return "Produk tidak ditemukan.";
          } else {
            return "Gagal menambahkan ke keranjang. Silakan coba lagi.";
          }
        case DioExceptionType.cancel:
          return "Permintaan dibatalkan.";
        default:
          return "Terjadi kesalahan. Silakan coba lagi.";
      }
    } else if (error
        .toString()
        .contains("No address associated with hostname")) {
      return "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
    } else if (error.toString().contains("User tidak terautentikasi")) {
      return "Silakan login terlebih dahulu.";
    } else if (error.toString().contains("ID produk kosong")) {
      return "Produk tidak valid. Silakan coba lagi.";
    } else {
      return "Terjadi kesalahan. Silakan coba lagi.";
    }
  }

  // Function to toggle favorite
  Future<void> _toggleFavorite() async {
    if (widget.id == null) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      final favoriteService = FavoriteService();
      final newFavoriteStatus = await favoriteService.toggleFavorite(
        context,
        int.parse(widget.id!),
      );

      setState(() {
        _isFavorite = newFavoriteStatus;
      });

      // Callback is only invoked on user interaction
      if (widget.onFavoriteChanged != null) {
        widget.onFavoriteChanged!();
      }

      Fluttertoast.showToast(
        msg: _isFavorite ? "Ditambahkan ke favorit" : "Dihapus dari favorit",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: _getErrorMessage(e),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isFavoriteLoading = false;
      });
    }
  }

  // Function to start animation
  void _startAnimation() {
    // Check mounted before starting animation
    if (!mounted) return;

    final RenderBox addToCartRenderBox =
        _addToCartKey.currentContext!.findRenderObject() as RenderBox;
    final RenderBox cartRenderBox =
        _cartKey.currentContext!.findRenderObject() as RenderBox;

    final Offset startPosition = addToCartRenderBox.localToGlobal(Offset.zero);
    final Offset endPosition = cartRenderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          // Check mounted
          if (!mounted) return const SizedBox.shrink();
          final progress =
              Curves.easeInOut.transform(_animationController.value);
          final currentPosition = Offset(
            startPosition.dx + (endPosition.dx - startPosition.dx) * progress,
            startPosition.dy + (endPosition.dy - startPosition.dy) * progress,
          );

          return Positioned(
            left: currentPosition.dx,
            top: currentPosition.dy,
            child: Opacity(
              opacity: 1 - progress,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: CachedNetworkImage(
                    width: 40,
                    height: 40,
                    imageUrl: widget.imagePath,
                    memCacheHeight: 100,
                    memCacheWidth: 100,
                    maxWidthDiskCache: 100,
                    maxHeightDiskCache: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.white,
                      child: const Center(
                        child: Icon(
                          Icons.shopping_cart,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/placeholder.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    _animationController.forward().then((_) {
      if (mounted && _overlayEntry != null) {
        _overlayEntry?.remove();
        _overlayEntry = null;
      }
    });
  }

  // Updated addToCart function with better error handling
  Future<void> addToCart(BuildContext context) async {
    // Prevent multiple simultaneous requests
    if (_isAddingToCart) return;

    setState(() {
      _isAddingToCart = true;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final token = userProvider.token;
      final userId = userProvider.userId;

      if (token == null || userId == null) {
        throw Exception("User tidak terautentikasi");
      }

      if (widget.id == null) {
        throw Exception("ID produk kosong");
      }

      await CartService().addToCart(
        context,
        userId.toString(),
        widget.id.toString(),
        quantity,
      );

      // Show success message
      // Fluttertoast.showToast(
      //   msg: "Produk berhasil ditambahkan ke keranjang",
      //   toastLength: Toast.LENGTH_SHORT,
      //   gravity: ToastGravity.BOTTOM,
      //   backgroundColor: Colors.green,
      //   textColor: Colors.white,
      // );

      // Reset animation controller
      _animationController.reset();

      // Run animation
      if (_addToCartKey.currentContext != null &&
          _cartKey.currentContext != null) {
        _startAnimation();
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');

      // Show user-friendly error message
      Fluttertoast.showToast(
        msg: _getErrorMessage(e),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      setState(() {
        _isAddingToCart = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
            fontSize: 16,
          ),
        ),
        actions: [
          // Cart button
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Stack(
                  key: _cartKey,
                  clipBehavior: Clip.none,
                  children: [
                    const Icon(Icons.shopping_cart),
                    if (cartProvider.cartItemCount > 0)
                      Positioned(
                        right: -5,
                        top: -5,
                        child: CircleAvatar(
                          radius: 8,
                          backgroundColor: Colors.red,
                          child: Text(
                            '${cartProvider.cartItemCount}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 8,
                              color: Colors.white,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const CartScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
              );
            },
          ),
          const SizedBox(width: 4),
        ],
      ),
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image and Product Name Section
          SizedBox(
            width: double.infinity,
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 250,
                  decoration: const BoxDecoration(
                    color: Color(0XFFF5F5F5),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: widget.imagePath,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    memCacheHeight: 900,
                    memCacheWidth: 900,
                    maxWidthDiskCache: 900,
                    maxHeightDiskCache: 900,
                    fadeInDuration: Duration.zero,
                    placeholder: (context, url) => FutureBuilder<FileInfo?>(
                      future: AppCacheManager().getFileFromCache(url),
                      builder: (context, snapshot) {
                        if (snapshot.hasData &&
                            snapshot.data!.file.existsSync()) {
                          return Image.file(
                            snapshot.data!.file,
                            fit: BoxFit.cover,
                          );
                        }
                        return Container(
                          color: const Color(0xFFF0F1F5),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF74B11A),
                            ),
                          ),
                        );
                      },
                    ),
                    errorWidget: (context, url, error) => Image.asset(
                      'assets/images/placeholder.png',
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row for product name and favorite button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Text(
                              widget.nama,
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                                fontSize: 24,
                                color: Color(0xFF1F2131),
                              ),
                            ),
                          ),
                          // Favorite button
                          _isFavoriteLoading
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.red,
                                  ),
                                )
                              : GestureDetector(
                                  onTap: _toggleFavorite,
                                  child: Center(
                                    child: Icon(
                                      _isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      size: 28,
                                      color: _isFavorite
                                          ? Colors.red
                                          : Colors.grey[600],
                                    ),
                                  ),
                                )
                        ],
                      ),
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/poin.png',
                            width: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            numberFormat.format(widget.hargaPoin),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Color(0xFF1F2131),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            formatRupiah(widget.hargaRp),
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                          Text(
                            '${widget.berat} ${widget.satuan == "Kilogram" ? "Kg" : widget.satuan == "Gram" ? "gram" : widget.satuan == "Biji" ? "biji" : widget.satuan}',
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: Color(0xFF1F2131),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Product Description Section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Deskripsi Produk',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Color(0xFF1F2131),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  widget.deskripsi,
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Spacer to push buttons to bottom
          const Spacer(),

          // Add to Cart and Buy Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                // Add to Cart Button with Icon
                Expanded(
                  key: _addToCartKey,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAddingToCart
                          ? Colors.grey
                          : const Color(0xFF1F2131),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isAddingToCart
                        ? null
                        : () {
                            addToCart(context);
                          },
                    child: _isAddingToCart
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.shopping_cart,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Add to Cart',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(width: 10),

                // Buy Now Button with Icon
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF589400),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => BuyNowModal(
                          id: widget.id,
                          nama: widget.nama,
                          hargaPoin: widget.hargaPoin,
                          hargaRp: widget.hargaRp,
                          imagePath: widget.imagePath,
                          berat: widget.berat,
                          satuan: widget.satuan,
                        ),
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shopping_bag,
                          color: Colors.white,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Buy Now',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
