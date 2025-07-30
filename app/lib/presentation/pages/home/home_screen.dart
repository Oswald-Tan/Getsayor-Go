import 'dart:io';

import 'package:collection/collection.dart';
import 'package:dio/dio.dart';
import 'package:getsayor/presentation/pages/home/components/card_saldo_poin.dart';
import 'package:getsayor/presentation/pages/home/components/shimmer_discount_topup.dart';
import 'package:getsayor/presentation/pages/produk/components/cart.dart';
import 'package:getsayor/presentation/pages/top_up/components/buy_points.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:getsayor/data/model/poin_model.dart';
import 'package:getsayor/data/services/poin_service.dart';
import 'package:getsayor/data/services/produk_service.dart';
import 'package:getsayor/presentation/pages/produk/components/produk_card.dart';
import 'package:getsayor/presentation/pages/produk/components/shimmer_produk_card.dart';
import 'package:getsayor/presentation/pages/produk/components/search_bar_produk.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:getsayor/presentation/providers/cart_provider.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class CategoryState {
  List<Produk> produkList = [];
  int currentPage = 1;
  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;
  String? errorMessage;
}

class _HomeScreenState extends State<HomeScreen> {
  late final IApEngine iApEngine = IApEngine();
  late ScrollController _scrollController;
  bool _isLoadingIAP = false;
  bool _hasPromo = false;
  bool _isInitialLoad = true;

  bool _isSearching = false;
  List<Produk> _searchResults = [];

  final int _perPage = 10;
  final ProdukService _produkService = ProdukService();

  final List<Map<String, dynamic>> categories = [
    {
      'key': 'All',
      'displayName': 'All',
      'assetIcon': 'assets/icons/all.png',
      'color': const Color(0xFFBDD1FF),
    },
    {
      'key': 'Vegetables',
      'displayName': 'Veggies',
      'assetIcon': 'assets/icons/veggies.png',
      'color': const Color(0xFFA5D6A7),
    },
    {
      'key': 'Fruits',
      'displayName': 'Fruits',
      'assetIcon': 'assets/icons/fruits.png',
      'color': const Color(0xFFFFCC80),
    },
    {
      'key': 'Spices',
      'displayName': 'Spices',
      'assetIcon': 'assets/icons/spices.png',
      'color': const Color(0xFFF8A7A7),
    },
    {
      'key': 'Seafood',
      'displayName': 'Seafood',
      'assetIcon': 'assets/icons/seafood.png',
      'color': const Color(0xFFFFAEB2),
    },
    {
      'key': 'Meat_poultry',
      'displayName': 'Meats',
      'assetIcon': 'assets/icons/meats.png',
      'color': const Color(0xFFFFA69C),
    },
    {
      'key': 'Tubers',
      'displayName': 'Tubers',
      'assetIcon': 'assets/icons/tubers.png',
      'color': const Color(0xFFFFD57B),
    },
    {
      'key': 'Plant_based_protein',
      'displayName': 'Protein',
      'assetIcon': 'assets/icons/protein.png',
      'color': const Color(0xFFF7E5A0),
    },
  ];
  String selectedCategory = 'All';
  String searchQuery = '';
  List<Poin> discountedPoins = [];
  bool isLoadingPoins = false;
  String message = "";
  Map<String, CategoryState> categoryStates = {};
  bool _isProductLoaded = false;
  bool _isIAPLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final arguments = ModalRoute.of(context)!.settings.arguments;

