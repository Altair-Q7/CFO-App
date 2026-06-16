import 'package:flutter/material.dart';

class MadiLogo extends StatelessWidget {
  final double size;
  final BoxFit fit;

  const MadiLogo({super.key, this.size = 40, this.fit = BoxFit.contain});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(size * 0.25),
      child: Image.asset(
        'assets/images/logo.png',
        width: size,
        height: size,
        fit: fit,
      ),
    );
  }
}
