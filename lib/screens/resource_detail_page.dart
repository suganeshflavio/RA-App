import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/dashboard_content.dart';

class ResourceDetailPage extends StatelessWidget {
  const ResourceDetailPage({super.key, required this.resource});

  final ResourceItem resource;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySubtle,
      appBar: AppBar(
        backgroundColor: AppColors.primarySubtle,
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: Text(resource.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: const Color(0xFFFFDDBF)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                resource.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF3A1E0B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                resource.subtitle,
                style: const TextStyle(fontSize: 16, color: Color(0xFF8F6A4D)),
              ),
              const SizedBox(height: 14),
              const Text(
                'This resource detail page is now fully connected from Home -> Resources and each item opens here for deeper content access.',
                style: TextStyle(height: 1.7, color: Color(0xFF6E4D37)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
