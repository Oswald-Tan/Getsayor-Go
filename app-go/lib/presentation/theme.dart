import 'package:flutter/material.dart';

import 'constants.dart';

class AppTheme {
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      // scaffoldBackgroundColor: Colors.white,
      fontFamily: "Poppins",
      appBarTheme: const AppBarTheme(
          elevation: 0,
          scrolledUnderElevation: 0,
          iconTheme: IconThemeData(
            color: Color(0xFF1F2131),
          ),
          titleTextStyle: TextStyle(
            color: Color(0xFF1F2131),
          )),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: kTextColor),
        bodyMedium: TextStyle(color: kTextColor),
        bodySmall: TextStyle(color: kTextColor),
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: kPrimaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
        ),
      ),

      //custom circular progress indicator color
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: Color(0xFF74B11A),
      ),
    );
  }
}

const OutlineInputBorder outlineInputBorder = OutlineInputBorder(
  borderRadius: BorderRadius.all(Radius.circular(58)),
  borderSide: BorderSide(color: Colors.grey),
  gapPadding: 10,
);
