import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/video_lesson.dart';
import '../repositories/video_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/skeleton.dart';
import 'video_player_page.dart';

class VideosPage extends StatefulWidget {
  const VideosPage({
    super.key,
    required this.courseId,
    required this.courseName,
    required this.subjectName,
    required this.chapterName,
  });

  final String courseId;
  final String courseName;
  final String subjectName;
  final String chapterName;

  @override
  State<VideosPage> createState() => _VideosPageState();
}

class _VideosPageState extends State<VideosPage> {
  final _repository = VideoRepository(ApiClient());
  late Future<List<VideoLesson>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<VideoLesson>> _load() async {
    final data = await _repository.fetchVideos(
      courseId: widget.courseId,
      chapter: widget.chapterName,
    );
    final videos = data.videos.where((video) => video.isActive).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return videos;
  }

  void _retry() {
    setState(() => _future = _load());
  }

  void _openVideo(VideoLesson video, {bool autoShowNotes = false}) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoPlayerPage(
          video: video,
          autoShowNotes: autoShowNotes,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.chapterName),
      ),
      body: AppBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InlineSearchField(
                  hintText: 'Search video lessons...',
                  onChanged: (value) => setState(() => _query = value),
                ),
                const SizedBox(height: 18),
                Expanded(
                  child: FutureBuilder<List<VideoLesson>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const VideoListSkeleton();
                      }

                      if (snapshot.hasError) {
                        final message = snapshot.error is ApiException
                            ? (snapshot.error as ApiException).message
                            : 'Unable to load videos';
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
                                AppPrimaryButton(
                                  text: 'Retry',
                                  height: 44,
                                  onPressed: _retry,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final videos = (snapshot.data ?? [])
                          .where(
                            (video) => video.videoName.toLowerCase().contains(
                              _query.trim().toLowerCase(),
                            ),
                          )
                          .toList();

                      if (videos.isEmpty) {
                        return Center(
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
                                  'No video lessons found.',
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final notedVideos = videos
                          .where((video) => video.hasNotes)
                          .toList();

                      return ListView(
                        children: [
                          ...videos.map(
                            (video) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _VideoTile(
                                video: video,
                                onTap: () => _openVideo(video),
                              ),
                            ),
                          ),
                          if (notedVideos.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            Text(
                              'Lesson Notes & Resources',
                              style: AppTypography.titleLarge.copyWith(fontSize: 18),
                            ),
                            const SizedBox(height: 12),
                            ...notedVideos.map(
                              (video) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _NoteTile(
                                  video: video,
                                  onTap: () => _openVideo(video, autoShowNotes: true),
                                ),
                              ),
                            ),
                          ],
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _VideoTile extends StatelessWidget {
  const _VideoTile({required this.video, required this.onTap});

  final VideoLesson video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
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
                  video.videoName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  video.subject,
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
    );
  }
}

class _NoteTile extends StatelessWidget {
  const _NoteTile({required this.video, required this.onTap});

  final VideoLesson video;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  video.displayNotesFileName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  video.videoName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }
}
