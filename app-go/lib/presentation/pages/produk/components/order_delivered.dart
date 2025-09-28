import 'package:flutter/material.dart';
import 'package:getsayor/core/api/config.dart';
import 'package:getsayor/data/model/pesanan_model.dart';
import 'package:getsayor/data/services/pesanan_service.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

String formatTanggal(String isoDate) {
  DateTime dateTime = DateTime.parse(isoDate).toLocal();
  return DateFormat('dd MMM yyyy').format(dateTime);
}

final numberFormat = NumberFormat("#,##0", "id_ID");

final currencyFormat =
    NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0);

String formatRupiah(int value) {
  return currencyFormat.format(value).replaceAll('Rp', 'Rp. ');
}

class OrderDeliveredPage extends StatefulWidget {
  final int userId;
  static String routeName = "/order-delivered";

  const OrderDeliveredPage({super.key, required this.userId});

  @override
  OrderDeliveredPageState createState() => OrderDeliveredPageState();
}

class OrderDeliveredPageState extends State<OrderDeliveredPage> {
  final PesananService _pesananService = PesananService();
  late Future<List<PesananModel>> _pesananFuture;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _refreshData() async {
    setState(() {
      _pesananFuture =
          _pesananService.getPesananByUserDelivered(context, widget.userId);
    });
  }

  void _fetchData() {
    _pesananFuture =
        _pesananService.getPesananByUserDelivered(context, widget.userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          'Complete Order',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.w600,
            color: Color(0xFF1F2131),
            fontSize: 16,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF0F1F5),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: const Color(0xFF74B11A),
        backgroundColor: Colors.white,
        child: FutureBuilder<List<PesananModel>>(
          future: _pesananFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildShimmerLoader();
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                  child: Text(
                'Belum ada pesanan complete',
                style: TextStyle(fontFamily: 'Poppins', color: Colors.grey),
              ));
            }

            return ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final pesanan = snapshot.data![index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Your Order',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "#${pesanan.orderId}",
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: pesanan.items.map((item) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        color: const Color(0xFFF0F1F5),
                                      ),
                                      child: Image.network(
                                        '$baseUrlStatic/${item.image}',
                                        height: 40,
                                        width: 40,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Image.asset(
                                            'assets/images/placeholder.png',
                                            height: 40,
                                            width: 40,
                                            fit: BoxFit.cover,
                                          );
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.namaProduk,
                                            style: const TextStyle(
                                              fontFamily: 'Poppins',
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  if (pesanan.hargaRp == null)
                                                    Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              right: 5),
                                                      child: Image.asset(
                                                        'assets/images/poin_cs.png',
                                                        height: 14,
                                                        width: 14,
                                                      ),
                                                    ),
                                                  Text(
                                                    pesanan.hargaRp != null
                                                        ? formatRupiah(
                                                            item.harga)
                                                        : '${item.harga} Poin',
                                                    style: const TextStyle(
                                                      fontFamily: 'Poppins',
                                                      color: Colors.grey,
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Text(
                                                '${item.jumlah} ${item.satuan.toLowerCase() == 'kilogram' ? 'kg' : item.satuan.toLowerCase() == 'gram' ? 'gr' : item.satuan}',
                                                style: const TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 5),
                          const Divider(
                            color: Color(0xFFF0F1F5),
                            thickness: 1,
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: pesanan.status == 'pending'
                                      ? Colors.orange
                                      : pesanan.status == 'confirmed'
                                          ? const Color(0xFF74B11A)
                                          : pesanan.status == 'processed'
                                              ? Colors.blue
                                              : pesanan.status ==
                                                      'out-for-delivery'
                                                  ? Colors.purple
                                                  : pesanan.status ==
                                                          'delivered'
                                                      ? Colors.teal
                                                      : pesanan.status ==
                                                              'cancelled'
                                                          ? Colors.grey
                                                          : Colors.red,
                                ),
                                child: Text(
                                  pesanan.status == 'out-for-delivery'
                                      ? 'Out for Delivery'
                                      : pesanan.status[0].toUpperCase() +
                                          pesanan.status.substring(1),
                                  style: const TextStyle(
                                    fontFamily: 'Poppins',
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: pesanan.paymentStatus == 'unpaid'
                                        ? Colors.orange.shade700
                                        : pesanan.paymentStatus == 'paid'
                                            ? const Color(0xFF74B11A)
                                            : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  pesanan.paymentStatus[0].toUpperCase() +
                                      pesanan.paymentStatus
                                          .substring(1)
                                          .toLowerCase(),
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: pesanan.paymentStatus == 'unpaid'
                                        ? Colors.orange.shade700
                                        : pesanan.paymentStatus == 'paid'
                                            ? const Color(0xFF74B11A)
                                            : Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 4, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: Colors.white,
                                  border: Border.all(
                                    color: pesanan.metodePembayaran == 'COD'
                                        ? const Color(0xFFFF0FC3)
                                        : pesanan.metodePembayaran == 'Poin'
                                            ? const Color(0xFF591AB1)
                                            : Colors.red,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  pesanan.metodePembayaran,
                                  style: TextStyle(
                                    fontFamily: 'Poppins',
                                    color: pesanan.metodePembayaran == 'COD'
                                        ? const Color(0xFFFF0FC3)
                                        : pesanan.metodePembayaran == 'Poin'
                                            ? const Color(0xFF591AB1)
                                            : Colors.red,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Row(
                                children: [
                                  if (pesanan.hargaRp == null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 5),
                                      child: Image.asset(
                                        'assets/images/poin_cs.png',
                                        height: 14,
                                        width: 14,
                                      ),
                                    ),
                                  Text(
                                    pesanan.hargaRp != null
                                        ? formatRupiah(pesanan.hargaRp!)
                                        : '${pesanan.hargaPoin} Poin',
                                    style: const TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

Widget _buildShimmerLoader() {
  return ListView.builder(
    padding: const EdgeInsets.all(20),
    itemCount: 3, // Number of shimmer items
    itemBuilder: (context, index) {
      return Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: 80,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: List.generate(2, (index) => _buildShimmerItem()),
                  ),
                  const SizedBox(height: 5),
                  const Divider(
                    color: Color(0xFFF0F1F5),
                    thickness: 1,
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        width: 80,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        width: 60,
                        height: 20,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 50,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      Container(
                        width: 100,
                        height: 16,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget _buildShimmerItem() {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: Colors.grey[300],
          ),
          child: Container(
            height: 10,
            width: 10,
            color: Colors.grey[300],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                height: 16,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(height: 5),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 80,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  Container(
                    width: 60,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
