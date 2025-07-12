import 'package:flutter/material.dart';

class TextfieldPhoneNumberWidget extends StatefulWidget {
  const TextfieldPhoneNumberWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  TextfieldPhoneNumberWidgetState createState() =>
      TextfieldPhoneNumberWidgetState();
}

class TextfieldPhoneNumberWidgetState
    extends State<TextfieldPhoneNumberWidget> {
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
              return null; // No error message when the field is empty
            }
            // Add phone number validation logic if needed
            return null;
          },
          keyboardType: TextInputType.phone, // Set keyboard type to phone
          decoration: InputDecoration(
            // hintText: 'Enter your phone number',
            // hintStyle: TextStyle(fontFamily: 'Poppins',color: Colors.grey, fontSize: 14),
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
            labelText: 'Phone Number',
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.phone,
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
