import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';

import 'skeleton.dart';

class PdfViewer extends StatefulWidget {
  const PdfViewer({super.key, required this.url});

  final String url;

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  late Future<String> _filePathFuture;

  @override
  void initState() {
    super.initState();
    _filePathFuture = _downloadIfNeeded(widget.url);
  }

  Future<String> _downloadIfNeeded(String url) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/notes_${url.hashCode}.pdf');
    if (await file.exists() && await file.length() > 0) {
      return file.path;
    }
    await Dio().download(url, file.path);
    return file.path;
  }

  void _retry() {
    setState(() => _filePathFuture = _downloadIfNeeded(widget.url));
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
        child: FutureBuilder<String>(
          future: _filePathFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const DocumentSkeleton();
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Unable to load the PDF.',
                      style: TextStyle(color: Color(0xFF6E4D37)),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF97316),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            return PDFView(
              filePath: snapshot.data!,
              enableSwipe: true,
              swipeHorizontal: false,
              autoSpacing: true,
              pageFling: true,
              onError: (error) {},
            );
          },
        ),
      ),
    );
  }
}
