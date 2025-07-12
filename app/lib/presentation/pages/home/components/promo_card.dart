import 'package:flutter/material.dart';

class PromoCard extends StatelessWidget {
  const PromoCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none, // Penting agar bagian atas gambar bisa keluar
      children: [
        // Card hijau
        Container(
          height: 180,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF74B11A), // Hijau muda
                Color(0xFF4C7E00), // Hijau tua
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Belanja Hemat\nTanpa Ribet!',
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Bahan dapur lengkap,\nlangsung kirim ke rumahmu.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 110), // ruang untuk gambar
            ],
          ),
        ),

        // Gambar diletakkan tepat di bawah container card
        Positioned(
          right: 24,
          bottom: 16,
          child: Image.asset(
            'assets/images/promo_card.png',
            height: 200,
          ),
        ),
      ],
    );
  }
}
