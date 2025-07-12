import 'package:flutter/material.dart';
import 'package:getsayor/presentation/pages/init_screen.dart';
import 'package:getsayor/presentation/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class OrderConfirmationCartPage extends StatelessWidget {
  final List<String> namaProduk;
  final List<int> jumlah;
  final List<int> berat;
  final List<String> hargaProduk;
  final List<String> satuan;
  final String ongkir;
  final String totalHarga;
  final String totalBayar;
  final String invoiceNumber;
  final String orderDate;

  const OrderConfirmationCartPage({
    required this.namaProduk,
    required this.jumlah,
    required this.berat,
    required this.hargaProduk,
    required this.satuan,
    required this.ongkir,
    required this.totalHarga,
    required this.totalBayar,
    required this.invoiceNumber,
    required this.orderDate,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    bool isRupiahFormat(String text) {
      return text.contains('Rp');
    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    const Text(
                      "Pengantaran produk dimulai setiap hari pukul 05.00 pagi untuk memastikan pesanan tiba cepat dan tepat waktu.",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 14,
                        color: Colors.grey,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    // Wrap Card List inside Column
                    Column(
                      children: [
                        // Invoice Card
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("No Invoice",
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14)),
                                    Text(invoiceNumber,
                                        style: const TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                // User name from Provider
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Nama",
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                        )),
                                    Consumer<UserProvider>(
                                      builder: (context, userProvider, child) {
                                        final fullname =
                                            userProvider.fullname ?? 'User';
                                        return Text(
                                          fullname,
                                          style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 14),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Tanggal",
                                        style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontSize: 14)),
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
                                // List Produk
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      ...namaProduk
                                          .asMap()
                                          .entries
                                          .map((entry) {
                                        int index = entry.key;
                                        String productName = entry.value;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      productName,
                                                      style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  isRupiahFormat(
                                                          hargaProduk[index])
                                                      ? Row(
                                                          children: [
                                                            Text(
                                                              'x${jumlah[index]}',
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            ),
                                                            const SizedBox(
                                                                width: 30),
                                                            Text(
                                                              '${hargaProduk[index]}',
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            )
                                                          ],
                                                        )
                                                      : Row(
                                                          children: [
                                                            Text(
                                                                'x${jumlah[index]} ',
                                                                style:
                                                                    const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                )),
                                                            const SizedBox(
                                                                width: 30),
                                                            Image.asset(
                                                              width: 14,
                                                              'assets/images/poin.png',
                                                            ),
                                                            const SizedBox(
                                                                width: 5),
                                                            Text(
                                                              numberFormat.format(
                                                                  int.parse(
                                                                      hargaProduk[
                                                                          index])),
                                                              style: const TextStyle(
                                                                  fontFamily:
                                                                      'Poppins',
                                                                  fontSize: 14,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600),
                                                            )
                                                          ],
                                                        ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  const Text(
                                                    'Total Berat',
                                                    style: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 14),
                                                  ),
                                                  Text(
                                                    '${berat[index]} ${satuan[index]}',
                                                    style: const TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontSize: 14),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        );
                                      }),
                                      const SizedBox(height: 4),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
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
                                          isRupiahFormat(totalHarga)
                                              ? Text(
                                                  totalHarga,
                                                  style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600),
                                                )
                                              : Row(
                                                  children: [
                                                    Image.asset(
                                                      width: 14,
                                                      'assets/images/poin.png',
                                                    ),
                                                    const SizedBox(width: 5),
                                                    Text(
                                                      numberFormat.format(
                                                          int.parse(
                                                              totalHarga)),
                                                      style: const TextStyle(
                                                          fontFamily: 'Poppins',
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    )
                                                  ],
                                                ),
                                        ],
                                      ),
                                    ],
                                  ),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      "Ongkos Kirim",
                                      style: TextStyle(
                                          fontFamily: 'Poppins', fontSize: 14),
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
                                                numberFormat
                                                    .format(int.parse(ongkir)),
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                    isRupiahFormat(totalBayar)
                                        ? Text(
                                            totalBayar,
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
                                                numberFormat.format(
                                                    int.parse(totalBayar)),
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
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Tombol Tetap di Bawah
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ElevatedButton(
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
                  fontSize: 14,
                ),
              ),
            ),
          ),
        ],
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
