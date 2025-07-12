import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/presentation/pages/produk/components/detail_produk.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:getsayor/data/services/favorite_service.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class ProdukCard extends StatefulWidget {
  final String? id;
  final String nama;
  final String kategori;
  final int hargaPoin;
  final String imagePath;
  final int hargaRp;
  final int berat;
  final String satuan;
  final String deskripsi;
  final bool isFavorite;
  final VoidCallback? onFavoriteChanged;

  const ProdukCard({
    super.key,
    this.id,
    required this.nama,
    required this.kategori,
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
  State<ProdukCard> createState() => _ProdukCardState();
}

class _ProdukCardState extends State<ProdukCard> {
  late bool _isFavorite;

  @override
  void initState() {
    super.initState();
    _isFavorite = widget.isFavorite;
  }

  @override
  void didUpdateWidget(ProdukCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isFavorite != widget.isFavorite) {
      setState(() {
        _isFavorite = widget.isFavorite;
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.id == null) return; // Pastikan ID produk tersedia

    try {
      final favoriteService = FavoriteService();
      final newFavoriteStatus = await favoriteService.toggleFavorite(
        context,
        int.parse(widget.id!),
      );

      setState(() => _isFavorite = newFavoriteStatus);

      // Callback is only invoked on user interaction
      if (widget.onFavoriteChanged != null) {
        widget.onFavoriteChanged!();
      }
    } catch (e) {
      Fluttertoast.showToast(
          msg: "Gagal memperbarui favorit: ${e.toString()}",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                DetailProduk(
              id: widget.id,
              nama: widget.nama,
              hargaPoin: widget.hargaPoin,
              hargaRp: widget.hargaRp,
              berat: widget.berat,
              satuan: widget.satuan,
              imagePath: widget.imagePath,
              deskripsi: widget.deskripsi,
              isFavorite: _isFavorite,
              onFavoriteChanged: widget.onFavoriteChanged,
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
            child: IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.grey[600],
                size: 25,
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
                '${widget.berat} ${_getUnitSymbol(widget.satuan)}',
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
                formatRupiah(widget.hargaRp),
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
                    numberFormat.format(widget.hargaPoin),
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
