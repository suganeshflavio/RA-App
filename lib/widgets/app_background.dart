import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({
    super.key,
    required this.child,
    this.useHeroGradient = false,
  });

  final Widget child;
  final bool useHeroGradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        gradient: useHeroGradient ? AppColors.heroGradient : null,
      ),
      child: child,
    );
  }
}
