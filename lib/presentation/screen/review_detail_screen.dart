import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/review_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';

class ReviewDetailScreen extends ConsumerWidget {
  final String accommodationId;
  final String reviewId;

  const ReviewDetailScreen({
    super.key,
    required this.accommodationId,
    required this.reviewId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accommodationAsync =
        ref.watch(accommodationDetailProvider(accommodationId));
    final reviewsAsync = ref.watch(reviewFeedProvider(accommodationId));

    return reviewsAsync.when(
      loading: () => const Scaffold(
        appBar: YanoljaAppBar.sub(title: '후기 상세'),
        body: Center(
          child: CircularProgressIndicator(color: YanoljaColors.primary),
        ),
      ),
      error: (error, _) => Scaffold(
        appBar: const YanoljaAppBar.sub(title: '후기 상세'),
        body: Center(child: Text('후기를 불러오지 못했어요\n$error')),
      ),
      data: (reviews) {
        ReviewFeedItem? review;
        for (final item in reviews) {
          if (item.id == reviewId) {
            review = item;
            break;
          }
        }
        if (review == null) {
          return const Scaffold(
            appBar: YanoljaAppBar.sub(title: '후기 상세'),
            body: Center(child: Text('삭제되었거나 존재하지 않는 후기입니다.')),
          );
        }

        final currentReview = review;
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: YanoljaAppBar.sub(
            title: '후기 상세',
            fallbackRoute: '/detail/$accommodationId/reviews',
            actions: currentReview.isEditable
                ? [
                    PopupMenuButton<String>(
                      tooltip: '후기 관리',
                      icon: const Icon(Icons.more_vert_rounded),
                      onSelected: (value) {
                        if (value == 'edit') {
                          context.push(
                            '/detail/$accommodationId/review-editor'
                            '?reviewId=${Uri.encodeComponent(reviewId)}',
                          );
                        } else if (value == 'delete') {
                          _delete(context, ref, currentReview);
                        }
                      },
                      itemBuilder: (context) => const [
                        PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(Icons.edit_outlined),
                            title: Text('수정하기'),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              Icons.delete_outline_rounded,
                              color: YanoljaColors.sale,
                            ),
                            title: Text(
                              '삭제하기',
                              style: TextStyle(color: YanoljaColors.sale),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]
                : null,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 40),
            children: [
              YanoljaEntrance(
                child: accommodationAsync.maybeWhen(
                  data: (accommodation) => Text(
                    accommodation.name,
                    style: const TextStyle(
                      color: YanoljaColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  orElse: () => const SizedBox.shrink(),
                ),
              ),
              const SizedBox(height: 18),
              YanoljaEntrance(
                delay: const Duration(milliseconds: 50),
                child: Row(
                  children: [
                    _Avatar(name: currentReview.userName),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  currentReview.userName,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: YanoljaColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (currentReview.isEditable) ...[
                                const SizedBox(width: 7),
                                const Icon(
                                  Icons.verified_rounded,
                                  size: 16,
                                  color: YanoljaColors.primary,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('yyyy년 M월 d일').format(
                              currentReview.date,
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              color: YanoljaColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              YanoljaEntrance(
                delay: const Duration(milliseconds: 90),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: YanoljaColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        color: YanoljaColors.star,
                        size: 28,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        currentReview.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      _InfoPill(
                        icon: Icons.group_outlined,
                        label: currentReview.tripType,
                      ),
                      const SizedBox(width: 7),
                      _InfoPill(
                        icon: currentReview.recommended
                            ? Icons.thumb_up_alt_outlined
                            : Icons.sentiment_dissatisfied_outlined,
                        label: currentReview.recommended ? '추천해요' : '아쉬웠어요',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 26),
              YanoljaEntrance(
                delay: const Duration(milliseconds: 130),
                child: Text(
                  currentReview.title,
                  style: const TextStyle(
                    fontSize: 22,
                    height: 1.3,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              YanoljaEntrance(
                delay: const Duration(milliseconds: 170),
                child: Text(
                  currentReview.comment,
                  style: const TextStyle(
                    fontSize: 15,
                    height: 1.75,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
              ),
              if (currentReview.isEditable) ...[
                const SizedBox(height: 32),
                const Divider(color: YanoljaColors.divider),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  onPressed: () => context.push(
                    '/detail/$accommodationId/review-editor'
                    '?reviewId=${Uri.encodeComponent(reviewId)}',
                  ),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    foregroundColor: YanoljaColors.textPrimary,
                    side: const BorderSide(color: YanoljaColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined, size: 19),
                  label: const Text(
                    '내 후기 수정하기',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    ReviewFeedItem review,
  ) async {
    final confirmed = await showYanoljaConfirmDialog(
      context: context,
      icon: Icons.delete_outline_rounded,
      title: '후기를 삭제할까요?',
      message: '삭제한 후기는 다시 복구할 수 없습니다.',
      confirmText: '삭제',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted || review.storedReview == null) return;

    await ref.read(reviewActionsProvider).delete(review.storedReview!);
    if (context.mounted) context.pop();
  }
}

class _Avatar extends StatelessWidget {
  final String name;

  const _Avatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: YanoljaColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Text(
        name.isEmpty ? '익' : name.characters.first,
        style: const TextStyle(
          color: YanoljaColors.primary,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: YanoljaColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: YanoljaColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
