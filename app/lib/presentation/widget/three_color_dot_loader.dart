import 'package:flutter/material.dart';
import 'dart:math';

class ThreeColorDotLoader extends StatefulWidget {
  final double size;

  const ThreeColorDotLoader({super.key, this.size = 80.0});

  @override
  ThreeColorDotLoaderState createState() => ThreeColorDotLoaderState();
}

class ThreeColorDotLoaderState extends State<ThreeColorDotLoader>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<Color> _colors = [
    Colors.red,
    Colors.purple,
    Colors.orange,
  ];
  final double _radius = 25.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: List.generate(3, (index) {
                final angle = 2 * pi * _controller.value + (index * 2 * pi / 3);
                final scale = 0.5 + (sin(angle + pi / 2).abs() * 0.5);

                return Transform.translate(
                  offset: Offset(
                    _radius * cos(angle),
                    _radius * sin(angle),
                  ),
                  child: Transform.scale(
                    scale: scale,
                    child: Dot(
                      color: _colors[index],
                      size: widget.size * 0.25,
                    ),
                  ),
                );
              }),
            );
          },
        ),
      ),
    );
  }
}

class Dot extends StatelessWidget {
  final Color color;
  final double size;

  const Dot({
    super.key,
    required this.color,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 8,
            spreadRadius: 2,
          )
        ],
      ),
    );
  }
}
