import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 96,
    this.showBackground = false,
    this.useTransparent = false,
  });

  final double size;
  final bool showBackground;
  final bool useTransparent;

  @override
  Widget build(BuildContext context) {
    final assetPath = useTransparent
        ? 'assets/images/ramars_academy_logo_transparent.png'
        : 'assets/images/ramars_academy_logo.png';

    final image = Image.asset(
      assetPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
    );

    if (!showBackground) {
      return SizedBox(
        width: size,
        height: size,
        child: image,
      );
    }

    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.06),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0B2545).withValues(alpha: 0.10),
            blurRadius: size * 0.2,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: image,
    );
  }
}
