import 'package:flutter/material.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:getsayor/data/services/favorite_service.dart';
import 'package:getsayor/presentation/pages/produk/components/produk_card.dart';
import 'package:getsayor/presentation/pages/produk/components/shimmer_produk_card.dart';
import 'package:getsayor/core/api/config.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({super.key});

  @override
  FavoriteScreenState createState() => FavoriteScreenState();
}

class FavoriteScreenState extends State<FavoriteScreen> {
  late Future<List<Produk>> _favoritesFuture;
  final FavoriteService _favoriteService = FavoriteService();
  final List<Produk> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    setState(() {
      _favoritesFuture = _favoriteService.getFavorites(context);
    });
  }

  void _removeFavorite(int productId) {
    setState(() {
      _favorites.removeWhere((product) => product.id == productId);
    });
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
              width: 180, // Lebar yang lebih kecil
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
            // TextButton(
            //   onPressed: () {
            //     // Tambahkan logika untuk bantuan lebih lanjut
            //     ScaffoldMessenger.of(context).showSnackBar(
            //       const SnackBar(
            //         content: Text('Bantuan sedang dikirim...'),
            //       ),
            //     );
            //   },
            //   child: Text(
            //     'Butuh bantuan?',
            //     style: TextStyle(
            //       fontFamily: 'Poppins',
            //       color: Colors.grey[600],
            //       decoration: TextDecoration.underline,
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
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
        child: FutureBuilder<List<Produk>>(
          future: _favoritesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return GridView.builder(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 90),
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
            } else if (snapshot.hasError) {
              // Handle timeout khusus
              String errorMessage = 'Terjadi kesalahan saat memuat data';
              if (snapshot.error.toString().contains('Timeout')) {
                errorMessage =
                    'Koneksi timeout. Pastikan koneksi internet Anda stabil dan coba lagi.';
              } else if (snapshot.error.toString().contains('network')) {
                errorMessage =
                    'Tidak ada koneksi internet. Periksa jaringan Anda.';
              }

              return _buildErrorWidget(errorMessage);
            } else if (snapshot.hasData) {
              final favorites = snapshot.data!;
              if (favorites.isEmpty) {
                return const Center(
                  child: Text(
                    'No favorite products yet.',
                    style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
                  ),
                );
              }
              return GridView.builder(
                padding: const EdgeInsets.only(
                    left: 16, right: 16, top: 16, bottom: 90),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 0.70,
                ),
                itemCount: favorites.length,
                itemBuilder: (context, index) {
                  final product = favorites[index];
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
                    isFavorite: true,
                    onFavoriteChanged: () {
                      _removeFavorite(product.id);
                    },
                  );
                },
              );
            } else {
              return _buildErrorWidget('Tidak ada data yang ditemukan');
            }
          },
        ),
      ),
    );
  }
}
