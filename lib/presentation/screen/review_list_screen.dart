import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/review_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

enum _ReviewFilter { latest, highRating, mine }

class ReviewListScreen extends ConsumerStatefulWidget {
  final String accommodationId;

  const ReviewListScreen({
    super.key,
    required this.accommodationId,
  });

  @override
  ConsumerState<ReviewListScreen> createState() => _ReviewListScreenState();
}

class _ReviewListScreenState extends ConsumerState<ReviewListScreen> {
  _ReviewFilter _filter = _ReviewFilter.latest;

  @override
  Widget build(BuildContext context) {
    final accommodationAsync =
        ref.watch(accommodationDetailProvider(widget.accommodationId));
    final reviewsAsync = ref.watch(reviewFeedProvider(widget.accommodationId));

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      appBar: YanoljaAppBar.sub(
        title: '실제 이용객 후기',
        fallbackRoute: '/detail/${widget.accommodationId}',
        actions: [
          IconButton(
            tooltip: '후기 작성',
            icon: const Icon(Icons.edit_square),
            onPressed: _openEditor,
          ),
        ],
      ),
      body: accommodationAsync.when(
        loading: _loading,
        error: (error, _) => _error(error),
        data: (accommodation) {
          return reviewsAsync.when(
            loading: _loading,
            error: (error, _) => _error(error),
            data: (reviews) {
              final displayed = _applyFilter(reviews);
              final storedCount =
                  reviews.where((item) => item.isEditable).length;
              return RefreshIndicator(
                color: YanoljaColors.primary,
                onRefresh: () async {
                  ref.invalidate(reviewFeedProvider(widget.accommodationId));
                  await ref.read(
                    reviewFeedProvider(widget.accommodationId).future,
                  );
                },
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  slivers: [
                    SliverToBoxAdapter(
                      child: _buildSummary(
                        accommodation.name,
                        accommodation.rating,
                        accommodation.reviewCount + storedCount,
                      ),
                    ),
                    SliverToBoxAdapter(child: _buildFilters()),
                    if (displayed.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: _emptyState(),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 112),
                        sliver: SliverList.separated(
                          itemCount: displayed.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final review = displayed[index];
                            return YanoljaEntrance(
                              delay: YanoljaMotion.stagger(
                                index,
                                start: 20,
                                step: 35,
                              ),
                              child: _ReviewListCard(
                                review: review,
                                onTap: () => context.push(
                                  '/detail/${widget.accommodationId}/reviews/${review.id}',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: _openEditor,
              style: FilledButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
              icon: const Icon(Icons.edit_rounded, size: 20),
              label: const Text(
                '후기 작성하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<ReviewFeedItem> _applyFilter(List<ReviewFeedItem> source) {
    final items = switch (_filter) {
      _ReviewFilter.mine =>
        source.where((review) => review.isEditable).toList(),
      _ => List<ReviewFeedItem>.from(source),
    };
    if (_filter == _ReviewFilter.highRating) {
      items.sort((a, b) => b.rating.compareTo(a.rating));
    } else {
      items.sort((a, b) => b.date.compareTo(a.date));
    }
    return items;
  }

  Widget _buildSummary(String name, double rating, int reviewCount) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      child: YanoljaEntrance(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: YanoljaColors.textPrimary,
            borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      '투숙객이 직접 남긴 경험',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '후기 ${NumberFormat('#,###').format(reviewCount)}개',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 74,
                height: 74,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.star_rounded,
                      size: 20,
                      color: YanoljaColors.star,
                    ),
                    Text(
                      rating.toStringAsFixed(1),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilters() {
    const filters = [
      (_ReviewFilter.latest, '최신순'),
      (_ReviewFilter.highRating, '평점 높은순'),
      (_ReviewFilter.mine, '내 후기'),
    ];
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: Row(
        children: [
          for (var index = 0; index < filters.length; index++) ...[
            Expanded(
              child: _FilterButton(
                label: filters[index].$2,
                selected: _filter == filters[index].$1,
                onTap: () => setState(() => _filter = filters[index].$1),
              ),
            ),
            if (index != filters.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.rate_review_outlined,
              size: 48,
              color: YanoljaColors.textTertiary,
            ),
            const SizedBox(height: 14),
            const Text(
              '표시할 후기가 없어요',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              _filter == _ReviewFilter.mine
                  ? '첫 후기를 직접 작성해보세요.'
                  : '새로운 후기가 등록되면 이곳에 표시됩니다.',
              style: const TextStyle(
                color: YanoljaColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _loading() {
    return const Center(
      child: CircularProgressIndicator(color: YanoljaColors.primary),
    );
  }

  Widget _error(Object error) {
    return Center(
      child: Text(
        '후기를 불러오지 못했어요\n$error',
        textAlign: TextAlign.center,
      ),
    );
  }

  void _openEditor() {
    context.push('/detail/${widget.accommodationId}/review-editor');
  }
}

class _FilterButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      pressedScale: 0.98,
      onTap: onTap,
      child: AnimatedContainer(
        duration: YanoljaMotion.base,
        curve: YanoljaMotion.curve,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? YanoljaColors.textPrimary : YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        ),
        child: Text(
          label,
          maxLines: 1,
          style: TextStyle(
            color: selected ? Colors.white : YanoljaColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ReviewListCard extends StatelessWidget {
  final ReviewFeedItem review;
  final VoidCallback onTap;

  const _ReviewListCard({
    required this.review,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _ReviewAvatar(name: review.userName),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              review.userName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                                color: YanoljaColors.textPrimary,
                              ),
                            ),
                          ),
                          if (review.isEditable) ...[
                            const SizedBox(width: 6),
                            const _MyReviewBadge(),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      _StarRow(rating: review.rating),
                    ],
                  ),
                ),
                Text(
                  DateFormat('yyyy.MM.dd').format(review.date),
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: YanoljaColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                _MetaChip(label: review.tripType),
                const SizedBox(width: 6),
                _MetaChip(
                  label: review.recommended ? '추천해요' : '아쉬웠어요',
                  positive: review.recommended,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15.5,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.5,
                color: YanoljaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 13),
            const Align(
              alignment: Alignment.centerRight,
              child: Icon(
                Icons.arrow_forward_rounded,
                size: 18,
                color: YanoljaColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewAvatar extends StatelessWidget {
  final String name;

  const _ReviewAvatar({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: YanoljaColors.primaryLight,
        shape: BoxShape.circle,
      ),
      child: Text(
        name.isEmpty ? '익' : name.characters.first,
        style: const TextStyle(
          color: YanoljaColors.primary,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _StarRow extends StatelessWidget {
  final double rating;

  const _StarRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 5; index++)
          Icon(
            index < rating.round()
                ? Icons.star_rounded
                : Icons.star_outline_rounded,
            size: 14,
            color: YanoljaColors.star,
          ),
        const SizedBox(width: 5),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MetaChip extends StatelessWidget {
  final String label;
  final bool? positive;

  const _MetaChip({
    required this.label,
    this.positive,
  });

  @override
  Widget build(BuildContext context) {
    final color = switch (positive) {
      true => YanoljaColors.success,
      false => YanoljaColors.sale,
      null => YanoljaColors.textSecondary,
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.09),
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MyReviewBadge extends StatelessWidget {
  const _MyReviewBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
        color: YanoljaColors.primaryLight,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      ),
      child: const Text(
        '내 후기',
        style: TextStyle(
          color: YanoljaColors.primary,
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}
