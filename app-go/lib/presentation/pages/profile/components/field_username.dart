import 'package:flutter/material.dart';

class UsernameField extends StatelessWidget {
  final TextEditingController controller;
  final String? currentUsername;
  final ValueChanged<String>? onChanged;

  const UsernameField({
    required this.controller,
    this.currentUsername,
    this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        TextFormField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Enter New Username',
            hintStyle: const TextStyle(
                fontFamily: 'Poppins', color: Colors.grey, fontSize: 14),
            floatingLabelBehavior: FloatingLabelBehavior.always,
            filled: true,
            fillColor: const Color(0xFFF0F1F5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Color(0xFF9FF421)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(20),
              borderSide: const BorderSide(color: Colors.grey),
            ),
            contentPadding:
                const EdgeInsets.only(left: 28.0, top: 17, bottom: 17),
            labelText: 'Username',
            labelStyle: const TextStyle(fontFamily: 'Poppins', color: Colors.grey),
            prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
            suffixIcon: currentUsername != null && currentUsername!.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.grey),
                    onPressed: () {
                      controller.clear();
                    },
                  )
                : null,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            } else if (value.length < 4) {
              return 'Username must be at least 4 characters long';
            }
            return null;
          },
        ),
        // Display error message if validation fails
        if (controller.text.isNotEmpty && controller.text.length < 4)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Text(
              'Username must be at least 4 characters long',
              style: TextStyle(
                  fontFamily: 'Poppins', color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }
}
