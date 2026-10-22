import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/catalog_models.dart';
import '../models/notes_item.dart';
import '../models/video_lesson.dart';
import '../repositories/notes_repository.dart';
import '../repositories/video_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/comments_section.dart';
import '../widgets/custom_card.dart';
import '../widgets/media_video_player.dart';
import '../widgets/notes_viewer.dart';
import 'notes_pdf_page.dart';
import 'quiz_page.dart';

class TopicDetailPage extends StatefulWidget {
  const TopicDetailPage({super.key, required this.topic});

  final TopicDetail topic;

  @override
  State<TopicDetailPage> createState() => _TopicDetailPageState();
}

class _TopicDetailPageState extends State<TopicDetailPage> {
  final _videoRepository = VideoRepository(ApiClient());
  final _notesRepository = NotesRepository(ApiClient());

  TopicContentRef? _selectedVideo;
  Future<VideoLesson>? _videoFuture;

  TopicContentRef? _openedNote;
  Future<NotesItem>? _noteFuture;

  @override
  void initState() {
    super.initState();
    if (widget.topic.videos.isNotEmpty) {
      _selectVideo(widget.topic.videos.first);
    }
  }

  void _selectVideo(TopicContentRef ref) {
    setState(() {
      _selectedVideo = ref;
      _videoFuture = _videoRepository.fetchVideoById(ref.id);
    });
  }

  void _openNote(TopicContentRef ref) {
    setState(() {
      _openedNote = ref;
      _noteFuture = _notesRepository.fetchNotesById(ref.id);
    });
  }

  void _closeNote() {
    setState(() {
      _openedNote = null;
      _noteFuture = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final topic = widget.topic;
    final hasVideos = topic.videos.isNotEmpty;

    return PopScope(
      canPop: _openedNote == null,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop && _openedNote != null) {
          _closeNote();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(topic.name),
          actions: [
            if (_openedNote != null)
              IconButton(
                tooltip: 'Close Notes',
                icon: const Icon(Icons.close_rounded),
                onPressed: _closeNote,
              ),
          ],
        ),
        body: AppBackground(
          child: hasVideos
              ? _buildVideoLayout(topic)
              : _buildNoVideoLayout(topic),
        ),
      ),
    );
  }

