import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:getsayor/presentation/pages/produk/components/shimmer_produk_card.dart';
import 'package:getsayor/data/services/cart_service.dart';
import 'package:getsayor/data/services/produk_service.dart';
import 'package:getsayor/presentation/pages/produk/components/produk_card.dart';
import 'package:getsayor/presentation/pages/produk/components/search_bar_produk.dart';
import 'package:getsayor/presentation/providers/cart_provider.dart';
import 'package:provider/provider.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  ProductScreenState createState() => ProductScreenState();
}

class ProductScreenState extends State<ProductScreen> {
  String searchQuery = "";
  late Future<List<Produk>> _produkFuture;
  final ProdukService _produkService = ProdukService();
  final List<Map<String, dynamic>> categories = [
    {
      'key': 'All',
      'displayName': 'All',
      'assetIcon': 'assets/icons/all.png',
    },
    {
      'key': 'Vegetables',
      'displayName': 'Veggies',
      'assetIcon': 'assets/icons/veggies.png',
    },
    {
      'key': 'Fruits',
      'displayName': 'Fruits',
      'assetIcon': 'assets/icons/fruits.png',
    },
    {
      'key': 'Spices',
      'displayName': 'Spices',
      'assetIcon': 'assets/icons/spices.png',
    },
    {
      'key': 'Seafood',
      'displayName': 'Seafood',
      'assetIcon': 'assets/icons/seafood.png',
    },
    {
      'key': 'Meat_poultry',
      'displayName': 'Meats',
      'assetIcon': 'assets/icons/meats.png',
    },
    {
      'key': 'Tubers',
      'displayName': 'Tubers',
      'assetIcon': 'assets/icons/tubers.png',
    },
    {
      'key': 'Plant_based_protein',
      'displayName': 'Protein',
      'assetIcon': 'assets/icons/protein.png',
    },
  ];
  String selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadProduk();
    _updateCartItemCount();
  }

  // Method to load or reload products
  Future<void> _loadProduk() async {
    setState(() {
      _produkFuture = _produkService.fetchProduk2(context);
    });

    await _updateCartItemCount();
  }

  //update cart item count
  Future<void> _updateCartItemCount() async {
    try {
      int count = await CartService().getCartItemCount(context);
      final cartProvider = Provider.of<CartProvider>(context, listen: false);
      cartProvider.setCartItemCount(count);
    } catch (e) {
      debugPrint('Error getting cart item count: $e');
    }
  }

  // Fungsi yang dijalankan ketika search berubah
  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
  }

  // Fungsi untuk menekan ikon keranjang

  void _showTimeoutBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 50,
              ),
              const SizedBox(height: 20),
              const Text(
                'Connection Timeout',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'The connection timed out. Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _loadProduk();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0XFF74B11A),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Try Again',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    Provider.of<CartProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0XFFF5F5F5),
      body: Column(
        children: [
          // Ganti dengan SearchBarProduk
          Padding(
            padding: const EdgeInsets.only(top: 25),
            child: SearchBarProduk(
              onSearchChanged: _onSearchChanged,
            ),
          ),

          _buildCategoryFilter(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _loadProduk,
              color: const Color(0xFF74B11A),
              backgroundColor: Colors.white,
              child: FutureBuilder<List<Produk>>(
                future: _produkFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return GridView.builder(
                      padding: const EdgeInsets.only(
                          left: 20, right: 20, top: 0, bottom: 90),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        childAspectRatio: 0.70,
                      ),
                      itemCount: 6, // Jumlah placeholder shimmer
                      itemBuilder: (context, index) {
                        return const ShimmerProdukCard();
                      },
                    );
                  } else if (snapshot.hasError &&
                      snapshot.error
                          .toString()
                          .contains('Connection timeout')) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _showTimeoutBottomSheet(context);
                    });
                    return const SizedBox.shrink();
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text('${snapshot.error}'),
                    );
                  } else if (snapshot.hasData) {
                    // Filter produk berdasarkan search query
                    final filteredProducts = snapshot.data!
                        .where((product) => product.nama
                            .toLowerCase()
                            .contains(searchQuery.toLowerCase()))
                        .toList();

                    // Filter produk berdasarkan kategori yang dipilih
                    final categoryFilteredProducts = selectedCategory == 'All'
                        ? filteredProducts
                        : filteredProducts
                            .where((product) =>
                                product.kategori == selectedCategory)
                            .toList();

                    return categoryFilteredProducts.isEmpty
                        ? const Center(
                            child: Text(
                            'No products found.',
                            style: TextStyle(
                                fontFamily: 'Poppins', color: Colors.grey),
                          ))
                        : GridView.builder(
                            padding: const EdgeInsets.only(
                                left: 20, right: 20, top: 0, bottom: 90),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              childAspectRatio: 0.70,
                            ),
                            itemCount: categoryFilteredProducts.length,
                            itemBuilder: (context, index) {
                              final product = categoryFilteredProducts[index];
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
                                  // Perbarui status favorit di list produk
                                  setState(() {
                                    product.isFavorite = !product.isFavorite;
                                  });
                                },
                              );
                            },
                          );
                  } else {
                    return const Center(child: Text('No products found.'));
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.only(left: 20, right: 20, top: 10, bottom: 20),
      child: Row(
        children: [
          for (int i = 0; i < categories.length; i++)
            Padding(
              padding: EdgeInsets.only(
                right: i == categories.length - 1
                    ? 0
                    : 10, // Kondisi untuk padding
              ),
              child: InkWell(
                onTap: () {
                  setState(() {
                    selectedCategory = categories[i]['key'];
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 70,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: selectedCategory == categories[i]['key']
                        ? const Color(0XFFFFAF15)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Color(0XFFF5F5F5),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Image.asset(
                          categories[i]['assetIcon'],
                          width: 24,
                          height: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        categories[i]['displayName'],
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: selectedCategory == categories[i]['key']
                              ? Colors.white
                              : const Color(0xFF595959),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
