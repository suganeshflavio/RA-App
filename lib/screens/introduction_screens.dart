import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/intro_page.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/intro_page_widget.dart';
import 'login_page.dart';

class IntroductionScreens extends StatefulWidget {
  const IntroductionScreens({super.key});

  @override
  State<IntroductionScreens> createState() => _IntroductionScreensState();
}

class _IntroductionScreensState extends State<IntroductionScreens> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 0;

  final List<IntroPage> _introPages = const [
    IntroPage(
      title: 'Welcome to TKS Academy',
      description: 'Learn from industry experts with structured video courses & study resources.',
      icon: Icons.rocket_launch_rounded,
      color: AppColors.primary,
    ),
    IntroPage(
      title: 'Learn Anytime & Anywhere',
      description: 'Access video lessons, notes, and tests at your convenience.',
      icon: Icons.schedule_rounded,
      color: AppColors.secondary,
    ),
    IntroPage(
      title: 'Master New Skills',
      description: 'Test your knowledge with instant MCQ assessments and track progress.',
      icon: Icons.trending_up_rounded,
      color: AppColors.primaryDark,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted) return;
      final nextPage = (_currentPage + 1) % _introPages.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _finish() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        useHeroGradient: true,
        child: SafeArea(
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _introPages.length,
                itemBuilder: (context, index) =>
                    IntroPageWidget(page: _introPages[index], isDark: false),
              ),
              Positioned(
                top: 16,
                right: 20,
                child: TextButton(
                  onPressed: _finish,
                  child: Text(
                    'Skip',
                    style: AppTypography.labelLarge.copyWith(
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                left: 24,
                right: 24,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(
                        _introPages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: _currentPage == index ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? AppColors.primary
                                : AppColors.cardBorder,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 130,
                      child: AppPrimaryButton(
                        text: _currentPage == _introPages.length - 1
                            ? 'Get Started'
                            : 'Next',
                        height: 48,
                        icon: Icons.arrow_forward_rounded,
                        onPressed: () {
                          if (_currentPage == _introPages.length - 1) {
                            _finish();
                          } else {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
