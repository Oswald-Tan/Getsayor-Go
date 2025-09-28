import 'package:flutter/material.dart';

class TextfieldConfirmPasswordWidget extends StatefulWidget {
  const TextfieldConfirmPasswordWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TextfieldConfirmPasswordWidget> createState() =>
      _TextfieldConfirmPasswordWidgetState();
}

class _TextfieldConfirmPasswordWidgetState
    extends State<TextfieldConfirmPasswordWidget> {
  bool obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          obscureText: obscureText,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return null; // No error message when the field is empty
            } else if (value.length < 6) {
              return 'Password must be at least 6 characters long';
            }
            return null;
          },
          decoration: InputDecoration(
            // hintText: 'Enter your password',
            // hintStyle: TextStyle(fontFamily: 'Poppins',color: Colors.grey, fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            suffixIcon: InkWell(
              onTap: () {
                setState(() {
                  obscureText = !obscureText;
                });
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15),
                child: Icon(
                  obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.grey[400],
                  size: 18,
                ),
              ),
            ),
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
            labelText: 'Confirm Password',
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
          ),
        )
      ],
    );
  }
}
