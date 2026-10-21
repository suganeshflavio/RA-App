import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_access_models.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_card.dart';
import '../widgets/inline_search_field.dart';
import 'chapter_page.dart';

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key, required this.course});

  final UserCourse course;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final subjects = widget.course.subjects
        .where(
          (subject) => subject.subject.toLowerCase().contains(
            _query.trim().toLowerCase(),
          ),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.courseName),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            InlineSearchField(
              hintText: 'Search subjects...',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 18),
            if (subjects.isEmpty)
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
                          size: 44,
                          color: AppColors.textMuted,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No subjects found matching "$_query"',
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...subjects.map((subject) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppCard(
                    padding: const EdgeInsets.all(18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ChapterPage(
                            course: widget.course,
                            subject: subject,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.secondaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.topic_outlined,
                            color: AppColors.secondaryDark,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                subject.subject,
                                style: AppTypography.titleMedium,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${subject.chapters.length} Chapters Available',
                                style: AppTypography.labelSmall,
                              ),
                            ],
                          ),
                        ),
                        const Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.textMuted,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }
}
