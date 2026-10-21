import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_background.dart';
import '../widgets/app_logo.dart';
import '../widgets/brand_title.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import 'contact_page.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Banner Card
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 24,
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
                            const AppLogo(size: 60),
                            const SizedBox(height: 12),
                            BrandTitle(
                              style: AppTypography.displayMedium.copyWith(
                                color: Colors.white,
                                fontSize: 22,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Privacy & Data Governance Policy',
                              style: AppTypography.bodyMedium.copyWith(
                                color: Colors.white.withValues(alpha: 0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.verified_user_rounded,
                              color: AppColors.success,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Last Updated: August 2026\nYour privacy and data security are our top priorities.',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Introduction Text
                Text(
                  'At TKS Academy, we believe in complete transparency regarding how your data is handled. This Privacy Policy details what information we collect, why we collect it, where it is stored, and how you can exercise your privacy rights.',
                  style: AppTypography.bodyLarge.copyWith(
                    height: 1.5,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                // Section 1: What We Collect
                const _PolicySectionHeader(
                  icon: Icons.inventory_2_outlined,
                  iconColor: Color(0xFF2563EB),
                  iconBg: Color(0xFFEFF6FF),
                  title: '1. What Information We Collect',
                ),
                const SizedBox(height: 10),
                const AppCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _PolicyItemRow(
                        title: 'Personal Account Information',
                        detail:
                            'Full name, email address, mobile phone number, and account access credentials during registration or profile updates.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Device & Hardware Identifiers',
                        detail:
                            'Device manufacturer, hardware model, operating system version (Android/iOS/Windows/macOS), and unique device identifier used for security authorization.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Academic & Learning Progress',
                        detail:
                            'Enrolled course subscriptions, subject/chapter completions, quiz & mock test responses, scores, video viewing logs, and study material downloads.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Support & Inquiries Data',
                        detail:
                            'Messages, category choices, and contact details submitted through our in-app Contact Us form or customer support channels.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 2: Why We Collect Data
                const _PolicySectionHeader(
                  icon: Icons.psychology_outlined,
                  iconColor: Color(0xFF7C3AED),
                  iconBg: Color(0xFFF5F3FF),
                  title: '2. Why We Collect Your Data',
                ),
                const SizedBox(height: 10),
                const AppCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _PolicyItemRow(
                        title: 'Account Authentication & Security',
                        detail:
                            'To verify student identity, maintain active authenticated login sessions, and prevent unauthorized account access.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Single-Device Session Management',
                        detail:
                            'Device hardware identifiers are processed to enforce single-device session security and protect course content from unauthorized sharing.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Course Delivery & Progress Tracking',
                        detail:
                            'To save your test scores, track video watch progress, render personalized dashboard stats, and deliver course materials smoothly.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Customer Service & Communication',
                        detail:
                            'To respond promptly to student help requests, technical inquiries, and course admission queries.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 3: Where Data Is Stored
                const _PolicySectionHeader(
                  icon: Icons.dns_outlined,
                  iconColor: Color(0xFF059669),
                  iconBg: Color(0xFFECFDF5),
                  title: '3. Where & How Data Is Stored',
                ),
                const SizedBox(height: 10),
                const AppCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    children: [
                      _PolicyItemRow(
                        title: 'Encrypted On-Device Storage',
                        detail:
                            'Your authentication bearer tokens and cached profile details are encrypted locally on your device using hardware-backed Flutter Secure Storage (Android Keystore / iOS Keychain).',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Secured Cloud Servers',
                        detail:
                            'Account details, course access records, test history, and support queries are transmitted over encrypted TLS 1.3 HTTPS connections and stored in TKS Academy’s protected cloud databases.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Sandboxed Application Caches',
                        detail:
                            'Temporary files (such as cached PDF notes or study material previews) are isolated within sandboxed app directories and cleared upon logout or app reset.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 4: Protection & User Rights
                const _PolicySectionHeader(
                  icon: Icons.shield_outlined,
                  iconColor: Color(0xFFEA580C),
                  iconBg: Color(0xFFFFF7ED),
                  title: '4. Data Protection & Your Rights',
                ),
                const SizedBox(height: 10),
                const AppCard(
                  padding: EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _PolicyItemRow(
                        title: 'No Data Sale to Third Parties',
                        detail:
                            'TKS Academy NEVER sells, rents, or trades your personal information to third-party advertising or marketing networks.',
                      ),
                      Divider(height: 20, color: AppColors.cardBorder),
                      _PolicyItemRow(
                        title: 'Access, Correction & Deletion Rights',
                        detail:
                            'You have the right to view your account data anytime via the Profile tab, log out to clear local tokens, or request complete account and data deletion by emailing our support team.',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Section 5: How to Contact Us
                const _PolicySectionHeader(
                  icon: Icons.headset_mic_outlined,
                  iconColor: AppColors.primary,
                  iconBg: AppColors.primaryLight,
                  title: '5. How to Contact Us',
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Have questions about this Privacy Policy or wish to request data deletion? Reach out to us directly:',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _ContactQuickRow(
                        icon: Icons.email_rounded,
                        text: 'support@tksacademy.com / info@tksacademy.com',
                      ),
                      const SizedBox(height: 10),
                      const _ContactQuickRow(
                        icon: Icons.phone_rounded,
                        text: '+91 98765 43210 (Toll Free: +1 800 555 0199)',
                      ),
                      const SizedBox(height: 10),
                      const _ContactQuickRow(
                        icon: Icons.location_on_rounded,
                        text:
                            'TKS Tower, 4th Floor, Knowledge Park, Tech Corridor, Metro City - 600001',
                      ),
                      const SizedBox(height: 20),
                      AppPrimaryButton(
                        text: 'Open Contact Form',
                        icon: Icons.send_rounded,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const ContactPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicySectionHeader extends StatelessWidget {
  const _PolicySectionHeader({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTypography.titleMedium.copyWith(
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PolicyItemRow extends StatelessWidget {
  const _PolicyItemRow({
    required this.title,
    required this.detail,
  });

  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: AppTypography.titleMedium.copyWith(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Text(
            detail,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              height: 1.45,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactQuickRow extends StatelessWidget {
  const _ContactQuickRow({
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 13,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
