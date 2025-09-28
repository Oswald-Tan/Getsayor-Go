import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:getsayor/cache_manager/cache_manager.dart';
import 'package:getsayor/presentation/pages/produk/components/pesanan_selection.dart';
import 'package:intl/intl.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

class BuyNowModal extends StatefulWidget {
  final String? productItemId;
  final String nama;
  final int hargaRp;
  final int hargaPoin;
  final String imagePath;
  final int berat;
  final String satuan;

  const BuyNowModal({
    super.key,
    this.productItemId,
    required this.nama,
    required this.hargaRp,
    required this.hargaPoin,
    required this.imagePath,
    required this.berat,
    required this.satuan,
  });

  @override
  BuyNowModalState createState() => BuyNowModalState();
}

class BuyNowModalState extends State<BuyNowModal> {
  late int quantity;
  late int baseWeight; //variabel untuk menyimpan berat dasar

  @override
  void initState() {
    super.initState();
    baseWeight = widget.berat; // Simpan berat dasar dari widget
    quantity = 1; // Mulai dari quantity 1
  }

  // Fungsi untuk menambah atau mengurangi berat produk
  // void _updateQuantity(bool increase) {
  //   setState(() {
  //     if (widget.satuan.toLowerCase() == "gram") {
  //       //jika satua gram, tambahkan atau kurangi kelipatan 100
  //       if (increase) {
  //         productQuantity += 100;
  //       } else if (productQuantity > 100) {
  //         productQuantity -= 100;
  //       }
  //     } else if (widget.satuan.toLowerCase() == "kilogram") {
  //       //jika satuan kilogram, tambahkan atau kurangi 1
  //       if (increase) {
  //         productQuantity += 1;
  //       } else if (productQuantity > 1) {
  //         productQuantity -= 1;
  //       }
  //     } else if (widget.satuan.toLowerCase() == "ikat") {
  //       //jika satuan ikat, tambahkan atau kurangi 1
  //       if (increase) {
  //         productQuantity += 1;
  //       } else if (productQuantity > 1) {
  //         productQuantity -= 1;
  //       }
  //     }
  //   });
  // }

  void _updateQuantity(bool increase) {
    setState(() {
      if (increase) {
        quantity += 1;
      } else if (quantity > 1) {
        quantity -= 1;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Hitung berat total berdasarkan quantity
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Menampilkan gambar produk
          Center(
            child: Container(
              width: 50,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0XFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                constraints: const BoxConstraints(
                  maxWidth: 100,
                  maxHeight: 100,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: widget.imagePath.startsWith('http')
                      ? CachedNetworkImage(
                          imageUrl: widget.imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                          memCacheHeight: 200,
                          memCacheWidth: 200,
                          maxWidthDiskCache: 200,
                          maxHeightDiskCache: 200,
                          fadeInDuration: Duration.zero,
                          placeholder: (context, url) =>
                              FutureBuilder<FileInfo?>(
                            future: AppCacheManager().getFileFromCache(url),
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
                                  color: Color(0xFF74B11A),
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
                        )
                      : Image.asset(
                          widget.imagePath,
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.nama,
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
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
                          fontSize: 18,
                          color: Color(0xFF1F2131),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    currencyFormat
                        .format(widget.hargaRp), // hargaRp ditampilkan
                    style: const TextStyle(
                      fontFamily: 'Poppins',
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(
            color: Color(0xFFE6E7E9), // Warna garis
            thickness: 1, // Ketebalan garis
          ),
          const SizedBox(height: 4),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Quantity",
                style: TextStyle(
                  fontFamily: 'Poppins',
                  color: Colors.grey,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              // Kontrol jumlah produk (plus/minus) yang berada di kanan
              Container(
                width: 115,
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    GestureDetector(
                      onTap: () => _updateQuantity(false),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
                        child: const Icon(
                          Icons.remove,
                          size: 16,
                          color: Color(0xFF589400),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          '$quantity',
                          style: const TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _updateQuantity(true),
                      child: Container(
                        margin: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 4,
                              offset: const Offset(0, 1),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(4),
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

          const SizedBox(height: 20),
          // Tombol untuk checkout atau membeli
          ElevatedButton(
            onPressed: () {
              //navigasi ke halaman payment selection
              Navigator.push(
                context,
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) {
                    return PaymentSelection(
                      productItemId: widget.productItemId,
                      nama: widget.nama,
                      hargaRp: widget.hargaRp,
                      hargaPoin: widget.hargaPoin,
                      imagePath: widget.imagePath,
                      jumlah: quantity,
                      berat: baseWeight * quantity,
                      beratNormal: widget.berat,
                      satuan: widget.satuan,
                    );
                  },
                  transitionDuration: Duration.zero,
                  reverseTransitionDuration: Duration.zero,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF589400),
              minimumSize: const Size(double.infinity, 50),
            ),
            child: const Text(
              'Selanjutnya',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
