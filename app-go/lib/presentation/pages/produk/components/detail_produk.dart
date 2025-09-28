import 'package:flutter/material.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/presentation/pages/produk/components/cart.dart';
import 'package:getsayor/presentation/providers/cart_provider.dart';
import 'package:getsayor/presentation/providers/favorite_provider.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/presentation/pages/produk/components/buy_now_modal.dart';
import 'package:getsayor/data/services/cart_service.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:provider/provider.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dio/dio.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class DetailProduk extends StatefulWidget {
  final String? id;
  final String productItemId;
  final String nama;
  final int hargaPoin;
  final String imagePath;
  final int hargaRp;
  final int berat;
  final String satuan;
  final String deskripsi;

  const DetailProduk({
    super.key,
    required this.id,
    required this.productItemId,
    required this.nama,
    required this.hargaPoin,
    required this.imagePath,
    required this.hargaRp,
    required this.berat,
    required this.satuan,
    required this.deskripsi,
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
  bool _isFavoriteLoading = false;
  bool _isAddingToCart = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _overlayEntry = null;
    _animationController.dispose();
    super.dispose();
  }

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

  Future<void> _toggleFavorite() async {
    if (widget.id == null) return;

    setState(() {
      _isFavoriteLoading = true;
    });

    try {
      final provider = Provider.of<FavoritesProvider>(context, listen: false);
      await provider.toggleFavorite(context, int.parse(widget.id!));

      Fluttertoast.showToast(
        msg: provider.isFavorite(int.parse(widget.id!))
            ? "Ditambahkan ke favorit"
            : "Dihapus dari favorit",
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
      if (mounted) {
        setState(() {
          _isFavoriteLoading = false;
        });
      }
    }
  }

  void _startAnimation() {
    if (!mounted) return;

    final addToCartContext = _addToCartKey.currentContext;
    final cartContext = _cartKey.currentContext;

    if (addToCartContext == null || cartContext == null) return;

    final RenderBox addToCartRenderBox =
        addToCartContext.findRenderObject() as RenderBox;
    final RenderBox cartRenderBox = cartContext.findRenderObject() as RenderBox;

    final Offset startPosition = addToCartRenderBox.localToGlobal(Offset.zero);
    final Offset endPosition = cartRenderBox.localToGlobal(Offset.zero);

    _overlayEntry = OverlayEntry(
      builder: (context) => AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
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

  Future<void> addToCart(BuildContext context) async {
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
        widget.productItemId,
        quantity,
      );

      _animationController.reset();

      if (_addToCartKey.currentContext != null &&
          _cartKey.currentContext != null) {
        _startAnimation();
      }
    } catch (e) {
      debugPrint('Error adding to cart: $e');

      Fluttertoast.showToast(
        msg: _getErrorMessage(e),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isAddingToCart = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = widget.id != null
        ? favoritesProvider.isFavorite(int.parse(widget.id!))
        : false;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1F2131),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: Stack(
                    key: _cartKey,
                    clipBehavior: Clip.none,
                    children: [
                      const Icon(
                        Icons.shopping_cart,
                        color: Color(0xFF1F2131),
                        size: 24,
                      ),
                      if (cartProvider.cartItemCount > 0)
                        Positioned(
                          right: -4,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 16,
                              minHeight: 16,
                            ),
                            child: Text(
                              '${cartProvider.cartItemCount}',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 10,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
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
                ),
              );
            },
          ),
        ],
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Image Section
                  Container(
                    width: double.infinity,
                    height: 280,
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
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
                                snapshot.data != null &&
                                snapshot.data!.file.existsSync()) {
                              return Image.file(
                                snapshot.data!.file,
                                fit: BoxFit.contain,
                              );
                            }
                            return Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8F9FA),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF74B11A),
                                  strokeWidth: 3,
                                ),
                              ),
                            );
                          },
                        ),
                        errorWidget: (context, url, error) => Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8F9FA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/placeholder.png',
                              width: 120,
                              height: 120,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Product Info Section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Product Name and Favorite
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                widget.nama,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 22,
                                  color: Color(0xFF1F2131),
                                  height: 1.3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Perbaikan: Gunakan SizedBox dengan ukuran tetap
                            SizedBox(
                              width: 48, // Lebar tetap
                              height: 48, // Tinggi tetap
                              child: Container(
                                decoration: BoxDecoration(
                                  color: isFavorite
                                      ? Colors.red.withOpacity(0.1)
                                      : Colors.grey.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: _isFavoriteLoading
                                    ? const Center(
                                        // Gunakan Center untuk posisi tengah
                                        child: SizedBox(
                                          width: 24, // Ukuran tetap loading
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    : IconButton(
                                        onPressed: _toggleFavorite,
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          size: 24,
                                          color: isFavorite
                                              ? Colors.red
                                              : Colors.grey[600],
                                        ),
                                        padding: EdgeInsets
                                            .zero, // Hilangkan padding default
                                        constraints:
                                            const BoxConstraints(), // Hilangkan constraint
                                        splashRadius: 24,
                                      ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Points Price
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/poin.png',
                                width: 18,
                                height: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                numberFormat.format(widget.hargaPoin),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w700,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Poin',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Price and Weight Info
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Harga Setara',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  formatRupiah(widget.hargaRp),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 16,
                                    color: Color(0xFF1F2131),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                const Text(
                                  'Berat/Ukuran',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 12,
                                    color: Colors.grey,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
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
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Description Section
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Deskripsi Produk',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w700,
                            fontSize: 18,
                            color: Color(0xFF1F2131),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.deskripsi,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Space for bottom navigation
                ],
              ),
            ),
          ),
        ],
      ),

      // Bottom Navigation with Buttons
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                // Add to Cart Button
                Expanded(
                  key: _addToCartKey,
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF1F2131),
                        width: 2,
                      ),
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1F2131),
                        elevation: 0,
                        shadowColor: Colors.transparent,
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
                                color: Color(0xFF1F2131),
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.shopping_cart_outlined,
                                  color: Color(0xFF1F2131),
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'Add to Cart',
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                    color: Color(0xFF1F2131),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                ),

                const SizedBox(width: 12),

                // Buy Now Button
                Expanded(
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      gradient: const LinearGradient(
                        begin: Alignment.centerLeft, // Mulai dari kiri
                        end: Alignment.centerRight, // Berakhir di kanan
                        colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF589400).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          elevation: 0,
                          backgroundColor: Colors.white,
                          builder: (context) => BuyNowModal(
                            productItemId: widget.productItemId,
                            nama: widget.nama,
                            hargaPoin: widget.hargaPoin,
                            hargaRp: widget.hargaRp,
                            imagePath: widget.imagePath,
                            berat: widget.berat,
                            satuan: widget.satuan,
                          ),
                        );
                        print(
                            "ProductItemID di BuyNowModal: ${widget.productItemId}");
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_bag_outlined,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
