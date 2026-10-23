import 'dart:async';

import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Content and colours for one promo banner on the home screen.
class PromoBannerData {
  const PromoBannerData({
    required this.badge,
    required this.badgeIcon,
    required this.title,
    required this.subtitle,
    required this.points,
    required this.gradient,
    required this.badgeColor,
    required this.badgeTextColor,
    required this.accentColor,
    this.logoAsset = 'assets/images/ramars_academy_logo.png',
  });

  final String badge;
  final IconData badgeIcon;
  final String title;
  final String subtitle;
  final List<String> points;
  final List<Color> gradient;
  final Color badgeColor;
  final Color badgeTextColor;
  // subtitle text and the ring around the logo
  final Color accentColor;
  final String logoAsset;
}

// Phones get a stacked layout (logo beside the heading, points full width
// underneath); wider screens get the side-by-side layout. Each is laid out
// at a fixed design size and scaled to the available width, so text grows
// and shrinks with the screen and nothing overflows or gets cut off.
const double _wideBreakpoint = 520;
const Size _compactDesignSize = Size(340, 196);
const Size _wideDesignSize = Size(720, 288);

class BannerCarousel extends StatefulWidget {
  const BannerCarousel({super.key, required this.banners});

  final List<PromoBannerData> banners;

  @override
  State<BannerCarousel> createState() => _BannerCarouselState();
}

class _BannerCarouselState extends State<BannerCarousel> {
  final _pageController = PageController();
  Timer? _autoPlayTimer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.banners.length > 1) {
      _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
        if (!mounted) return;
        final next = (_currentPage + 1) % widget.banners.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth >= _wideBreakpoint;
            final designSize = isWide ? _wideDesignSize : _compactDesignSize;

            return AspectRatio(
              aspectRatio: designSize.width / designSize.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: widget.banners.length,
                    onPageChanged: (index) =>
                        setState(() => _currentPage = index),
                    itemBuilder: (context, index) => _PromoBanner(
                      data: widget.banners[index],
                      isWide: isWide,
                      designSize: designSize,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        if (widget.banners.length > 1) ...[
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(widget.banners.length, (index) {
              final isActive = index == _currentPage;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: isActive ? 20 : 7,
                height: 7,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : AppColors.cardBorder,
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ],
      ],
    );
  }
}

class _PromoBanner extends StatelessWidget {
  const _PromoBanner({
    required this.data,
    required this.isWide,
    required this.designSize,
  });

  final PromoBannerData data;
  final bool isWide;
  final Size designSize;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: data.gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: FittedBox(
        fit: BoxFit.contain,
        // the whole banner already scales with the screen, so don't let the
        // system font size enlarge text past the design box
        child: MediaQuery.withNoTextScaling(
          child: SizedBox.fromSize(
            size: designSize,
            child: Stack(
              children: [
                ..._decorations(),
                Padding(
                  padding: isWide
                      ? const EdgeInsets.symmetric(horizontal: 32, vertical: 28)
                      : const EdgeInsets.all(16),
                  child: isWide ? _wideLayout() : _compactLayout(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _decorations() {
    final ring = Border.all(color: data.accentColor.withValues(alpha: 0.18));
    final size = designSize.height * 1.4;

    return [
      Positioned(
        right: -size * 0.3,
        top: -size * 0.35,
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(shape: BoxShape.circle, border: ring),
        ),
      ),
      Positioned(
        left: designSize.width * 0.08,
        bottom: -size * 0.55,
        child: Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
          ),
        ),
      ),
    ];
  }

  Widget _compactLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(data: data, fontSize: 10.5),
                  const SizedBox(height: 8),
                  _Title(text: data.title, fontSize: 21),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: data.accentColor,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w700,
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            _Logo(data: data, size: 84),
          ],
        ),
        const Spacer(),
        _Points(points: data.points, fontSize: 11.5, spacing: 4),
      ],
    );
  }

  Widget _wideLayout() {
    return Row(
      children: [
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Badge(data: data, fontSize: 13),
              const SizedBox(height: 14),
              _Title(text: data.title, fontSize: 34),
              const SizedBox(height: 6),
              Text(
                data.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: data.accentColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),
              _Points(points: data.points, fontSize: 14, spacing: 6),
            ],
          ),
        ),
        const SizedBox(width: 24),
        _Logo(data: data, size: 200),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.data, required this.fontSize});

  final PromoBannerData data;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: fontSize * 0.9,
        vertical: fontSize * 0.35,
      ),
      decoration: BoxDecoration(
        color: data.badgeColor,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.badgeIcon, size: fontSize * 1.2, color: data.badgeTextColor),
          SizedBox(width: fontSize * 0.4),
          Text(
            data.badge,
            style: TextStyle(
              color: data.badgeTextColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _Title extends StatelessWidget {
  const _Title({required this.text, required this.fontSize});

  final String text;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    // one line, shrunk if a long title wouldn't fit
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Text(
        text,
        maxLines: 1,
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w900,
          height: 1.1,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

class _Points extends StatelessWidget {
  const _Points({
    required this.points,
    required this.fontSize,
    required this.spacing,
  });

  final List<String> points;
  final double fontSize;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final point in points)
          Padding(
            padding: EdgeInsets.only(bottom: spacing),
            child: Row(
              children: [
                Container(
                  width: fontSize * 0.38,
                  height: fontSize * 0.38,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.7),
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: fontSize * 0.55),
                Expanded(
                  child: Text(
                    point,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: fontSize,
                      height: 1.25,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.data, required this.size});

  final PromoBannerData data;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.05),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(size * 0.14),
        border: Border.all(color: data.accentColor, width: size * 0.025),
      ),
      child: Image.asset(data.logoAsset, fit: BoxFit.contain),
    );
  }
}
