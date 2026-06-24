import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

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
              else ...[
                SliverToBoxAdapter(
                  child: _buildSavedOverview(
                    context,
                    ref,
                    savedAccommodations.length,
                  ),
                ),
                _buildSavedList(context, ref, savedAccommodations),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, int count) {
    return YanoljaSliverAppBar.main(
      title: '찜',
      subtitle: count > 0 ? '찜한 숙소 $count개' : '저장한 숙소가 없어요',
      floating: true,
      snap: true,
      actions: [
        IconButton(
          onPressed: () => context.go('/search'),
          tooltip: '검색',
          icon: const Icon(
            Icons.search_rounded,
            color: YanoljaColors.textPrimary,
            size: 24,
          ),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildSavedOverview(BuildContext context, WidgetRef ref, int count) {
    return Container(
      color: YanoljaColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Row(
              children: [
                _buildSavedTab('숙소', count: count, selected: true),
                const SizedBox(width: 8),
                _buildSavedTab('티켓', count: 0),
                const SizedBox(width: 8),
                _buildSavedTab('공연', count: 0),
                const Spacer(),
                TextButton(
                  onPressed: () => _showClearAllDialog(context, ref),
                  style: TextButton.styleFrom(
                    foregroundColor: YanoljaColors.textSecondary,
                    minimumSize: const Size(0, 34),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: const Text(
                    '편집',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: YanoljaColors.primaryLight,
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
                border: Border.all(color: const Color(0xFFDCE5FF)),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.notifications_active_rounded,
                    color: YanoljaColors.primary,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '찜한 상품의 특가와 쿠폰 소식을 바로 확인해보세요',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: YanoljaColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(height: 8, color: YanoljaColors.surfaceAlt),
        ],
      ),
    );
  }

  Widget _buildSavedTab(
    String label, {
    required int count,
    bool selected = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
      decoration: BoxDecoration(
        color: selected ? YanoljaColors.textPrimary : YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      ),
      child: Text(
        '$label $count',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: selected ? Colors.white : YanoljaColors.textSecondary,
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
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 34),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final accommodation = savedAccommodations[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _buildDismissibleCard(context, ref, accommodation),
            );
          },
          childCount: savedAccommodations.length,
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
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          color: YanoljaColors.textPrimary,
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
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border, width: 1),
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
                    width: 112,
                    height: 112,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 112,
                      height: 112,
                      color: YanoljaColors.surfaceAlt,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 112,
                      height: 112,
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
                            : YanoljaColors.sale,
                        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                      ),
                      child: Text(
                        accommodation.isNew ? 'NOL특가' : '인기',
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
                            color: YanoljaColors.sale,
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
                          color: YanoljaColors.sale,
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
                  const SizedBox(height: 3),
                  const Text(
                    '쿠폰 적용가',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.primary,
                    ),
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
              '아직 찜한 상품이 없어요',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            const Text(
              'NOL 특가, 숙소, 티켓을 찜하고\n가격과 혜택을 한 번에 확인하세요.',
              style: TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 50,
              child: ElevatedButton.icon(
                onPressed: () => context.go('/home'),
                icon: const Icon(Icons.local_offer_rounded, size: 18),
                label: const Text(
                  'NOL 특가 보러가기',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: YanoljaColors.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  ),
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
    return showYanoljaConfirmDialog(
      context: context,
      icon: Icons.bookmark_remove_rounded,
      title: '찜 삭제',
      message: '$accommodationName을(를)\n찜 목록에서 삭제합니다.',
      confirmText: '찜 삭제',
      isDestructive: true,
    );
  }

  Future<void> _showClearAllDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showYanoljaConfirmDialog(
      context: context,
      icon: Icons.delete_sweep_rounded,
      title: '찜 목록을 비울까요?',
      message: '저장한 모든 숙소가 삭제됩니다.\n이 작업은 되돌릴 수 없어요.',
      confirmText: '모두 삭제',
      isDestructive: true,
    );
    if (!confirmed || !context.mounted) return;
    ref.read(savedProvider.notifier).clearAll();
    _showSnackBar(context, '모든 찜 목록이 삭제되었습니다.');
  }

  void _showSnackBar(BuildContext context, String message) {
    YanoljaToast.show(context, message);
  }
}
