import 'package:flutter/material.dart';

class TextfieldReferralCodeWidget extends StatefulWidget {
  const TextfieldReferralCodeWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  TextfieldReferralCodeWidgetState createState() =>
      TextfieldReferralCodeWidgetState();
}

class TextfieldReferralCodeWidgetState
    extends State<TextfieldReferralCodeWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: (value) {
            if (value == null || value.isEmpty) {
              // Tidak ada validasi jika kosong (opsional)
              return null;
            }

            // Validasi panjang kode referral
            if (value.length != 12) {
              return 'Referral code must be 12 characters long.';
            }

            // Validasi format kode referral (hanya huruf, angka dan karakter)
            // final regex = RegExp(r'^[a-zA-Z0-9]+$');
            // if (!regex.hasMatch(value)) {
            //   return 'Referral code can only contain letters and numbers.';
            // }

            return null; // Validasi berhasil
          },
          keyboardType: TextInputType.text, // Ubah ke text karena referral code
          decoration: InputDecoration(
            floatingLabelBehavior: FloatingLabelBehavior.never,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFEDF0F1), width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFFEDF0F1), width: 1),
            ),
            contentPadding:
                const EdgeInsets.only(left: 20, top: 18, bottom: 18),
            labelText: 'Referral Code (Optional)',
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.card_giftcard,
                color: Colors.grey[400],
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
