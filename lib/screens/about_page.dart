import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/brand_title.dart';
import '../widgets/custom_card.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About Us'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hero Banner & Taglines
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 28,
                          horizontal: 20,
                        ),
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        child: Column(
                          children: [
                            const AppLogo(size: 72),
                            const SizedBox(height: 14),
                            BrandTitle(
                              style: AppTypography.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Learn • Practice • Improve • Excel',
                                textAlign: TextAlign.center,
                                style: AppTypography.labelLarge.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Your Dream. Our Guidance. Your Success.',
                              textAlign: TextAlign.center,
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontStyle: FontStyle.italic,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          'TKS Academy is a premier educational platform dedicated to conceptual clarity, competitive exam excellence, and empowering students to achieve their academic goals.',
                          textAlign: TextAlign.center,
                          style: AppTypography.bodyLarge.copyWith(
                            height: 1.5,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Mission & Vision
                Text(
                  'Mission & Vision',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                const _MissionVisionSection(),
                const SizedBox(height: 24),

                // Why Choose Us
                Text(
                  'Why Choose TKS Academy?',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                const _WhyChooseUsSection(),
                const SizedBox(height: 24),

                // Founder / Academic Director Profile
                Text(
                  'About Our Founder',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                const _FounderSection(),
                const SizedBox(height: 24),

                // Strengths
                Text(
                  'Our Key Strengths',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                const _StrengthsSection(),
                const SizedBox(height: 24),

                // Founder's Vision Quote Card
                const _VisionQuoteCard(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MissionVisionSection extends StatelessWidget {
  const _MissionVisionSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PurposeHeader(
            icon: Icons.rocket_launch_rounded,
            iconColor: AppColors.primary,
            title: 'MISSION',
          ),
          const SizedBox(height: 12),
          const _BulletPoint(
            text:
                'To provide quality education with clear concepts and expert guidance.',
          ),
          const _BulletPoint(
            text:
                'To empower every student to learn, practice, improve, and achieve success.',
          ),
          const _BulletPoint(
            text:
                'To make learning accessible and engaging through modern technology and digital education.',
          ),
          const _BulletPoint(
            text:
                'To nurture confidence, discipline, and a passion for continuous learning.',
          ),
          const Divider(height: 32, color: AppColors.cardBorder),
          _PurposeHeader(
            icon: Icons.visibility_rounded,
            iconColor: AppColors.secondary,
            title: 'VISION',
          ),
          const SizedBox(height: 12),
          const _BulletPoint(
            text:
                'To become a trusted educational platform for students across different academic levels and competitive examinations.',
          ),
          const _BulletPoint(
            text:
                'To inspire academic excellence and help every learner achieve their highest potential.',
          ),
          const _BulletPoint(
            text:
                'To build confident, skilled, and future-ready students through knowledge and innovation.',
          ),
          const _BulletPoint(
            text:
                'To create a brighter future by transforming students’ dreams into meaningful achievements.',
          ),
        ],
      ),
    );
  }
}

class _PurposeHeader extends StatelessWidget {
  const _PurposeHeader({
    required this.icon,
    required this.iconColor,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 22),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}

class _BulletPoint extends StatelessWidget {
  const _BulletPoint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 6, right: 10),
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: AppTypography.bodyMedium.copyWith(
                height: 1.45,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WhyChooseUsSection extends StatelessWidget {
  const _WhyChooseUsSection();

  static const List<Map<String, dynamic>> _reasons = [
    {
      'icon': Icons.school_rounded,
      'title': 'Expert Faculty Guidance',
      'subtitle': 'Learn from experienced and dedicated educators.',
      'color': Color(0xFFF97316),
    },
    {
      'icon': Icons.psychology_rounded,
      'title': 'Strong Conceptual Clarity',
      'subtitle': 'Understand concepts deeply instead of memorising.',
      'color': Color(0xFF6366F1),
    },
    {
      'icon': Icons.track_changes_rounded,
      'title': 'NEET & JEE Focused Preparation',
      'subtitle': 'Structured coaching designed for competitive success.',
      'color': Color(0xFF10B981),
    },
    {
      'icon': Icons.menu_book_rounded,
      'title': 'Complete Study Support',
      'subtitle':
          'Quality notes, study materials, worksheets, and practice resources.',
      'color': Color(0xFF3B82F6),
    },
    {
      'icon': Icons.quiz_rounded,
      'title': 'Regular Tests & Assessments',
      'subtitle': 'Track your preparation and improve continuously.',
      'color': Color(0xFFF59E0B),
    },
    {
      'icon': Icons.history_edu_rounded,
      'title': 'Previous Year Question Discussion',
      'subtitle': 'Learn exam patterns and master important questions.',
      'color': Color(0xFF8B5CF6),
    },
    {
      'icon': Icons.help_outline_rounded,
      'title': 'Doubt-Clearing Support',
      'subtitle': 'Get the guidance you need whenever you face difficulties.',
      'color': Color(0xFFEC4899),
    },
    {
      'icon': Icons.devices_rounded,
      'title': 'Smart Digital Learning',
      'subtitle': 'Learn anytime, anywhere through the TKS Academy App.',
      'color': Color(0xFF06B6D4),
    },
    {
      'icon': Icons.insights_rounded,
      'title': 'Personalised Performance Guidance',
      'subtitle':
          'Identify strengths, improve weaknesses, and progress with confidence.',
      'color': Color(0xFF84CC16),
    },
    {
      'icon': Icons.emoji_events_rounded,
      'title': 'Success-Oriented Learning Environment',
      'subtitle':
          'Build knowledge, discipline, confidence, and the mindset to excel.',
      'color': Color(0xFFEAB308),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: List.generate(_reasons.length, (index) {
          final item = _reasons[index];
          final isLast = index == _reasons.length - 1;
          return Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: (item['color'] as Color).withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      item['icon'] as IconData,
                      color: item['color'] as Color,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item['title'] as String,
                          style: AppTypography.titleMedium.copyWith(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          item['subtitle'] as String,
                          style: AppTypography.bodyMedium.copyWith(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (!isLast) const SizedBox(height: 16),
            ],
          );
        }),
      ),
    );
  }
}

class _FounderSection extends StatelessWidget {
  const _FounderSection();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'P. Tharani, M.Sc., M.Phil.',
                      style: AppTypography.titleMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'FOUNDER & ACADEMIC DIRECTOR',
                        style: AppTypography.labelSmall.copyWith(
                          color: AppColors.primaryDark,
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Chemistry Educator | NEET & JEE Competitive Exam Trainer',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 28, color: AppColors.cardBorder),
          _BioParagraph(
            text:
                'I am P. Tharani, M.Sc., M.Phil. in Chemistry, with a strong academic foundation and over 17 years of teaching experience.',
          ),
          const SizedBox(height: 10),
          _BioParagraph(
            text:
                'For the past 10+ years, I have been passionately training students in CBSE, NEET, and JEE Chemistry, with a strong focus on conceptual clarity, problem-solving skills, and competitive-exam excellence.',
          ),
          const SizedBox(height: 10),
          _BioParagraph(
            text:
                'Over the years, my students have achieved excellent scores in competitive examinations and have successfully secured admissions into reputed Medical and Engineering institutions, turning their academic dreams into reality.',
          ),
          const SizedBox(height: 10),
          _BioParagraph(
            text:
                'My students have also demonstrated their excellence in Olympiad examinations, including achieving Bronze Medal honours at the competitive level.',
          ),
        ],
      ),
    );
  }
}

class _BioParagraph extends StatelessWidget {
  const _BioParagraph({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 4, right: 8),
          child: Icon(
            Icons.check_circle_rounded,
            size: 16,
            color: AppColors.primary,
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              height: 1.5,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _StrengthsSection extends StatelessWidget {
  const _StrengthsSection();

  static const List<String> _strengths = [
    'Strong Expertise in Chemistry',
    'Concept-Based & Result-Oriented Teaching',
    'Competitive Examination Specialist',
    'Olympiad Training & Achievement',
    'Proven Student Success & Academic Results',
    'Medical & Engineering College Placements',
    'Student-Centred Learning Approach',
    'Strong Focus on Conceptual Clarity & Problem Solving',
  ];

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(_strengths.length, (index) {
          final text = _strengths[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star_rounded,
                    color: AppColors.primary,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _VisionQuoteCard extends StatelessWidget {
  const _VisionQuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primarySubtle,
            AppColors.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.cardBorderFocus.withValues(alpha: 0.5),
        ),
        boxShadow: AppColors.softShadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.format_quote_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              const SizedBox(width: 6),
              Text(
                'FOUNDER\'S VISION',
                style: AppTypography.titleMedium.copyWith(
                  color: AppColors.primaryDark,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '"To transform every student\'s potential into performance and every dream into achievement through quality education, strong concepts, expert guidance, and continuous motivation."',
            textAlign: TextAlign.center,
            style: AppTypography.bodyLarge.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.5,
              fontWeight: FontWeight.w500,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'TKS Academy — Where Concepts Become Confidence, and Confidence Becomes Success.',
              textAlign: TextAlign.center,
              style: AppTypography.labelLarge.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

