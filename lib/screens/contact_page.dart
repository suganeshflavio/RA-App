import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/custom_text_field.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  String _selectedCategory = 'General Inquiry';
  bool _isSubmitting = false;

  final List<String> _categories = [
    'General Inquiry',
    'Course Admission',
    'Technical Support',
    // 'Payment & Subscription',
    'Feedback & Suggestions',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    // Simulate API network latency for realistic submission behavior
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    // Clear form inputs
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();

    // Show success dialog
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: const [
            Icon(Icons.check_circle_rounded, color: AppColors.success, size: 28),
            SizedBox(width: 10),
            Text('Message Sent!'),
          ],
        ),
        content: const Text(
          'Thank you for reaching out to TKS Academy. Our support team will review your message and respond within 24 hours.',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Contact Us'),
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
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryLight,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.headset_mic_rounded,
                          size: 36,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'We are Here to Help!',
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Have questions about courses, admissions, or technical issues? Get in touch with us.',
                              style: AppTypography.bodyMedium.copyWith(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Contact Details Grid
                Text(
                  'Reach Out Directly',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                const _ContactDetailCard(
                  icon: Icons.email_rounded,
                  iconBg: Color(0xFFEFF6FF),
                  iconColor: Color(0xFF2563EB),
                  title: 'Email Support',
                  primaryDetail: 'support@tksacademy.com',
                  secondaryDetail: 'info@tksacademy.com',
                ),
                const SizedBox(height: 10),
                const _ContactDetailCard(
                  icon: Icons.phone_in_talk_rounded,
                  iconBg: Color(0xFFECFDF5),
                  iconColor: Color(0xFF059669),
                  title: 'Phone & WhatsApp',
                  primaryDetail: '+91 98765 43210',
                  secondaryDetail: '+1 (800) 555-0199 (Toll Free)',
                ),
                const SizedBox(height: 10),
                const _ContactDetailCard(
                  icon: Icons.location_on_rounded,
                  iconBg: Color(0xFFFFF7ED),
                  iconColor: Color(0xFFEA580C),
                  title: 'Campus / Main Office',
                  primaryDetail: 'TKS Tower, 4th Floor, Knowledge Park',
                  secondaryDetail: 'Tech Corridor, Metro City - 600001',
                ),
                // const SizedBox(height: 10),
                // const _ContactDetailCard(
                //   icon: Icons.access_time_filled_rounded,
                //   iconBg: Color(0xFFF5F3FF),
                //   iconColor: Color(0xFF7C3AED),
                //   title: 'Working Hours',
                //   primaryDetail: 'Mon - Sat: 9:00 AM - 7:00 PM IST',
                //   secondaryDetail: 'Sun: Closed (Email Support Active)',
                // ),
                const SizedBox(height: 24),

                // Contact Form Card
                Text(
                  'Send Us a Message',
                  style: AppTypography.titleLarge,
                ),
                const SizedBox(height: 12),
                AppCard(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppTextField(
                          controller: _nameController,
                          labelText: 'Your Name',
                          hintText: 'Enter your full name',
                          prefixIcon: Icons.person_outline_rounded,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your name';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _emailController,
                          labelText: 'Email Address',
                          hintText: 'name@example.com',
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your email';
                            }
                            if (!val.contains('@') || !val.contains('.')) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Topic Dropdown
                        Text(
                          'Category',
                          style: AppTypography.labelLarge.copyWith(
                            fontSize: 14,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedCategory,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.category_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                          ),
                          items: _categories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category,
                              child: Text(
                                category,
                                style: AppTypography.bodyLarge.copyWith(
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) {
                              setState(() => _selectedCategory = val);
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        AppTextField(
                          controller: _messageController,
                          labelText: 'Message',
                          hintText: 'Type your message or query here...',
                          prefixIcon: Icons.edit_note_rounded,
                          maxLines: 4,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Please enter your message';
                            }
                            if (val.trim().length < 10) {
                              return 'Message must be at least 10 characters long';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),

                        AppPrimaryButton(
                          text: 'Submit Message',
                          icon: Icons.send_rounded,
                          isLoading: _isSubmitting,
                          onPressed: _handleSubmit,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Frequently Asked Questions
                // Text(
                //   'Frequently Asked Questions',
                //   style: AppTypography.titleLarge,
                // ),
                // const SizedBox(height: 12),
                // AppCard(
                //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //   child: Column(
                //     children: const [
                //       _FaqTile(
                //         question: 'How long does it take to get a response?',
                //         answer:
                //             'Our support team typically responds within 2 to 4 business hours for technical issues, and within 24 hours for general inquiries.',
                //       ),
                //       Divider(height: 1, color: AppColors.cardBorder),
                //       _FaqTile(
                //         question: 'How do I request course access or refund?',
                //         answer:
                //             'You can reach out directly via the "Course Admission" or "Payment & Subscription" category in the form above with your purchase receipt.',
                //       ),
                //       Divider(height: 1, color: AppColors.cardBorder),
                //       _FaqTile(
                //         question: 'Can I access study notes on iOS & Web?',
                //         answer:
                //             'Yes! All notes, videos, and test series seamlessly sync across Android, iOS, and Web browsers.',
                //       ),
                //     ],
                //   ),
                // ),
                // const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ContactDetailCard extends StatelessWidget {
  const _ContactDetailCard({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.primaryDetail,
    required this.secondaryDetail,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String primaryDetail;
  final String secondaryDetail;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  primaryDetail,
                  style: AppTypography.titleMedium.copyWith(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  secondaryDetail,
                  style: AppTypography.bodyMedium.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

