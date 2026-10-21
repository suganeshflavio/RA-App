import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/dashboard_content.dart';
import '../widgets/app_background.dart';
import '../widgets/custom_card.dart';
import 'resource_detail_page.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key, required this.resources});

  final List<ResourceItem> resources;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Learning Resources'),
      ),
      body: AppBackground(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Explore Study Materials',
                style: AppTypography.displayMedium.copyWith(fontSize: 24),
              ),
              const SizedBox(height: 4),
              Text(
                'Select a resource to open reference guides and notes',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.separated(
                  itemCount: resources.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final item = resources[index];
                    final accent = _hexColor(item.accent);
                    return AppCard(
                      padding: const EdgeInsets.all(18),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ResourceDetailPage(resource: item),
                          ),
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration: BoxDecoration(
                              color: accent.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              _resourceIcon(item.icon),
                              color: accent,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: AppTypography.titleLarge.copyWith(fontSize: 17),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.subtitle,
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
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

IconData _resourceIcon(String key) {
  switch (key) {
    case 'notes':
      return Icons.sticky_note_2_rounded;
    case 'clipboard':
      return Icons.assignment_rounded;
    case 'book':
      return Icons.menu_book_rounded;
    case 'book-open':
      return Icons.auto_stories_rounded;
    case 'shield':
      return Icons.verified_user_rounded;
    case 'spark':
      return Icons.local_fire_department_rounded;
    default:
      return Icons.folder_open_rounded;
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
