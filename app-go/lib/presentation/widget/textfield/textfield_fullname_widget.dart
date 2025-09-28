import 'package:flutter/material.dart';

class TextfieldFullnameWidget extends StatefulWidget {
  const TextfieldFullnameWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TextfieldFullnameWidget> createState() =>
      _TextfieldFullnameWidgetState();
}

class _TextfieldFullnameWidgetState extends State<TextfieldFullnameWidget> {
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
            } else if (value.length < 4) {
              return 'Fullname must be at least 4 characters long';
            }
            return null;
          },
          decoration: InputDecoration(
            // hintText: 'Enter your username',
            // hintStyle: TextStyle(fontFamily: 'Poppins',color: Colors.grey, fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.never,
            suffixIcon: Padding(
              padding: const EdgeInsets.only(right: 15),
              child: Icon(
                Icons.person,
                color: Colors.grey[400],
                size: 18,
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
            labelText: 'Fullname',
            labelStyle: const TextStyle(
                fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
