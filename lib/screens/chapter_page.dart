import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/catalog_models.dart';
import '../models/user_access_models.dart';
import '../repositories/catalog_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/skeleton.dart';
import 'topics_page.dart';

class ChapterPage extends StatefulWidget {
  const ChapterPage({
    super.key,
    required this.course,
    required this.classId,
    required this.subjectName,
    this.topicRefs,
  });

  final UserCourse course;
  final String classId;
  final String subjectName;

  /// When provided (topic-linking mode), chapters are derived from these
  /// refs alone — no `/api/chapters` call — and only chapters that
  /// actually have a linked topic are shown. When null (legacy
  /// `CourseSubject` mode), every chapter of [classId] is fetched, same as
  /// before this feature existed.
  final List<CourseTopicRef>? topicRefs;

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {
  final _repository = CatalogRepository(ApiClient());
  late Future<List<ChapterItem>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<ChapterItem>> _load() {
    final topicRefs = widget.topicRefs;
    if (topicRefs != null) {
      final chapters = <ChapterItem>[];
      final seen = <String>{};
      for (final ref in topicRefs) {
        if (seen.add(ref.chapterId)) {
          chapters.add(
            ChapterItem(id: ref.chapterId, name: ref.chapterName, classId: widget.classId),
          );
        }
      }
      return Future.value(chapters);
    }
    return _repository.fetchChapters(widget.classId);
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.subjectName),
      ),
      body: AppBackground(
        child: FutureBuilder<List<ChapterItem>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const VideoListSkeleton();
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Unable to load chapters.';
              return Center(
                child: AppCard(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 44,
                        color: AppColors.error,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: AppTypography.bodyMedium,
                      ),
                      const SizedBox(height: 16),
                      AppPrimaryButton(text: 'Retry', height: 44, onPressed: _retry),
                    ],
                  ),
                ),
              );
            }

            final chapters = (snapshot.data ?? [])
                .where(
                  (chapter) => chapter.name.toLowerCase().contains(
                    _query.trim().toLowerCase(),
                  ),
                )
                .toList();

            return ListView(
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
                              'No chapters found.',
                              style: AppTypography.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...chapters.map((chapter) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AppCard(
                        padding: const EdgeInsets.all(18),
                        onTap: () {
                          final topicRefs = widget.topicRefs
                              ?.where((ref) => ref.chapterId == chapter.id)
                              .toList();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TopicsPage(
                                course: widget.course,
                                chapterId: chapter.id,
                                chapterName: chapter.name,
                                topicIds: topicRefs
                                    ?.map((ref) => ref.topicId)
                                    .toList(),
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
                                chapter.name,
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
            );
          },
        ),
      ),
    );
  }
}
