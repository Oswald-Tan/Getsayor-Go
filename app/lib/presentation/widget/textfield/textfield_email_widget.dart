import 'package:flutter/material.dart';

class TextfieldEmailWidget extends StatefulWidget {
  const TextfieldEmailWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TextfieldEmailWidget> createState() => _TextfieldEmailWidgetState();
}

class _TextfieldEmailWidgetState extends State<TextfieldEmailWidget> {
  final _emailValidator = RegExp(
    r'^[\w-]+(\.[\w-]+)*@[\w-]+(\.[\w-]+)*(\.[a-zA-Z]{2,})$',
  );

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
            } else if (!_emailValidator.hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            // hintText: 'Enter your email',
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
            labelText: 'Email',
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.alternate_email,
                color: Colors.grey[400],
                size: 18,
              ),
            ), // Tambahkan baris ini
          ),
        ),
      ],
    );
  }
}
