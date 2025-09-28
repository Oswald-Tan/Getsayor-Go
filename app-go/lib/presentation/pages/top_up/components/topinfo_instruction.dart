import 'package:flutter/material.dart';

class TopUpInfoInstruction extends StatelessWidget {
  const TopUpInfoInstruction({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Color(0xFF1F2131),
                size: 16,
              ),
              SizedBox(width: 5),
              Text(
                'Minimum top up amount: 100',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF1F2131),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Container(
            margin: const EdgeInsets.only(left: 21),
            child: const Text.rich(
              TextSpan(
                text:
                    'Sekarang, pilih jumlah poin yang ingin Anda top up. Setelah itu, klik tombol ',
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 12,
                  color: Color(0xFF1F2131),
                ),
                children: [
                  TextSpan(
                    text: 'Proses',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      fontSize: 12,
                      color: Color(0xFF1F2131),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  TextSpan(
                    text: ' untuk melanjutkan proses top up.',
                    style: TextStyle(
                      fontFamily: 'Poppins',
                      color: Color(0xFF1F2131),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
