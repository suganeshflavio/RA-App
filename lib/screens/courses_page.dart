import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_access_models.dart';
import '../state/session_state.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/skeleton.dart';
import 'subject_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionState>();
    final courses = session.courses
        .where(
          (course) => course.courseName.toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Enrolled Courses'),
      ),
      body: AppBackground(
        child: session.isLoadingCourses
            ? const CourseListSkeleton()
            : RefreshIndicator(
                onRefresh: () => context.read<SessionState>().refreshCourses(),
                color: AppColors.primary,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  children: [
                    InlineSearchField(
                      hintText: 'Search your courses...',
                      onChanged: (value) => setState(() => _query = value),
                    ),
                    const SizedBox(height: 18),
                    if (courses.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 40),
                        child: Center(
                          child: AppCard(
                            padding: const EdgeInsets.all(28),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.search_off_rounded,
                                  size: 48,
                                  color: AppColors.textMuted,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  session.errorMessage ?? 'No matching courses found.',
                                  textAlign: TextAlign.center,
                                  style: AppTypography.bodyMedium,
                                ),
                                if (session.errorMessage != null) ...[
                                  const SizedBox(height: 16),
                                  AppPrimaryButton(
                                    text: 'Retry',
                                    height: 44,
                                    onPressed: () =>
                                        context.read<SessionState>().refreshCourses(),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ...courses.map((course) => _CourseCard(course: course)),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final UserCourse course;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SubjectPage(course: course),
            ),
          );
        },
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.primaryDark.withValues(alpha: 0.2)),
              ),
              child: const Icon(
                Icons.menu_book_rounded,
                color: AppColors.primaryDark,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.courseName,
                    style: AppTypography.titleLarge.copyWith(fontSize: 17),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      AppChip(
                        label: '${course.subjects.length} Subjects',
                        backgroundColor: AppColors.surfaceVariant,
                        textColor: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      AppChip(
                        label: '${course.chapterCount} Chapters',
                        backgroundColor: AppColors.primaryLight,
                        textColor: AppColors.primaryDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: AppColors.primaryDark,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
