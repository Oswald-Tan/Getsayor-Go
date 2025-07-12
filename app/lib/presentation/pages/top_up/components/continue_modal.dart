import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ContinueModal extends StatelessWidget {
  final int? selectedAmount;
  final ValueNotifier<int> conversionRateNotifier;

  const ContinueModal({
    super.key,
    required this.selectedAmount,
    required this.conversionRateNotifier,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Top Up',
                  style: TextStyle(
                    fontFamily: 'Poppins',
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 207, 207, 207),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Poin:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF3E2961),
                          ),
                        ),
                        Row(
                          children: [
                            Image.asset(
                              'assets/images/poin_cs.png',
                              width: 15,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '$selectedAmount',
                              style: const TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Total Rupiah:',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            color: Color(0xFF1F2131),
                          ),
                        ),
                        ValueListenableBuilder<int>(
                          valueListenable: conversionRateNotifier,
                          builder: (context, currentRate, child) {
                            int updatedTotalRupiah =
                                selectedAmount! * currentRate;

                            String formattedTotalRupiah =
                                'Rp. ${updatedTotalRupiah.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match match) => '${match[1]},')}';

                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      formattedTotalRupiah,
                                      style: const TextStyle(
                                        fontFamily: 'Poppins',
                                        color: Color(0xFF1F2131),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 5),
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
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 207, 207, 207),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nomor Telephone',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF1F2131),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Text(
                      'Silahkan menghubungi nomor Admin di bawah ini untuk verifikasi pembayaran agar Poin Anda segera di kirim.',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: Row(
                        children: [
                          Image.asset(
                            'assets/images/whatsup.png',
                            width: 20,
                          ),
                          const SizedBox(
                            width: 5,
                            height: 5,
                          ),
                          const Text(
                            '0821-5492-6917',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 50),
            ElevatedButton(
              onPressed: () async {
                int currentRate = conversionRateNotifier.value;

                int updatedTotalRupiah = selectedAmount! * currentRate;
                String formattedTotalRupiah = NumberFormat.currency(
                  locale: 'id_ID',
                  symbol: 'Rp.',
                ).format(updatedTotalRupiah);

                bool? confirm = await _showConfirmationDialog(
                  context,
                  formattedTotalRupiah,
                );

                if (confirm != null && confirm) {
                  // Handle confirmation action here
                  // No Firebase actions are being taken
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF74B11A),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(
    BuildContext context,
    String formattedTotalRupiah,
  ) async {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Text(
            'Konfirmasi',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              color: Color(0xFF1F2131),
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            'Anda yakin ingin memproses Top Up?',
            style: TextStyle(
                fontFamily: 'Poppins', color: Color(0xFF1F2131)),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // Cancel
              },
              child: const Text(
                'Tidak',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2131)),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm
              },
              child: const Text(
                'Ya',
                style: TextStyle(
                    fontFamily: 'Poppins',
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2131)),
              ),
            ),
          ],
        );
      },
    );
  }
}
