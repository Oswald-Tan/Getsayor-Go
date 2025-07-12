import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerProdukCard extends StatelessWidget {
  const ShimmerProdukCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!, // ✅ Warna lebih gelap
        highlightColor: Colors.grey[100]!, // ✅ Warna lebih terang
        period: const Duration(
            milliseconds: 1500), // ✅ Tambahkan durasi animasi (opsional)
        child: Container(
          width: 200,
          height: 275,
          decoration: BoxDecoration(
            color: Colors.grey[300]!, // ✅ Kontras lebih baik
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 140,
                color: Colors.grey[300]!, // ✅ Placeholder gambar
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.all(3.0),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300]!, // ✅ Kontras untuk info produk
                    borderRadius: const BorderRadius.all(Radius.circular(20)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.white, // ✅ Placeholder teks
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 60,
                        height: 16,
                        color: Colors.white, // ✅ Placeholder teks
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 80,
                            height: 12,
                            color: Colors.white, // ✅ Placeholder teks
                          ),
                          Container(
                            width: 40,
                            height: 16,
                            color: Colors.white, // ✅ Placeholder teks
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
