import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

final numberFormat = NumberFormat("#,##0", "id_ID");

class PointsSelection extends StatelessWidget {
  final List<Map<String, dynamic>> pointsOptions;
  final int selectedPoints;
  final void Function(int, int) onSelectPoints;

  const PointsSelection({
    super.key,
    required this.pointsOptions,
    required this.selectedPoints,
    required this.onSelectPoints,
  });

  @override
  Widget build(BuildContext context) {
    // Membuat instance NumberFormat untuk format "Rp 1.000"
    final numberFormat = NumberFormat("#,##0", "id_ID");

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.8,
      ),
      itemCount: pointsOptions.length,
      itemBuilder: (context, index) {
        final points = pointsOptions[index]['points'];
        final price = pointsOptions[index]['price'];
        final discountPercentage = pointsOptions[index]['discountPercentage'];
        final originalPrice = pointsOptions[index]['originalPrice'];

        return GestureDetector(
          onTap: () {
            if (selectedPoints == points) {
              // jika poin yang sama di klik, reset selection
              onSelectPoints(0, 0); // nilai default untuk unselect
            } else {
              onSelectPoints(points, price);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: selectedPoints == points
                  ? const Color(0xFFC3C3C3)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Image.asset(
                        'assets/images/poin.png',
                        width: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        numberFormat.format(points),
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: selectedPoints == points
                              ? Colors.white
                              : const Color(0xFF1F2131),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Rp. ${numberFormat.format(price)}',
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selectedPoints == points
                              ? Colors.white
                              : const Color(0xFF74B11A),
                        ),
                      ),
                      // Menampilkan originalPrice jika ada diskon
                      if (discountPercentage != null &&
                          discountPercentage > 0 &&
                          originalPrice != null)
                        Text(
                          'Rp. ${numberFormat.format(originalPrice)}', // Tampilkan harga asli
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: selectedPoints == points
                                ? Colors.white
                                : Colors.grey, // Warna untuk harga asli
                            decoration: TextDecoration
                                .lineThrough, // Garis strikethrough
                          ),
                        ),

                      const Spacer(),
                      // Menambahkan teks "Diskon" jika discountPercentage > 0
                      if (discountPercentage != null && discountPercentage > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.discount,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Diskon $discountPercentage%',
                                style: const TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
