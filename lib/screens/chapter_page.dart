import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_access_models.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_card.dart';
import '../widgets/inline_search_field.dart';
import 'videos_page.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({super.key, required this.course, required this.subject});

  final UserCourse course;
  final UserSubject subject;

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final chapters = widget.subject.chapters
        .where(
          (chapter) =>
              chapter.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subject.subject),
      ),
      body: AppBackground(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            InlineSearchField(
              hintText: 'Search chapters...',
              onChanged: (value) => setState(() => _query = value),
            ),
            const SizedBox(height: 18),
            if (chapters.isEmpty)
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
                          'No chapters found matching "$_query"',
                          style: AppTypography.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...chapters.map((chapterName) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: AppCard(
                    padding: const EdgeInsets.all(18),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => VideosPage(
                            courseId: widget.course.courseId,
                            courseName: widget.course.courseName,
                            subjectName: widget.subject.subject,
                            chapterName: chapterName,
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
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.play_circle_fill_rounded,
                            color: AppColors.primaryDark,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            chapterName,
                            style: AppTypography.titleMedium,
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
