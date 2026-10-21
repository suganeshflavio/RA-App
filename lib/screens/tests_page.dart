import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/dashboard_content.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';

class TestsPage extends StatelessWidget {
  const TestsPage({super.key, required this.tests});

  final List<TestItem> tests;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessments & Tests'),
      ),
      body: AppBackground(
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          itemCount: tests.length,
          separatorBuilder: (_, _) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final item = tests[index];
            final isAvailable = item.status == 'Available';

            return AppCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          style: AppTypography.titleLarge.copyWith(fontSize: 18),
                        ),
                      ),
                      AppChip(
                        label: item.status,
                        backgroundColor: isAvailable
                            ? const Color(0xFFD1FAE5)
                            : AppColors.primaryLight,
                        textColor: isAvailable
                            ? AppColors.success
                            : AppColors.primaryDark,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    item.subject,
                    style: AppTypography.titleMedium.copyWith(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${item.questionCount} questions • ${item.duration}',
                    style: AppTypography.labelSmall,
                  ),
                  const SizedBox(height: 16),
                  AppPrimaryButton(
                    text: isAvailable ? 'Start Test' : 'Set Reminder',
                    icon: isAvailable
                        ? Icons.play_arrow_rounded
                        : Icons.notifications_active_outlined,
                    onPressed: () {},
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
