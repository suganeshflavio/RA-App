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
import 'course_mcq_tests_page.dart';
import 'course_notes_page.dart';
import 'subject_page.dart';

class CoursesPage extends StatefulWidget {
  const CoursesPage({super.key});

  @override
  State<CoursesPage> createState() => _CoursesPageState();
}

class _CoursesPageState extends State<CoursesPage> {
  String _query = '';

  void _openCourse(UserCourse course) {
    switch (course.category) {
      case CourseCategory.notes:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CourseNotesPage(course: course)),
        );
      case CourseCategory.test:
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CourseMcqTestsPage(course: course),
          ),
        );
      case CourseCategory.video:
      case CourseCategory.mixed:
      case CourseCategory.empty:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => SubjectPage(course: course)),
        );
    }
  }

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
                      ...courses.map(
                        (course) => _CourseCard(
                          course: course,
                          onTap: () => _openCourse(course),
                        ),
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

class _CourseCategoryStyle {
  const _CourseCategoryStyle({
    required this.icon,
    required this.label,
    required this.background,
    required this.foreground,
  });

  final IconData icon;
  final String label;
  final Color background;
  final Color foreground;
}

_CourseCategoryStyle _styleFor(CourseCategory category) {
  switch (category) {
    case CourseCategory.video:
      return const _CourseCategoryStyle(
        icon: Icons.menu_book_rounded,
        label: 'Course',
        background: AppColors.primaryLight,
        foreground: AppColors.primaryDark,
      );
    case CourseCategory.notes:
      return const _CourseCategoryStyle(
        icon: Icons.menu_book_outlined,
        label: 'Notes (eBook)',
        background: AppColors.secondaryLight,
        foreground: AppColors.secondaryDark,
      );
    case CourseCategory.test:
      return const _CourseCategoryStyle(
        icon: Icons.quiz_rounded,
        label: 'MCQ Test',
        background: AppColors.primaryLight,
        foreground: AppColors.primaryDark,
      );
    case CourseCategory.mixed:
      return const _CourseCategoryStyle(
        icon: Icons.dashboard_customize_rounded,
        label: 'Notes & MCQ',
        background: AppColors.secondaryLight,
        foreground: AppColors.secondaryDark,
      );
    case CourseCategory.empty:
      return const _CourseCategoryStyle(
        icon: Icons.hourglass_empty_rounded,
        label: 'No content yet',
        background: AppColors.surfaceVariant,
        foreground: AppColors.textMuted,
      );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course, required this.onTap});

  final UserCourse course;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _styleFor(course.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        onTap: onTap,
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: style.background,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: style.foreground.withValues(alpha: 0.2)),
              ),
              child: Icon(style.icon, color: style.foreground, size: 26),
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
                  AppChip(
                    label: style.label,
                    backgroundColor: style.background,
                    textColor: style.foreground,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: style.foreground,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}
