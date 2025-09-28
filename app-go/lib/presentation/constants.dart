import 'package:flutter/material.dart';

const kPrimaryColor = Color(0xFF74B11A);
const kPrimaryLightColor = Color(0XFFF5F5F5);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF74B11A), Color(0xFFABCF51)],
);
const kSecondaryColor = Color(0xFF979797);
const kTextColor = Colors.black;

const kAnimationDuration = Duration(milliseconds: 200);

const headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Colors.black,
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

// final otpInputDecoration = InputDecoration(
//   contentPadding: const EdgeInsets.symmetric(vertical: 16),
//   border: outlineInputBorder(),
//   focusedBorder: outlineInputBorder(),
//   enabledBorder: outlineInputBorder(),
// );

// OutlineInputBorder outlineInputBorder() {
//   return OutlineInputBorder(
//     borderRadius: BorderRadius.circular(16),
//     borderSide: const BorderSide(color: kTextColor),
//   );
// }
