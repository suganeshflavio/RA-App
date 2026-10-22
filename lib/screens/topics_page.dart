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
import 'topic_detail_page.dart';

/// One topic filtered down to only the content this student's course grant
/// actually covers.
class _GrantedTopic {
  const _GrantedTopic(this.detail);
  final TopicDetail detail;
}

class TopicsPage extends StatefulWidget {
  const TopicsPage({
    super.key,
    required this.course,
    required this.chapterId,
    required this.chapterName,
    this.topicIds,
  });

  final UserCourse course;
  final String chapterId;
  final String chapterName;

  /// When provided (topic-linking mode — the course has explicit
  /// `CourseTopic` links), only these topic ids are shown, and
  /// [CatalogRepository.fetchTopics] is skipped entirely. When null
  /// (legacy `CourseSubject` mode), every topic of the chapter is fetched
  /// and filtered down to what the student's course grant covers, same as
  /// before this feature existed.
  final List<String>? topicIds;

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  final _repository = CatalogRepository(ApiClient());
  late Future<List<_GrantedTopic>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<_GrantedTopic>> _load() async {
    final topicIds =
        widget.topicIds ??
        (await _repository.fetchTopics(widget.chapterId)).map((t) => t.id).toList();
    final grantedVideoIds = widget.course.grantedVideoIds;
    final grantedNotesIds = widget.course.grantedNotesIds;
    final grantedTestIds = widget.course.grantedTestIds;

    final details = await Future.wait(
      topicIds.map((id) => _repository.fetchTopicById(id)),
    );

    return details
        .map((detail) {
          final videos = detail.videos
              .where((v) => grantedVideoIds.contains(v.id))
              .toList();
          final notes = detail.notes
              .where((n) => grantedNotesIds.contains(n.id))
              .toList();
          final mcqTests = detail.mcqTests
              .where((t) => grantedTestIds.contains(t.id))
              .toList();
          return _GrantedTopic(
            TopicDetail(
              id: detail.id,
              name: detail.name,
              videos: videos,
              notes: notes,
              mcqTests: mcqTests,
            ),
          );
        })
        .where((t) => t.detail.hasAnyContent)
        .toList();
  }

  void _retry() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName),
      ),
      body: AppBackground(
        child: FutureBuilder<List<_GrantedTopic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const VideoListSkeleton();
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Unable to load topics.';
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

            final topics = (snapshot.data ?? [])
                .where(
                  (t) => t.detail.name.toLowerCase().contains(
                    _query.trim().toLowerCase(),
                  ),
                )
                .toList();

            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              children: [
                InlineSearchField(
                  hintText: 'Search topics...',
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 18),
                if (topics.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Center(
                      child: AppCard(
                        padding: const EdgeInsets.all(28),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.video_library_outlined,
                              size: 44,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'No topics available in this chapter yet.',
                              style: AppTypography.bodyMedium,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  )
                else
                  ...topics.map((topic) {
                    final detail = topic.detail;
                    final subtitleParts = <String>[
                      if (detail.videos.isNotEmpty) '${detail.videos.length} video',
                      if (detail.notes.isNotEmpty) '${detail.notes.length} notes',
                      if (detail.mcqTests.isNotEmpty) '${detail.mcqTests.length} MCQ',
                    ];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: AppCard(
                        padding: const EdgeInsets.all(18),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => TopicDetailPage(topic: detail),
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
                                Icons.play_arrow_rounded,
                                color: AppColors.primaryDark,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    detail.name,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.titleMedium,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    subtitleParts.join(' • '),
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
            );
          },
        ),
      ),
    );
  }
}
