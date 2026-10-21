import 'package:flutter/material.dart';

import '../core/network/api_client.dart';
import '../core/network/api_exception.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../repositories/testimonial_repository.dart';
import 'custom_buttons.dart';

Future<void> showReviewSheet(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => const ReviewSheet(),
  );
}

class ReviewSheet extends StatefulWidget {
  const ReviewSheet({super.key});

  @override
  State<ReviewSheet> createState() => _ReviewSheetState();
}

class _ReviewSheetState extends State<ReviewSheet> {
  final _repository = TestimonialRepository(ApiClient());
  final _reviewController = TextEditingController();
  int _rating = 0;
  bool _isSubmitting = false;
  String? _error;

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_rating == 0) {
      setState(() => _error = 'Please select a rating.');
      return;
    }
    if (_reviewController.text.trim().isEmpty) {
      setState(() => _error = 'Please write your review feedback.');
      return;
    }

    setState(() {
      _isSubmitting = true;
      _error = null;
    });

    try {
      await _repository.submitTestimonial(
        star: _rating,
        review: _reviewController.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          content: const Text('Thank you! Your review will appear after approval.'),
        ),
      );
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Rate Your Experience',
                style: AppTypography.displayMedium.copyWith(fontSize: 20),
              ),
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(5, (index) {
                final filled = index < _rating;
                return IconButton(
                  iconSize: 38,
                  onPressed: () => setState(() {
                    _rating = index + 1;
                    _error = null;
                  }),
                  icon: Icon(
                    filled ? Icons.star_rounded : Icons.star_border_rounded,
                    color: AppColors.primary,
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _reviewController,
            maxLines: 4,
            style: AppTypography.bodyLarge,
            decoration: InputDecoration(
              hintText: 'Share your learning experience...',
              fillColor: AppColors.background,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: AppTypography.labelSmall.copyWith(color: AppColors.error),
            ),
          ],
          const SizedBox(height: 20),
          AppPrimaryButton(
            text: 'Submit Review',
            isLoading: _isSubmitting,
            icon: Icons.rate_review_outlined,
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
