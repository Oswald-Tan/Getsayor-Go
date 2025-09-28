import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/data/model/produk_model.dart';
import 'package:getsayor/presentation/pages/produk/components/detail_produk.dart';
import 'package:getsayor/presentation/providers/favorite_provider.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class ProdukCard extends StatefulWidget {
  final int id;
  final String nama;
  final String kategori;
  final String imagePath;
  final String deskripsi;
  final ProductItem productItem;
  final bool initialFavorite;
  final ValueChanged<bool>? onFavoriteChanged;

  const ProdukCard({
    super.key,
    required this.id,
    required this.nama,
    required this.kategori,
    required this.imagePath,
    required this.deskripsi,
    required this.productItem,
    this.initialFavorite = false,
    this.onFavoriteChanged,
  });

  @override
  State<ProdukCard> createState() => _ProdukCardState();
}

class _ProdukCardState extends State<ProdukCard> {
  bool _isFavoriteLoading = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didUpdateWidget(ProdukCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFavorite != widget.initialFavorite) {
      setState(() {});
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavoriteLoading = true);
    try {
      final provider = Provider.of<FavoritesProvider>(context, listen: false);
      await provider.toggleFavorite(context, widget.id);
    } catch (e) {
      // Tampilkan pesan error sesuai jenis error
      String errorMessage;

      if (e is DioException) {
        switch (e.type) {
          case DioExceptionType.connectionTimeout:
          case DioExceptionType.sendTimeout:
          case DioExceptionType.receiveTimeout:
            errorMessage = "Koneksi timeout. Silakan coba lagi.";
            break;
          case DioExceptionType.connectionError:
            errorMessage =
                "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
            break;
          case DioExceptionType.badResponse:
            if (e.response?.statusCode == 401) {
              errorMessage = "Silakan login terlebih dahulu.";
            } else if (e.response?.statusCode == 500) {
              errorMessage =
                  "Terjadi kesalahan pada server. Silakan coba lagi nanti.";
            } else {
              errorMessage = "Gagal memperbarui favorit. Silakan coba lagi.";
            }
            break;
          default:
            errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
        }
      } else if (e.toString().contains("No address associated with hostname")) {
        errorMessage =
            "Tidak dapat terhubung ke server. Periksa koneksi internet Anda.";
      } else if (e.toString().contains("User not authenticated")) {
        errorMessage = "Silakan login terlebih dahulu.";
      } else {
        errorMessage = "Terjadi kesalahan. Silakan coba lagi.";
      }

      Fluttertoast.showToast(
        msg: errorMessage,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } finally {
      if (mounted) setState(() => _isFavoriteLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final favoritesProvider = Provider.of<FavoritesProvider>(context);
    final isFavorite = favoritesProvider.isFavorite(widget.id);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetailProduk(
              id: widget.id.toString(),
              productItemId: widget.productItem.id.toString(),
              nama: widget.nama,
              hargaPoin: widget.productItem.hargaPoin,
              hargaRp: widget.productItem.hargaRp,
              berat: widget.productItem.jumlah,
              satuan: widget.productItem.satuan,
              imagePath: widget.imagePath,
              deskripsi: widget.deskripsi,
            ),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      },
      child: Stack(
        children: [
          Container(
            // width: 200,
            // height: 275,
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(6),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                      child: widget.imagePath.startsWith('http')
                          ? CachedNetworkImage(
                              imageUrl: widget.imagePath,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                              memCacheHeight: 350,
                              memCacheWidth: 350,
                              maxHeightDiskCache: 350,
                              maxWidthDiskCache: 350,
                              fadeInDuration: Duration.zero,
                              placeholder: (context, url) =>
                                  FutureBuilder<FileInfo?>(
                                future: AppCacheManager().getFileFromCache(url),
                                builder: (context, snapshot) {
                                  if (snapshot.hasData &&
                                      snapshot.data != null &&
                                      snapshot.data!.file.existsSync()) {
                                    return Image.file(
                                      snapshot.data!.file,
                                      fit: BoxFit.cover,
                                    );
                                  }
                                  return _buildPlaceholder();
                                },
                              ),
                              errorWidget: (context, url, error) =>
                                  _buildErrorWidget(),
                            )
                          : Image.asset(
                              widget.imagePath,
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                ),
                _buildProductInfo(),
              ],
            ),
          ),
          // Tombol favorite
          Positioned(
            top: 3,
            right: 3,
            child: _isFavoriteLoading
                ? Container(
                    padding: const EdgeInsets.all(8),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Color(0xFF74B11A),
                        strokeWidth: 2,
                      ),
                    ),
                  )
                : IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey[600],
                    ),
                    onPressed: _toggleFavorite,
                  ),
          )
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFF74B11A),
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Image.asset(
      'assets/images/placeholder.png',
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
    );
  }

  Widget _buildProductInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16, top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama produk
          Text(
            widget.nama,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Baris untuk kategori dan berat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Kategori produk
              Text(
                _getDisplayCategory(widget.kategori),
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              // Berat produk
              Text(
                '${widget.productItem.jumlah} ${_getUnitSymbol(widget.productItem.satuan)}',
                style: const TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1F2131),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Baris untuk harga Rupiah dan harga poin
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Harga Rupiah
              Text(
                formatRupiah(widget.productItem.hargaRp),
                style: const TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF74B11A)),
              ),
              // Harga Poin
              Row(
                children: [
                  Image.asset(
                    'assets/images/poin.png',
                    width: 14,
                  ),
                  const SizedBox(width: 3),
                  Text(
                    numberFormat.format(widget.productItem.hargaPoin),
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Color(0xFF1F2131),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getUnitSymbol(String unit) {
    switch (unit) {
      case "Kilogram":
        return "Kg";
      case "Gram":
        return "gr";
      case "Biji":
        return "biji";
      case "Buah":
        return "buah";
      case "Pcs":
        return "pcs";
      default:
        return unit;
    }
  }

  String _getDisplayCategory(String category) {
    switch (category) {
      case 'Vegetables':
        return 'Veggie';
      case 'Seafood':
        return 'Fish';
      case 'Meat_poultry':
        return 'Meat';
      case 'Plant_based_protein':
        return 'Protein';
      default:
        return category;
    }
  }
}
