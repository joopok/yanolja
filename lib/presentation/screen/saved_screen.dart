import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedProvider);
    final allAccommodationsAsync = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.background,
      body: allAccommodationsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: YanoljaColors.primary),
        ),
        error: (err, stack) => _buildErrorState(context, ref, err.toString()),
        data: (allAccommodations) {
          final savedAccommodations = allAccommodations
              .where((acc) => savedIds.contains(acc.id))
              .toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, savedAccommodations.length),
              if (savedAccommodations.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(context),
                )
              else
                _buildSavedList(context, ref, savedAccommodations),
            ],
          );
        },
      ),
      floatingActionButton: savedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showClearAllDialog(context, ref),
              backgroundColor: YanoljaColors.primary,
              foregroundColor: Colors.white,
              elevation: 2,
              icon: const Icon(Icons.delete_sweep_outlined, size: 20),
              label: const Text(
                '전체 삭제',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
    );
  }

  /// 야놀자 스타일 화이트 좌측정렬 앱바
  SliverAppBar _buildSliverAppBar(BuildContext context, int count) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: YanoljaColors.shadow,
      backgroundColor: YanoljaColors.background,
      surfaceTintColor: YanoljaColors.background,
      centerTitle: false,
      titleSpacing: 20,
      title: RichText(
        text: TextSpan(
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.4,
          ),
          children: [
            const TextSpan(text: '찜 목록 '),
            TextSpan(
              text: '$count',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                color: YanoljaColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSavedList(
    BuildContext context,
    WidgetRef ref,
    List<Accommodation> savedAccommodations,
  ) {
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 100),
      sliver: AnimationLimiter(
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final accommodation = savedAccommodations[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 300),
                child: SlideAnimation(
                  verticalOffset: 20.0,
                  child: FadeInAnimation(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child:
                          _buildDismissibleCard(context, ref, accommodation),
                    ),
                  ),
                ),
              );
            },
            childCount: savedAccommodations.length,
          ),
        ),
      ),
    );
  }

  Widget _buildDismissibleCard(
    BuildContext context,
    WidgetRef ref,
    Accommodation accommodation,
  ) {
    return Dismissible(
      key: Key(accommodation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
          color: YanoljaColors.primary,
        ),
        alignment: Alignment.centerRight,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete_sweep_outlined, color: Colors.white, size: 26),
            SizedBox(height: 4),
            Text(
              '삭제',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
      confirmDismiss: (direction) async {
        return await _showRemoveDialog(context, accommodation.name);
      },
      onDismissed: (direction) {
        ref.read(savedProvider.notifier).removeSaved(accommodation.id);
        _showSnackBar(context, '${accommodation.name}을(를) 찜 목록에서 삭제했습니다.');
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          context.push('/detail/${accommodation.id}');
        },
        child: Hero(
          tag: 'saved-${accommodation.id}',
          child: _buildSavedCard(context, ref, accommodation),
        ),
      ),
    );
  }

  /// 야놀자 플랫 찜 카드 (가로형 썸네일 + 정보)
  Widget _buildSavedCard(
    BuildContext context,
    WidgetRef ref,
    Accommodation accommodation,
  ) {
    final rate = YanoljaFormat.discountRate(accommodation.id);
    final original = YanoljaFormat.originalPrice(accommodation.price, rate);

    return Container(
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: YanoljaColors.border, width: 1),
        boxShadow: const [
          BoxShadow(
            color: YanoljaColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 썸네일
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: accommodation.imageUrls.isNotEmpty
                        ? accommodation.imageUrls.first
                        : '',
                    width: 104,
                    height: 104,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 104,
                      height: 104,
                      color: YanoljaColors.surfaceAlt,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 104,
                      height: 104,
                      color: YanoljaColors.surfaceAlt,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: YanoljaColors.textTertiary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
                if (accommodation.isPopular || accommodation.isNew)
                  Positioned(
                    top: 6,
                    left: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: accommodation.isNew
                            ? YanoljaColors.textPrimary
                            : YanoljaColors.primary,
                        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                      ),
                      child: Text(
                        accommodation.isNew ? 'NEW' : '인기',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 14),
            // 정보
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          accommodation.name,
                          style: const TextStyle(
                            fontSize: 15.5,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.3,
                            height: 1.25,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // 찜 해제 버튼
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          ref
                              .read(savedProvider.notifier)
                              .toggleSaved(accommodation.id);
                          _showSnackBar(
                            context,
                            '${accommodation.name}을(를) 찜 목록에서 삭제했습니다.',
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Icon(
                            Icons.favorite_rounded,
                            color: YanoljaColors.primary,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 12.5,
                        color: YanoljaColors.textTertiary,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          accommodation.address,
                          style: const TextStyle(
                            fontSize: 12,
                            color: YanoljaColors.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  YanoljaRating(
                    rating: accommodation.rating,
                    reviewCount: accommodation.reviewCount,
                    fontSize: 12,
                  ),
                  const SizedBox(height: 8),
                  // 가격: 정가(취소선) + 핑크 할인율 + 굵은 현재가
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '$rate%',
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: YanoljaColors.primary,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${YanoljaFormat.price(original)}원',
                        style: const TextStyle(
                          fontSize: 11,
                          color: YanoljaColors.textTertiary,
                          decoration: TextDecoration.lineThrough,
                          decorationColor: YanoljaColors.textTertiary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        YanoljaFormat.price(accommodation.price),
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const Text(
                        '원',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: YanoljaColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: YanoljaColors.primaryLight,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                color: YanoljaColors.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              '찜한 숙소가 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '마음에 드는 숙소를 찜하고\n나중에 편하게 확인하세요.',
              style: TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home_outlined, size: 18),
              label: const Text('홈으로 가기'),
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: YanoljaColors.textTertiary,
              size: 56,
            ),
            const SizedBox(height: 24),
            const Text(
              '데이터를 불러올 수 없어요',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              '네트워크 연결을 확인하거나\n잠시 후 다시 시도해 주세요.',
              style: TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(accommodationListProvider),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('다시 시도'),
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showRemoveDialog(
      BuildContext context, String accommodationName) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: YanoljaColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          ),
          title: const Text(
            '찜 삭제',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: YanoljaColors.textPrimary,
            ),
          ),
          content: Text(
            '$accommodationName을(를) 정말 삭제할까요?',
            style: const TextStyle(color: YanoljaColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text(
                '취소',
                style: TextStyle(color: YanoljaColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                ),
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: YanoljaColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          ),
          title: const Text(
            '전체 삭제',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: YanoljaColors.textPrimary,
            ),
          ),
          content: const Text(
            '찜한 모든 숙소를 삭제할까요?\n이 작업은 되돌릴 수 없습니다.',
            style: TextStyle(color: YanoljaColors.textSecondary, height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text(
                '취소',
                style: TextStyle(color: YanoljaColors.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(savedProvider.notifier).clearAll();
                Navigator.of(context).pop();
                _showSnackBar(context, '모든 찜 목록이 삭제되었습니다.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                ),
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: YanoljaColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
