import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/user_access_models.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_card.dart';
import 'notes_pdf_page.dart';

class CourseNotesPage extends StatelessWidget {
  const CourseNotesPage({super.key, required this.course});

  final UserCourse course;

  @override
  Widget build(BuildContext context) {
    final notes = course.notes;

    return Scaffold(
      appBar: AppBar(title: Text(course.courseName)),
      body: AppBackground(
        child: notes.isEmpty
            ? Center(
                child: AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.menu_book_outlined,
                        size: 44,
                        color: AppColors.textMuted,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'No notes available yet.',
                        style: AppTypography.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                itemCount: notes.length,
                separatorBuilder: (_, _) => const SizedBox(height: 14),
                itemBuilder: (context, index) {
                  final item = notes[index];
                  return AppCard(
                    padding: const EdgeInsets.all(18),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotesPdfPage(
                          notesId: item.notesId,
                          title: item.title,
                        ),
                      ),
                    ),
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
                            Icons.description_outlined,
                            color: AppColors.secondaryDark,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(item.title, style: AppTypography.titleMedium),
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
