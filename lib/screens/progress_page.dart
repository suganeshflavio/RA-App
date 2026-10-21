import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/dashboard_content.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key, required this.metrics, required this.courses});

  final List<ProgressMetric> metrics;
  final List<CourseItem> courses;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primarySubtle,
      appBar: AppBar(
        backgroundColor: AppColors.primarySubtle,
        foregroundColor: const Color(0xFF3A1E0B),
        elevation: 0,
        title: const Text('Progress'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...metrics.map((metric) {
            final accent = _hexColor(metric.accent);
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFFDDBF)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          metric.label,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF3A1E0B),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          metric.detail,
                          style: const TextStyle(color: Color(0xFF8F6A4D)),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    metric.value,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 14),
          const Text(
            'Course Tracking',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF3A1E0B),
            ),
          ),
          const SizedBox(height: 10),
          ...courses.map((course) {
            final completion = (course.rating * 20).clamp(20, 100).toInt();
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFFDDBF)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    course.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF3A1E0B),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      minHeight: 9,
                      value: completion / 100,
                      color: const Color(0xFFF97316),
                      backgroundColor: const Color(0xFFFFE9D8),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$completion% completed',
                    style: const TextStyle(color: Color(0xFF8F6A4D)),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

Color _hexColor(String value) {
  final buffer = StringBuffer();
  if (value.length == 7) {
    buffer.write('ff');
  }
  buffer.write(value.replaceFirst('#', ''));
  return Color(int.parse(buffer.toString(), radix: 16));
}
