import 'package:flutter/material.dart';

class TextfieldEmailWidget extends StatefulWidget {
  const TextfieldEmailWidget({super.key, required this.controller});

  final TextEditingController controller;

  @override
  State<TextfieldEmailWidget> createState() => _TextfieldEmailWidgetState();
}

class _TextfieldEmailWidgetState extends State<TextfieldEmailWidget> {
  final _emailValidator = RegExp(
    r'^[\w-]+(\.[\w-]+)*@([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}$',
  );

  // Daftar domain email yang umum dan valid
  final List<String> _commonDomains = [
    'gmail.com',
    'yahoo.com',
    'hotmail.com',
    'outlook.com',
    'icloud.com',
    'aol.com',
    'protonmail.com',
    'yandex.com',
    'mail.com',
    'zoho.com',
    'gmail.co.id',
    'yahoo.co.id',
    'rocketmail.com',
    'live.com',
    'msn.com',
  ];

  // Daftar typo yang umum untuk domain populer
  // Daftar typo yang umum untuk domain populer
  final Map<String, List<String>> _commonTypos = {
    'gmail.com': [
      'gmai.com',
      'gmal.com',
      'gmial.com',
      'gmail.con',
      'gmail.cm',
      'gmil.com',
      'gnail.com',
      'gmaill.com', // double l
      'gmaik.com', // k ganti l
      'gmali.com', // i dan l ketukar
      'gmail.co', // kurang m
      'gmail.cmo', // huruf terbalik
      'gemail.com', // extra e
      'gmaul.com', // u typo dari i
    ],
    'yahoo.com': [
      'yaho.com',
      'yahooo.com',
      'yahoo.con',
      'yahu.com',
      'yahoo.cm',
      'yaho.co', // kurang m
      'yahho.com', // double h
      'yaoo.com', // hilang h
      'yahol.com', // l salah dari o
      'yahoom.com', // double m
      'yaho.cmo', // huruf terbalik
    ],
    'hotmail.com': [
      'hotmal.com',
      'hotmai.com',
      'hotmail.con',
      'hotmail.cm',
      'hotnail.com', // n ganti m
      'hotmaill.com', // double l
      'hotmil.com', // hilang a
      'hormail.com', // r ganti t
      'hoymail.com', // y salah ketik
      'hotmail.co', // kurang m
    ],
    'outlook.com': [
      'outlok.com',
      'outlook.con',
      'outlook.cm',
      'outook.com',
      'outllok.com', // double l
      'outllook.com', // double l + double o
      'oulook.com', // hilang t
      'ootlook.com', // double o
      'outllk.com', // typo parah
      'outlook.co', // kurang m
    ],
  };

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // No error message when the field is empty
    }

    // Validasi format email dasar
    if (!_emailValidator.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    // Ekstrak domain dari email
    final parts = value.split('@');
    if (parts.length != 2) return 'Invalid email format';

    final domain = parts[1].toLowerCase();

    // Cek jika domain termasuk dalam common domains
    if (_commonDomains.contains(domain)) {
      return null; // Domain valid
    }

    // Cek typo untuk domain populer
    for (final commonDomain in _commonTypos.keys) {
      if (_commonTypos[commonDomain]!.contains(domain)) {
        return 'Did you mean "$commonDomain"? Common typo detected.';
      }
    }

    // Validasi untuk domain khusus Indonesia
    if (domain.endsWith('.co.id')) {
      final mainPart = domain.replaceAll('.co.id', '');
      if (mainPart.isNotEmpty) {
        return null; // Domain .co.id dianggap valid
      }
    }

    // Validasi untuk domain umum (2-6 karakter)
    final domainRegex =
        RegExp(r'^[a-zA-Z0-9-]+\.([a-zA-Z]{2,6}|[a-zA-Z]{2}\.[a-zA-Z]{2})$');
    if (domainRegex.hasMatch(domain)) {
      return null; // Domain format umum dianggap valid
    }

    // Jika domain tidak dikenali, beri warning (bukan error)
    return 'Uncommon email domain. Please double-check for typos.';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: widget.controller,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: _validateEmail,
          keyboardType: TextInputType.emailAddress,
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
            ),
          ),
        ),
      ],
    );
  }
}
