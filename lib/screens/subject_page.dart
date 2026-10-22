import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/catalog_models.dart';
import '../models/user_access_models.dart';
import '../repositories/catalog_repository.dart';
import '../state/session_state.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/inline_search_field.dart';
import '../widgets/skeleton.dart';
import 'chapter_page.dart';

/// Either the course's `CourseTopic` links (current, preferred) or its
/// legacy `CourseSubject` links (courses configured before topic-level
/// linking existed) — whichever the backend actually returned data for.
class _SubjectPageData {
  const _SubjectPageData.topicMode(this.topicRefs) : subjectGroups = null;
  const _SubjectPageData.legacyMode(this.subjectGroups) : topicRefs = null;

  final List<CourseTopicRef>? topicRefs;
  final List<CourseSubjectGroup>? subjectGroups;

  bool get isTopicMode => topicRefs != null;
}

class SubjectPage extends StatefulWidget {
  const SubjectPage({super.key, required this.course});

  final UserCourse course;

  @override
  State<SubjectPage> createState() => _SubjectPageState();
}

class _SubjectPageState extends State<SubjectPage> {
  final _repository = CatalogRepository(ApiClient());
  late Future<_SubjectPageData> _future;
  String _query = '';
  String? _resolvingId;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  /// Prefers the course's `CourseTopic` links; only falls back to the
  /// legacy `CourseSubject` flow (auto-resolving Class from the profile)
  /// when a course has no topic links at all.
  Future<_SubjectPageData> _load() async {
    final topicRefs = await _repository.fetchCourseTopics(widget.course.courseId);
    if (topicRefs.isNotEmpty) {
      return _SubjectPageData.topicMode(topicRefs);
    }
    final subjectGroups = await _repository.fetchCourseSubjects(widget.course.courseId);
    return _SubjectPageData.legacyMode(subjectGroups);
  }

  void _retry() => setState(() => _future = _load());