  Widget _buildVideoLayout(TopicDetail topic) {
    return Column(
      children: [
        // 1. Pinned Video Player at the top
        if (_videoFuture != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
            child: FutureBuilder<VideoLesson>(
              future: _videoFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Center(
                      child: CircularProgressIndicator(color: AppColors.primary),
                    ),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Unable to load this video.';
                  return AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Text(message, style: AppTypography.bodyMedium),
                    ),
                  );
                }
                final video = snapshot.data!;
                return ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: MediaVideoPlayer(videoUrl: video.videoUrl),
                );
              },
            ),
          ),

        // 2. Area below the video
        Expanded(
          child: _openedNote != null
              ? _buildInlineNoteView(_openedNote!)
              : FutureBuilder<VideoLesson>(
                  future: _videoFuture,
                  builder: (context, snapshot) {
                    final video = snapshot.data;
                    return _buildNormalContentList(topic, video);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildInlineNoteView(TopicContentRef noteRef) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primarySubtle,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.description_outlined,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    noteRef.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.titleMedium.copyWith(fontSize: 14),
                  ),
                ),
                Tooltip(
                  message: 'Open Fullscreen',
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.fullscreen_rounded,
                      color: AppColors.primaryDark,
                      size: 22,
                    ),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => NotesPdfPage(
                          notesId: noteRef.id,
                          title: noteRef.name,
                        ),
                      ),
                    ),
                  ),
                ),
                Tooltip(
                  message: 'Close Notes',
                  child: IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: const Icon(
                      Icons.close_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: _closeNote,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: FutureBuilder<NotesItem>(
              future: _noteFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  );
                }
                if (snapshot.hasError || snapshot.data == null) {
                  final message = snapshot.error is ApiException
                      ? (snapshot.error as ApiException).message
                      : 'Unable to load these notes.';
                  return AppCard(
                    padding: const EdgeInsets.all(20),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.error_outline_rounded,
                            color: AppColors.error,
                            size: 36,
                          ),
                          const SizedBox(height: 10),
                          Text(message, style: AppTypography.bodyMedium),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => _openNote(noteRef),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return NotesViewer(notesUrl: snapshot.data!.notesUrl);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNormalContentList(TopicDetail topic, VideoLesson? video) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
      children: [
        // Video title and description
        if (video != null) ...[
          Text(video.videoName, style: AppTypography.titleLarge),
          if (video.description.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(video.description, style: AppTypography.bodyMedium),
          ],
          const SizedBox(height: 16),
        ],

        // Lessons list (if multiple videos)
        if (topic.videos.length > 1) ...[
          Text('Lessons', style: AppTypography.titleMedium),
          const SizedBox(height: 8),
          ...topic.videos.map(
            (ref) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _ContentTile(
                icon: Icons.play_arrow_rounded,
                iconBackground: AppColors.primaryLight,
                iconColor: AppColors.primaryDark,
                title: ref.name,
                selected: ref.id == _selectedVideo?.id,
                onTap: () {
                  if (_openedNote != null) _closeNote();
                  _selectVideo(ref);
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Swapped 1: NOTES (shown before MCQ and Comments)
        if (topic.notes.isNotEmpty) ...[
          Row(
            children: [
              Text('Notes', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
              const SizedBox(width: 8),
              Text(
                'Tap to view below video',
                style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...topic.notes.map(
            (ref) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContentTile(
                icon: Icons.description_outlined,
                iconBackground: AppColors.secondaryLight,
                iconColor: AppColors.secondaryDark,
                title: ref.name,
                trailingIcon: Icons.menu_book_rounded,
                onTap: () => _openNote(ref),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Swapped 2: MCQ TESTS (shown before Comments)
        if (topic.mcqTests.isNotEmpty) ...[
          Text('MCQ Tests', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ...topic.mcqTests.map(
            (ref) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContentTile(
                icon: Icons.quiz_outlined,
                iconBackground: AppColors.primaryLight,
                iconColor: AppColors.primaryDark,
                title: ref.name,
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizPage(testId: ref.id, title: ref.name),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        // Swapped 3: DISCUSSION & COMMENTS (swapped to the bottom)
        if (video != null) ...[
          Text(
            'Discussion & Comments',
            style: AppTypography.titleLarge.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 380,
            child: CommentsSection(videoId: video.id),
          ),
        ],
      ],
    );
  }

  Widget _buildNoVideoLayout(TopicDetail topic) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        if (topic.notes.isNotEmpty) ...[
          Text('Notes', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ...topic.notes.map(
            (ref) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContentTile(
                icon: Icons.description_outlined,
                iconBackground: AppColors.secondaryLight,
                iconColor: AppColors.secondaryDark,
                title: ref.name,
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NotesPdfPage(notesId: ref.id, title: ref.name),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
        if (topic.mcqTests.isNotEmpty) ...[
          Text('MCQ Tests', style: AppTypography.titleLarge.copyWith(fontSize: 18)),
          const SizedBox(height: 12),
          ...topic.mcqTests.map(
            (ref) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _ContentTile(
                icon: Icons.quiz_outlined,
                iconBackground: AppColors.primaryLight,
                iconColor: AppColors.primaryDark,
                title: ref.name,
                trailingIcon: Icons.arrow_forward_ios_rounded,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => QuizPage(testId: ref.id, title: ref.name),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _ContentTile extends StatelessWidget {
  const _ContentTile({
    required this.icon,
    required this.iconBackground,
    required this.iconColor,
    required this.title,
    required this.onTap,
    this.trailingIcon = Icons.arrow_forward_ios_rounded,
    this.selected = false,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconColor;
  final String title;
  final VoidCallback onTap;
  final IconData trailingIcon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBackground,
              borderRadius: BorderRadius.circular(12),
              border: selected ? Border.all(color: iconColor, width: 2) : null,
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.titleMedium,
            ),
          ),
          Icon(trailingIcon, color: AppColors.textMuted, size: 18),
        ],
      ),
    );
  }
}
