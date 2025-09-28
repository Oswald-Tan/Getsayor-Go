import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: LoadingAnimationWidget.stretchedDots(
            color: const Color(0xFF74B11A),
            size: 80,
          ),
        ));
  }
}