  void _openChapters(
    String classId,
    String subjectName, {
    List<CourseTopicRef>? topicRefs,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChapterPage(
          course: widget.course,
          classId: classId,
          subjectName: subjectName,
          topicRefs: topicRefs,
        ),
      ),
    );
  }

  // ---------------- topic-linking mode (CourseTopic) ----------------

  Future<void> _openTopicSubject(
    List<CourseTopicRef> allRefs,
    String subjectId,
    String subjectName,
  ) async {
    final refs = allRefs.where((ref) => ref.subjectId == subjectId).toList();

    final classNames = <String, String>{};
    for (final ref in refs) {
      classNames.putIfAbsent(ref.classId, () => ref.className);
    }

    if (classNames.length == 1) {
      final classId = classNames.keys.first;
      _openChapters(
        classId,
        subjectName,
        topicRefs: refs.where((ref) => ref.classId == classId).toList(),
      );
      return;
    }

    setState(() => _resolvingId = subjectId);
    try {
      final chosenClassId = await _pickClassId(subjectName, classNames);
      if (chosenClassId != null) {
        _openChapters(
          chosenClassId,
          subjectName,
          topicRefs: refs.where((ref) => ref.classId == chosenClassId).toList(),
        );
      }
    } finally {
      if (mounted) setState(() => _resolvingId = null);
    }
  }

  Future<String?> _pickClassId(String subjectName, Map<String, String> classNames) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$subjectName — Choose a class',
                  style: AppTypography.titleLarge.copyWith(fontSize: 17),
                ),
                const SizedBox(height: 4),
                Text(
                  'This course covers more than one class for this subject.',
                  style: AppTypography.labelSmall,
                ),
                const SizedBox(height: 16),
                ...classNames.entries.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: AppCard(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      onTap: () => Navigator.of(sheetContext).pop(entry.key),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(entry.value, style: AppTypography.titleMedium),
                          ),
                          const Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: AppColors.textMuted,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------- legacy mode (CourseSubject) ----------------

  /// Auto-resolves the Class from the student's profile — used when this
  /// subject was linked to the course without pinning it to a specific
  /// class.
  Future<void> _autoResolveAndOpen(CourseSubjectGroup subject) async {
    final classes = await _repository.fetchClasses(subject.subjectId);
    if (!mounted) return;
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No classes found for this subject.')),
      );
      return;
    }

    final className = context.read<SessionState>().user?.className;
    final resolved = className == null
        ? classes.first
        : classes.firstWhere(
            (c) => c.name.trim().toLowerCase() == className.trim().toLowerCase(),
            orElse: () => classes.first,
          );

    _openChapters(resolved.id, subject.subjectName);
  }

  Future<void> _pickClassAndOpenLegacy(
    CourseSubjectGroup subject,
    List<CourseSubjectClassLink> options,
  ) async {
    final classNames = <String, String>{
      for (final option in options)
        if (option.classId != null) option.classId!: option.className ?? 'Class',
    };
    final chosenClassId = await _pickClassId(subject.subjectName, classNames);
    if (chosenClassId != null) {
      _openChapters(chosenClassId, subject.subjectName);
    }
  }

  Future<void> _openLegacySubject(CourseSubjectGroup subject) async {
    setState(() => _resolvingId = subject.subjectId);
    try {
      final links = subject.classLinks;
      final hasUnrestrictedLink = links.any((link) => link.classId == null);

      if (hasUnrestrictedLink) {
        await _autoResolveAndOpen(subject);
        return;
      }

      final specificLinks = links.where((link) => link.classId != null).toList();
      if (specificLinks.length == 1) {
        _openChapters(specificLinks.first.classId!, subject.subjectName);
        return;
      }

      await _pickClassAndOpenLegacy(subject, specificLinks);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } finally {
      if (mounted) setState(() => _resolvingId = null);
    }
  }

  // ---------------- shared UI ----------------

  Widget _emptyCard(String message) {
    return Padding(
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
                message,
                style: AppTypography.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _subjectTile({
    required String id,
    required String name,
    required VoidCallback onTap,
  }) {
    final isResolving = _resolvingId == id;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: AppCard(
        padding: const EdgeInsets.all(18),
        onTap: isResolving ? null : onTap,
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
              child: Text(name, style: AppTypography.titleMedium),
            ),
            if (isResolving)
              const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            else
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.textMuted,
                size: 16,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicModeList(List<CourseTopicRef> topicRefs) {
    final subjectNames = <String, String>{};
    for (final ref in topicRefs) {
      subjectNames.putIfAbsent(ref.subjectId, () => ref.subjectName);
    }
    final filtered = subjectNames.entries
        .where(
          (entry) => entry.value.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      children: [
        InlineSearchField(
          hintText: 'Search subjects...',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 18),
        if (filtered.isEmpty)
          _emptyCard('No subjects found.')
        else
          ...filtered.map(
            (entry) => _subjectTile(
              id: entry.key,
              name: entry.value,
              onTap: () => _openTopicSubject(topicRefs, entry.key, entry.value),
            ),
          ),
      ],
    );
  }

  Widget _buildLegacyModeList(List<CourseSubjectGroup> subjectGroups) {
    final filtered = subjectGroups
        .where(
          (subject) =>
              subject.subjectName.toLowerCase().contains(_query.trim().toLowerCase()),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      children: [
        InlineSearchField(
          hintText: 'Search subjects...',
          onChanged: (value) => setState(() => _query = value),
        ),
        const SizedBox(height: 18),
        if (filtered.isEmpty)
          _emptyCard('No subjects found.')
        else
          ...filtered.map(
            (subject) => _subjectTile(
              id: subject.subjectId,
              name: subject.subjectName,
              onTap: () => _openLegacySubject(subject),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.course.courseName),
      ),
      body: AppBackground(
        child: FutureBuilder<_SubjectPageData>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const VideoListSkeleton();
            }

            if (snapshot.hasError) {
              final message = snapshot.error is ApiException
                  ? (snapshot.error as ApiException).message
                  : 'Unable to load subjects.';
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

            final data = snapshot.data;
            if (data == null) return const SizedBox.shrink();

            return data.isTopicMode
                ? _buildTopicModeList(data.topicRefs!)
                : _buildLegacyModeList(data.subjectGroups!);
          },
        ),
      ),
    );
  }
}
