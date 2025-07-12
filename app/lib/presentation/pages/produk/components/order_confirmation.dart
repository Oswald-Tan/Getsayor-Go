import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/init_screen.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class OrderConfirmationPage extends StatelessWidget {
  final String namaProduk;
  final String jumlah;
  final int beratNormal;
  final String satuan;
  final String hargaProduk;
  final String ongkir;
  final String totalBayar;
  final String totalBayarSemua;
  final String invoiceNumber;
  final String orderDate;

  const OrderConfirmationPage(
      {required this.namaProduk,
      required this.jumlah,
      required this.beratNormal,
      required this.satuan,
      required this.hargaProduk,
      required this.ongkir,
      required this.totalBayar,
      required this.totalBayarSemua,
      required this.invoiceNumber,
      required this.orderDate,
      super.key});

  @override
  Widget build(BuildContext context) {
    bool isRupiahFormat(String text) {
      return text.contains('Rp');
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              SvgPicture.asset(
                'assets/images/success.svg',
                width: 140,
                height: 140,
              ),
              const SizedBox(height: 20),
              const Text(
                "Order Successfully!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 20,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              const Column(
                children: [
                  Text(
                    "Pengantaran produk dimulai setiap hari pukul 05.00 pagi untuk memastikan pesanan tiba cepat dan tepat waktu.",
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 14,
                      color: Colors.grey,
                      fontWeight: FontWeight.w400,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFe9e8e8)),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Invoice",
                        style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "No Invoice",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            invoiceNumber,
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Nama",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                            ),
                          ),
                          Consumer<UserProvider>(
                            builder: (context, userProvider, child) {
                              final fullname = userProvider.fullname ?? 'User';
                              return Text(
                                fullname,
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Tanggal",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            _formatOrderDate(
                                orderDate), // Gunakan fungsi formatter
                            style: const TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Divider(
                        color: Color(0xFFe9e8e8),
                        thickness: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nama Produk
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$namaProduk ($beratNormal $satuan)',
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                ),
                                isRupiahFormat(hargaProduk)
                                    ? Row(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                'x$jumlah',
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                              const SizedBox(width: 30),
                                              Text(
                                                hargaProduk,
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      )
                                    : Row(
                                        children: [
                                          Text(
                                            'x$jumlah',
                                            style: const TextStyle(
                                                fontFamily: 'Poppins',
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600),
                                          ),
                                          const SizedBox(width: 30),
                                          Row(
                                            children: [
                                              Image.asset(
                                                width: 14,
                                                'assets/images/poin.png',
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                numberFormat.format(
                                                    int.parse(hargaProduk)),
                                                style: const TextStyle(
                                                    fontFamily: 'Poppins',
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            // Total Berat
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Total Berat',
                                    style: TextStyle(
                                        fontFamily: 'Poppins', fontSize: 14),
                                  ),
                                ),
                                Text(
                                  '${int.parse(jumlah) * beratNormal} $satuan',
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'Total Harga Produk',
                              style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600),
                            ),
                          ),
                          isRupiahFormat(totalBayar)
                              ? Text(
                                  totalBayar,
                                  style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600),
                                )
                              : Row(
                                  children: [
                                    Image.asset(
                                      width: 14,
                                      'assets/images/poin.png',
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      numberFormat
                                          .format(int.parse(totalBayar)),
                                      style: const TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600),
                                    )
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 0,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: const BorderSide(color: Color(0xFFe9e8e8)),
                ),
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Ongkos Kirim",
                            style:
                                TextStyle(fontFamily: 'Poppins', fontSize: 14),
                          ),
                          isRupiahFormat(ongkir)
                              ? Text(
                                  ongkir,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontSize: 14,
                                  ),
                                )
                              : Row(
                                  children: [
                                    Image.asset(
                                      width: 14,
                                      'assets/images/poin.png',
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      numberFormat.format(int.parse(ongkir)),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontSize: 14,
                                      ),
                                    )
                                  ],
                                ),
                        ],
                      ),
                      const Divider(
                        color: Color(0xFFe9e8e8),
                        thickness: 1,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Total",
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF589400),
                            ),
                          ),
                          isRupiahFormat(totalBayarSemua)
                              ? Text(
                                  totalBayarSemua,
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF589400),
                                  ),
                                )
                              : Row(
                                  children: [
                                    Image.asset(
                                      width: 16,
                                      'assets/images/poin.png',
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      numberFormat
                                          .format(int.parse(totalBayarSemua)),
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Color(0xFF589400),
                                      ),
                                    )
                                  ],
                                ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          const InitScreen(),
                      transitionDuration: Duration.zero,
                      reverseTransitionDuration: Duration.zero,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF589400),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
                child: const Text(
                  'Back to home',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatOrderDate(String dateString) {
    try {
      final date = DateTime.parse(dateString).toLocal();
      return DateFormat('d MMMM, yyyy - hh:mm a').format(date);
    } catch (e) {
      return "Invalid date";
    }
  }
}
