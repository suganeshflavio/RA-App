import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/notes_item.dart';
import '../repositories/notes_repository.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_buttons.dart';
import '../widgets/custom_card.dart';
import '../widgets/notes_viewer.dart';

class NotesPdfPage extends StatefulWidget {
  const NotesPdfPage({super.key, required this.notesId, required this.title});

  final String notesId;
  final String title;

  @override
  State<NotesPdfPage> createState() => _NotesPdfPageState();
}

class _NotesPdfPageState extends State<NotesPdfPage> {
  final _repository = NotesRepository(ApiClient());
  late Future<NotesItem> _future;

  @override
  void initState() {
    super.initState();
    _future = _repository.fetchNotesById(widget.notesId);
  }

  void _retry() => setState(() => _future = _repository.fetchNotesById(widget.notesId));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: AppBackground(
        child: FutureBuilder<NotesItem>(
          future: _future,
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

            return NotesViewer(notesUrl: snapshot.data!.notesUrl);
          },
        ),
      ),
    );
  }
}
