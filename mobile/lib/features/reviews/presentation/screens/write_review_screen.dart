import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:brewphoria/core/constants/app_colors.dart';
import 'package:brewphoria/core/constants/app_text_styles.dart';
import 'package:brewphoria/features/reviews/presentation/providers/review_provider.dart';
import 'package:brewphoria/features/reviews/domain/review_model.dart';

class WriteReviewScreen extends ConsumerStatefulWidget {
  const WriteReviewScreen({required this.orderId, super.key});

  final String orderId; // This is actually orderItemId from the route

  @override
  ConsumerState<WriteReviewScreen> createState() => _WriteReviewScreenState();
}

class _WriteReviewScreenState extends ConsumerState<WriteReviewScreen> {
  int _rating = 0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reviewState = ref.watch(reviewNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Write Review', style: AppTextStyles.headlineMedium),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Icon(Icons.rate_review_outlined,
                      size: 64, color: AppColors.textSecondary),
                  const SizedBox(height: 12),
                  Text('How was your experience?',
                      style: AppTextStyles.headlineSmall),
                  const SizedBox(height: 24),
                  // Star rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (i) => GestureDetector(
                        onTap: () => setState(() => _rating = i + 1),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < _rating ? Icons.star : Icons.star_border,
                            size: 44,
                            color: AppColors.tierGold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _ratingLabel,
                    style: AppTextStyles.bodyMedium
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Text('Your Comment', style: AppTextStyles.labelLarge),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 5,
              maxLength: 1000,
              decoration: const InputDecoration(
                hintText:
                    'Share your thoughts about this product... (min 10 characters)',
              ),
            ),
            const SizedBox(height: 32),
            if (reviewState.hasError)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  reviewState.error.toString(),
                  style:
                      AppTextStyles.bodySmall.copyWith(color: AppColors.error),
                ),
              ),
            ElevatedButton(
              onPressed: reviewState.isLoading || _rating == 0
                  ? null
                  : () async {
                      if (_commentController.text.length < 10) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Comment must be at least 10 characters')),
                        );
                        return;
                      }
                      final review = await ref
                          .read(reviewNotifierProvider.notifier)
                          .submitReview(CreateReviewRequest(
                            orderItemId: widget.orderId,
                            rating: _rating,
                            comment: _commentController.text,
                          ));
                      if (review != null && context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Review submitted! Thank you.')),
                        );
                        context.pop();
                      }
                    },
              child: reviewState.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Text('Submit Review'),
            ),
          ],
        ),
      ),
    );
  }

  String get _ratingLabel => switch (_rating) {
        1 => 'Poor',
        2 => 'Fair',
        3 => 'Good',
        4 => 'Very Good',
        5 => 'Excellent',
        _ => 'Tap to rate',
      };
}
