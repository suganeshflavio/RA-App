import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'pdf_viewer.dart';
import 'skeleton.dart';

/// Renders a note/attachment for a video. PDFs use the native
/// [PdfViewer] (flutter_pdfview); other office formats (PPT/DOC/XLS, etc.)
/// fall back to an embedded web viewer since there's no native Flutter
/// renderer for those.
class NotesViewer extends StatelessWidget {
  const NotesViewer({super.key, required this.notesUrl});

  final String notesUrl;

  @override
  Widget build(BuildContext context) {
    final extension = Uri.parse(notesUrl).path.split('.').last.toLowerCase();
    if (extension == 'pdf') {
      return PdfViewer(url: notesUrl);
    }
    return _OfficeDocumentViewer(notesUrl: notesUrl);
  }
}

class _OfficeDocumentViewer extends StatefulWidget {
  const _OfficeDocumentViewer({required this.notesUrl});

  final String notesUrl;

  @override
  State<_OfficeDocumentViewer> createState() => _OfficeDocumentViewerState();
}

class _OfficeDocumentViewerState extends State<_OfficeDocumentViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    final viewerUrl =
        'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(widget.notesUrl)}';

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            await _controller.runJavaScript(_cleanupScript);
            if (mounted) setState(() => _isLoading = false);
          },
        ),
      )
      ..loadRequest(Uri.parse(viewerUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFFDDBF)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            SizedBox.expand(child: WebViewWidget(controller: _controller)),
            if (_isLoading) const DocumentSkeleton(),
          ],
        ),
      ),
    );
  }
}

// Best-effort cleanup: the viewer is a third-party hosted page we don't
// control, so these selectors may not match every layout/update on their end.
const _cleanupScript = '''
(function() {
  document.documentElement.style.overflow = 'auto';
  document.body.style.overflow = 'auto';
  document.body.style.webkitOverflowScrolling = 'touch';

  var header = document.querySelector('.ndfHFb-c4325c-HcW0Tw-Lg2Whd');
  if (header) header.style.display = 'none';

  var topBar = document.querySelector('.ndfHFb-c4325c-HzV7m-pbAoWc');
  if (topBar) topBar.style.display = 'none';

  var popout = document.querySelector('.ndfHFb-c4325c-J8mB1c-BPrWId');
  if (popout) popout.style.display = 'none';

  var iframe = document.querySelector('iframe');
  if (iframe) {
    iframe.style.width = '100%';
    iframe.style.height = '100%';
  }
})();
''';
