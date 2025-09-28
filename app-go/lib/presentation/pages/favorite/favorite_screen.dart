import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/produk/components/produk_card.dart';
import 'package:getsayor/presentation/pages/produk/components/shimmer_produk_card.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/presentation/providers/favorite_provider.dart';
import 'package:provider/provider.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  FavoriteScreenState createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  bool _isLoading = true;
  String? _errorMessage;
  late FavoritesProvider _provider;

  @override
  void initState() {
    super.initState();
    // Dapatkan provider setelah frame pertama
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFavorites();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Dapatkan provider saat dependencies berubah
    _provider = Provider.of<FavoritesProvider>(context, listen: false);
  }

  Future<void> _loadFavorites() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      await _provider.loadFavorites(context);

      if (!mounted) return;
      setState(() => _isLoading = false);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  // Widget untuk menampilkan tampilan error
  Widget _buildErrorWidget(String errorMessage) {
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
            const SizedBox(height: 24),
            Text(
              'Gagal Memuat Data',
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
            const SizedBox(height: 24),
            SizedBox(
              width: 180,
              child: ElevatedButton.icon(
                onPressed: _loadFavorites,
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
            const SizedBox(height: 26),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<FavoritesProvider>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          'Favorite Products',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Color(0xFF1F2131),
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0XFFF5F5F5),
      body: RefreshIndicator(
        onRefresh: _loadFavorites,
        color: const Color(0xFF74B11A),
        backgroundColor: Colors.white,
        child: _buildBodyContent(provider),
      ),
    );
  }

  Widget _buildBodyContent(FavoritesProvider provider) {
    if (_isLoading) return _buildLoadingState();
    if (_errorMessage != null) return _buildErrorWidget(_errorMessage!);
    if (provider.favorites.isEmpty) return _buildEmptyState();

    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.70,
      ),
      itemCount: provider.favorites.length,
      itemBuilder: (context, index) {
        final product = provider.favorites.values.elementAt(index);
        return ProdukCard(
          id: product.id,
          nama: product.nama,
          kategori: product.kategori,
          productItem: product.varianUtama,
          imagePath: product.image != null
              ? '$baseUrlStatic/${product.image}'
              : 'assets/images/placeholder.png',
          deskripsi: product.deskripsi,
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return GridView.builder(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 90),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.70,
      ),
      itemCount: 6,
      itemBuilder: (context, index) {
        return const ShimmerProdukCard();
      },
    );
  }

  Widget _buildEmptyState() {
    // Perbaikan: Gunakan SingleChildScrollView agar bisa di-refresh
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: const Center(
          child: Text(
            'No favorite products yet.',
            style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
