import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/video_lesson.dart';
import '../widgets/app_background.dart';
import '../widgets/comments_section.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/media_video_player.dart';
import '../widgets/notes_viewer.dart';
import 'quiz_page.dart';

class VideoPlayerPage extends StatefulWidget {
  const VideoPlayerPage({
    super.key,
    required this.video,
    this.autoShowNotes = false,
  });

  final VideoLesson video;
  final bool autoShowNotes;

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late bool _showNotes;

  @override
  void initState() {
    super.initState();
    _showNotes = widget.autoShowNotes;
  }

  void _toggleNotes() => setState(() => _showNotes = !_showNotes);

  void _closeNotes() => setState(() => _showNotes = false);

  void _openQuiz() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => QuizPage(video: widget.video)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final video = widget.video;
    final isKeyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Lesson Player'),
      ),
      body: AppBackground(
        child: Column(
          children: [
            // Video Player Container (hidden/compact when typing if space is constrained)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: video.videoUrl.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: MediaVideoPlayer(videoUrl: video.videoUrl),
                    )
                  : AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          'Unable to load this video.',
                          style: AppTypography.bodyMedium,
                        ),
                      ),
                    ),
            ),
            // Hide description & action buttons when typing to prevent bottom overflow when keyboard opens
            if (!_showNotes && !isKeyboardOpen)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.videoName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${video.subject} • ${video.chapter}',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.primaryDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      video.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.bodyMedium,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        if (video.hasNotes)
                          Expanded(
                            child: AppSecondaryButton(
                              text: 'Notes',
                              icon: Icons.description_outlined,
                              height: 44,
                              onPressed: _toggleNotes,
                            ),
                          ),
                        if (video.hasNotes) const SizedBox(width: 10),
                        Expanded(
                          child: AppPrimaryButton(
                            text: 'Start MCQ',
                            icon: Icons.quiz_outlined,
                            height: 44,
                            onPressed: _openQuiz,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: _showNotes
                  ? Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.description_rounded,
                                color: AppColors.primaryDark,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Lesson Notes',
                                  style: AppTypography.titleMedium,
                                ),
                              ),
                              IconButton(
                                onPressed: _closeNotes,
                                icon: const Icon(Icons.close_rounded),
                                color: AppColors.textPrimary,
                                tooltip: 'Close notes',
                              ),
                            ],
                          ),
                          Expanded(
                            child: NotesViewer(notesUrl: video.notesUrl!),
                          ),
                        ],
                      ),
                    )
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (!isKeyboardOpen) ...[
                            Text(
                              'Discussion & Comments',
                              style: AppTypography.titleMedium.copyWith(
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                          ],
                          Expanded(child: CommentsSection(videoId: video.id)),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
