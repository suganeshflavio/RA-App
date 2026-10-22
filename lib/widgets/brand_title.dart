import 'package:flutter/material.dart';

class BrandTitle extends StatelessWidget {
  const BrandTitle({super.key, this.style});

  final TextStyle? style;

  static const _smallScreenBreakpoint = 360.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final label = width < _smallScreenBreakpoint ? "Ramar's" : "Ramar's Academy";
    return Text(label, style: style);
  }
}
