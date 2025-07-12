import 'package:flutter/material.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});
  static String routeName = "/empty_page";

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: Container(
            child: const Text("Push Notification"),
          ),
        ),
      ),
    );
  }
}
