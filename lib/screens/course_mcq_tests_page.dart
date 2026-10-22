import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_access_models.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_card.dart';
import 'quiz_page.dart';

class CourseMcqTestsPage extends StatelessWidget {
  const CourseMcqTestsPage({super.key, required this.course});

  final UserCourse course;

  @override
  Widget build(BuildContext context) {
    final tests = course.mcqTests;

    return Scaffold(
      appBar: AppBar(title: Text(course.courseName)),
      body: AppBackground(
        child: tests.isEmpty
            ? Center(
                child: AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.quiz_outlined,
                        size: 44,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No MCQ tests available yet.',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                itemCount: tests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = tests[index];
                  return AppCard(
                    padding: const EdgeInsets.all(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => QuizPage(
                          testId: item.testId,
                          title: item.testName,
                        ),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.quiz_rounded,
                            color: AppColors.primaryDark,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(item.testName, style: AppTypography.titleMedium),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textMuted,
                          size: 16,
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