    if (arguments != null) {
      Map? pushArguments = arguments as Map;

      setState(() {
        message = pushArguments['message'];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Inisialisasi state untuk semua kategori
    for (var category in categories) {
      categoryStates[category['key']] = CategoryState();
    }

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _loadInitialData();
    _initData();
  }

  // Fungsi baru untuk memuat data awal
  Future<void> _loadInitialData() async {
    await Future.wait([
      _loadCategoryProduk('All'),
      _fetchIAPProducts(),
    ]);

    // Set state setelah semua data selesai dimuat
    if (mounted) {
      setState(() {
        _isInitialLoad = false;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;

    // Load lebih awal sebelum mencapai akhir (500 pixel sebelum akhir)
    if (maxScroll - currentScroll <= 500 && !_isSearching) {
      _loadMoreProduk();
    }
  }

  Future<void> _loadCategoryProduk(String category,
      {bool reset = false}) async {
    final state = categoryStates[category]!;

    if (reset) {
      state.produkList.clear();
      state.currentPage = 1;
      state.hasMore = true;
    }

    setState(() {
      if (reset) {
        state.isLoading = true;
      } else {
        state.isLoadingMore = true;
      }
      state.errorMessage = null;
    });

    try {
      final produk = await _produkService.fetchProduk(
        context,
        page: state.currentPage,
        perPage: _perPage,
        category: category == 'All' ? null : category,
      );

      setState(() {
        state.produkList.addAll(produk);
        state.hasMore = produk.length == _perPage;
        state.currentPage++;
        state.isLoading = false;
        state.isLoadingMore = false;
        _isProductLoaded = true;
      });
    } catch (e) {
      String errorMessage = 'Terjadi kesalahan saat memuat produk';
      if (e.toString().contains('Timeout')) {
        errorMessage =
            'Koneksi timeout. Pastikan koneksi internet Anda stabil dan coba lagi.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      }

      setState(() {
        state.errorMessage = errorMessage;
        state.isLoading = false;
        state.isLoadingMore = false;
        _isProductLoaded = true;
      });
    }
  }

  void _onCategorySelected(String category) {
    setState(() {
      selectedCategory = category;
      searchQuery = "";
      _isSearching = false;
      _searchResults = [];
    });

    // Selalu reset dan muat ulang data saat kategori berubah
    _loadCategoryProduk(category, reset: true);
  }

  Future<void> _loadMoreProduk() async {
    final state = categoryStates[selectedCategory]!;

    if (!state.hasMore || state.isLoadingMore || _isSearching) return;

    await _loadCategoryProduk(selectedCategory);
  }

  List<Map<String, dynamic>> _iapProductsWithPoin = [];

  Future<void> _fetchIAPProducts() async {
    setState(() => _isLoadingIAP = true);
    try {
      PoinService poinService = PoinService();
      List<Poin> poinList = await poinService.fetchPoin(context);

      List<String> productIds = poinList
          .map((poin) => [
                poin.productId,
                if (poin.promoProductId != null) poin.promoProductId
              ])
          .expand((id) => id)
          .whereType<String>()
          .toList();

      if (await iApEngine.getIsAvailable()) {
        final response = await iApEngine.queryProducts(productIds);
        List<Map<String, dynamic>> combinedList = [];

        for (Poin poin in poinList) {
          // Gunakan firstWhereOrNull
          ProductDetails? mainProduct =
              response.productDetails.firstWhereOrNull(
            (p) => p.id == poin.productId,
          );

          ProductDetails? promoProduct;
          if (poin.promoProductId != null) {
            promoProduct = response.productDetails.firstWhereOrNull(
              (p) => p.id == poin.promoProductId,
            );
          }

          if (mainProduct != null) {
            combinedList.add({
              'poin': poin,
              'product': mainProduct,
              'isPromo': false,
            });
          }

          if (promoProduct != null) {
            combinedList.add({
              'poin': poin,
              'product': promoProduct,
              'isPromo': true,
            });
          }
        }
        // Hitung apakah ada promo
        bool hasPromo = combinedList.any((item) => item['isPromo'] == true);

        setState(() {
          _iapProductsWithPoin = combinedList;
          _hasPromo = hasPromo;
          _isIAPLoaded = true;
        });
      }
    } catch (e) {
      debugPrint("Error fetching IAP products: $e");
    } finally {
      setState(() => _isLoadingIAP = false);
      _isIAPLoaded = true;
    }
  }

  Future<void> _initData() async {
    _loadCartCount();
  }

  Future<void> _loadCartCount() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    await cartProvider.loadCartItemCount(context);
  }

  // Fungsi ketika pencarian berubah
  void _onSearchChanged(String query) async {
    setState(() {
      searchQuery = query;
      _isSearching = query.isNotEmpty;
      _searchResults = [];
    });

    if (query.isEmpty) {
      return;
    }

    try {
      final state = categoryStates[selectedCategory]!;
      setState(() => state.isLoading = true);

      final results = await _produkService
          .searchProduk(
        context,
        query: query,
        category: selectedCategory,
      )
          .timeout(const Duration(seconds: 10), onTimeout: () {
        throw 'Connection timeout. Please try again.';
      });

      setState(() {
        _searchResults = results;
      });
    } catch (e) {
      String errorMessage = 'Failed to search products';
      if (e is DioException) {
        if (e.response?.statusCode == 404) {
          errorMessage = 'No products found for "$query"';
          setState(() {
            _searchResults = [];
          });
        } else {
          errorMessage = 'Network error: ${e.message}';
        }
      } else {
        errorMessage = e.toString();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      setState(() {
        final state = categoryStates[selectedCategory]!;
        state.isLoading = false;
      });
    }
  }

  void _onCartPressed() {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const CartScreen(),
        transitionDuration: Duration.zero, // Tidak ada durasi animasi
        reverseTransitionDuration: Duration.zero, // Tidak ada animasi balik
      ),
    );
  }

  List<Widget> _buildProductSliverList() {
    final state = categoryStates[selectedCategory]!;
    final productsToDisplay = _isSearching ? _searchResults : state.produkList;

    // Tampilkan loading saat pertama kali memuat
    if (state.isLoading && state.currentPage == 1) {
      return [
        SliverPadding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 20,
            bottom: 90,
          ),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.70,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ShimmerProdukCard(),
              childCount: 4,
            ),
          ),
        ),
      ];
    }

    // Filter products by search query
    final filteredProducts = productsToDisplay
        .where((product) =>
            product.nama.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    // Dapatkan nama kategori yang user-friendly
    String categoryName = selectedCategory;
    if (selectedCategory != 'All') {
      final category = categories.firstWhere(
        (cat) => cat['key'] == selectedCategory,
        orElse: () => {'displayName': selectedCategory},
      );
      categoryName = category['displayName'];
    }

    // Handle search when no results in selected category
    if (_isSearching && filteredProducts.isEmpty && !state.isLoading) {
      // Get category display name
      final category = categories.firstWhere(
        (c) => c['key'] == selectedCategory,
        orElse: () => {'displayName': selectedCategory},
      );
      final categoryName = category['displayName'];

      return [
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Produk "${searchQuery}" tidak ditemukan\npada kategori $categoryName',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Coba kategori lain atau kata kunci berbeda',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[500],
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    // Show search status messages (general no results)
    if (_isSearching && filteredProducts.isEmpty && !state.isLoading) {
      return [
        SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'No products found for "$searchQuery"',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey[500],
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }

    List<Widget> slivers = [];

    // Handle error state
    if (state.errorMessage != null && !_isSearching) {
      slivers.add(
        SliverToBoxAdapter(
          child: _buildProductErrorWidget(state.errorMessage!),
        ),
      );
      return slivers;
    }

    // Handle empty state (no products at all)
    if (filteredProducts.isEmpty && !state.isLoadingMore && !_isSearching) {
      slivers.add(
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Tidak ada produk yang ditemukan',
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      return slivers;
    }

    // Product grid
    slivers.add(
      SliverPadding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 20,
          bottom: (!state.hasMore || _isSearching) ? 90 : 10,
        ),
        sliver: SliverGrid(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.70,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = filteredProducts[index];
              return ProdukCard(
                id: product.id.toString(),
                nama: product.nama,
                kategori: product.kategori,
                hargaPoin: product.hargaPoin,
                hargaRp: product.hargaRp,
                berat: product.jumlah,
                satuan: product.satuan,
                imagePath: product.image != null
                    ? '$baseUrlStatic/${product.image}'
                    : 'assets/images/placeholder.png',
                deskripsi: product.deskripsi,
                isFavorite: product.isFavorite,
                onFavoriteChanged: () {
                  setState(() {
                    product.isFavorite = !product.isFavorite;
                  });
                },
              );
            },
            childCount: filteredProducts.length,
          ),
        ),
      ),
    );

    // TAMPILKAN LOADING MORE INDICATOR HANYA JIKA BUKAN INITIAL LOAD
    if (state.isLoadingMore && !_isSearching && state.currentPage > 1) {
      slivers.add(
        SliverPadding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 90),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 0.70,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) => const ShimmerProdukCard(),
              childCount: 4, // Menampilkan 2 shimmer (satu baris)
            ),
          ),
        ),
      );
    }

    return slivers;
  }

  // Widget kategori filter
  Widget _buildCategoryFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 0),
            child: Row(
              children: [
                for (int i = 0; i < categories.length; i++) ...[
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: InkWell(
                      onTap: () => _onCategorySelected(categories[i]['key']),
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selectedCategory == categories[i]['key']
                              ? categories[i]['color']
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              categories[i]['assetIcon'],
                              width: 24,
                              height: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              categories[i]['displayName'],
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedCategory == categories[i]['key']
                                    ? Colors.white
                                    : const Color(0xFF1F2131),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Widget untuk menampilkan error produk
  Widget _buildProductErrorWidget(String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/no-internet.png',
              width: 150,
              height: 150,
            ),
            const SizedBox(height: 16),
            Text(
              'Gagal Memuat Produk',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 180, // Lebar yang lebih kecil
              child: ElevatedButton.icon(
                onPressed: () =>
                    _loadCategoryProduk(selectedCategory, reset: true),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text(
                  'Coba Lagi',
                  style: TextStyle(fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 68),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    Provider.of<CartProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: 80,
        backgroundColor: const Color(0XFFF5F5F5),
        title: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Getsayor',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      final fullname = userProvider.fullname ?? 'User';
                      final firstName = fullname.split(' ').first;
                      return Text(
                        'Hi, $firstName!',
                        style: const TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          color: Colors.black,
                        ),
                      );
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  const SizedBox(width: 4),
                  // Ikon keranjang dengan badge
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, child) {
                      return Stack(
                        children: [
                          GestureDetector(
                            onTap: _onCartPressed,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                              ),
                              alignment: Alignment.center,
                              child: const Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Icon(
                                  Icons.shopping_cart_outlined,
                                  size: 20,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          if (cartProvider.cartItemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: CircleAvatar(
                                radius: 8,
                                backgroundColor: Colors.red,
                                child: Text(
                                  cartProvider.cartItemCount.toString(),
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
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _isInitialLoad = true;
                _isProductLoaded = false;
                _isIAPLoaded = false;
              });

              userProvider.getUserData(userProvider.token!);
              await _loadCartCount();

              await Future.wait([
                _loadCategoryProduk(selectedCategory, reset: true),
                _fetchIAPProducts(),
              ]);

              if (mounted) {
                setState(() => _isInitialLoad = false);
              }
            },
            color: const Color(0xFF74B11A),
            backgroundColor: Colors.white,
            child: CustomScrollView(
              controller: _scrollController,
              slivers: [
                SliverToBoxAdapter(
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 125,
                        child: CardSaldoPoin(),
                      ),

                      // Search bar
                      SearchBarProduk(
                        onSearchChanged: _onSearchChanged,
                      ),

                      // Kategori filter
                      _buildCategoryFilter(),

                      if (_isInitialLoad) ...[
                        const ShimmerCarousel(),
                      ] else ...[
                        if (_isLoadingIAP && _hasPromo)
                          const ShimmerCarousel()
                        else if (_iapProductsWithPoin.isNotEmpty)
                          DiscountedPoinCarousel(
                            iapProductsWithPoin: _iapProductsWithPoin,
                            onTap: (productId) {
                              Navigator.pushNamed(
                                context,
                                BuyPoints.routeName,
                                arguments: productId,
                              );
                            },
                          ),
                      ],
                    ],
                  ),
                ),
                // Daftar produk - tampilkan shimmer jika initial load
                if (_isInitialLoad) ...[
                  SliverPadding(
                    padding: const EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: 20,
                      bottom: 90,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.70,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => const ShimmerProdukCard(),
                        childCount: 4,
                      ),
                    ),
                  ),
                ] else ...[
                  ..._buildProductSliverList(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class IApEngine {
  final InAppPurchase inAppPurchase = InAppPurchase.instance;

  Future<bool> getIsAvailable() async => await inAppPurchase.isAvailable();

  Future<ProductDetailsResponse> queryProducts(List<String> productIds) async {
    return await inAppPurchase.queryProductDetails(productIds.toSet());
  }

  Future<void> handlePurchase({
    required ProductDetails productDetails,
    required int pointAmount,
  }) async {
    late PurchaseParam purchaseParam;

    if (Platform.isAndroid) {
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );
    }

    try {
      await inAppPurchase.buyConsumable(
        purchaseParam: purchaseParam,
        autoConsume: true,
      );
    } catch (e) {
      debugPrint("Purchase error: $e");
    }
  }
}

class DiscountedPoinCarousel extends StatelessWidget {
  final List<Map<String, dynamic>> iapProductsWithPoin;
  final Function(String) onTap;

  const DiscountedPoinCarousel({
    super.key,
    required this.iapProductsWithPoin,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat("#,##0", "id_ID");

    // Filter hanya produk promo
    final promoProducts =
        iapProductsWithPoin.where((item) => item['isPromo'] == true).toList();

    if (promoProducts.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 16, top: 16, bottom: 10),
          child: Text(
            "Promo Spesial Top Up",
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2131),
            ),
          ),
        ),
        SizedBox(
          height: 140,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
              ),
              image: DecorationImage(
                image: AssetImage('assets/images/grid.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              clipBehavior: Clip.none,
              itemCount: promoProducts.length,
              separatorBuilder: (context, index) => const SizedBox(width: 15),
              itemBuilder: (context, index) {
                final item = promoProducts[index];
                final product = item['product'] as ProductDetails;
                final poin = item['poin'] as Poin;

                // Cari produk utama yang sesuai
                final mainProductItem = iapProductsWithPoin.firstWhereOrNull(
                    (item) =>
                        item['poin'].id == poin.id &&
                        item['isPromo'] == false &&
                        item['product'].id == poin.productId);

                final mainProduct = mainProductItem != null
                    ? mainProductItem['product'] as ProductDetails
                    : null;

                return GestureDetector(
                  onTap: () => onTap(product.id),
                  child: Container(
                    width: 240,
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          spreadRadius: 2,
                          offset: const Offset(2, 2),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                'assets/images/poin.png',
                                width: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                numberFormat.format(poin.poin),
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Tampilkan harga asli dari produk utama
                              if (mainProduct != null)
                                Text(
                                  mainProduct
                                      .price, // Harga asli dari produk utama
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                              Text(
                                product.price,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Color(0xFF74B11A),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const Spacer(),
                              // Tampilkan badge promo
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.discount,
                                      size: 10,
                                      color: Colors.white,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Special Offer',
                                      style: TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.white,
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
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
