import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final savedIds = ref.watch(savedProvider);
    final allAccommodationsAsync = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: allAccommodationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => _buildErrorState(context, ref, err.toString()),
        data: (allAccommodations) {
          final savedAccommodations = allAccommodations
              .where((acc) => savedIds.contains(acc.id))
              .toList();

          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, savedAccommodations.length),
              if (savedAccommodations.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(context))
              else
                _buildSavedList(context, ref, savedAccommodations),
            ],
          );
        },
      ),
      floatingActionButton: savedIds.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => _showClearAllDialog(context, ref),
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: Colors.white,
              elevation: 4,
              icon: const Icon(Icons.delete_sweep_outlined),
              label: const Text('전체 삭제'),
            )
          : null,
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, int count) {
    final theme = Theme.of(context);
    return SliverAppBar(
      expandedHeight: 120,
      pinned: true,
      floating: true,
      snap: true,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: false,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: RichText(
          text: TextSpan(
            style: theme.textTheme.titleLarge?.copyWith(color: theme.colorScheme.onSurface),
            children: [
              const TextSpan(text: '찜 목록 '),
              TextSpan(
                text: '$count',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.secondary.withOpacity(0.8),
              ],
            ),
          ),
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
      padding: const EdgeInsets.only(top: 8, bottom: 100),
      sliver: AnimationLimiter(
        child: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final accommodation = savedAccommodations[index];
              return AnimationConfiguration.staggeredList(
                position: index,
                duration: const Duration(milliseconds: 400),
                child: SlideAnimation(
                  verticalOffset: 50.0,
                  child: FadeInAnimation(
                    child: _buildDismissibleCard(context, ref, accommodation),
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
    final theme = Theme.of(context);
    return Dismissible(
      key: Key(accommodation.id),
      direction: DismissDirection.endToStart,
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: theme.colorScheme.errorContainer,
        ),
        alignment: Alignment.centerRight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.delete_sweep_outlined, color: theme.colorScheme.onErrorContainer, size: 28),
            const SizedBox(height: 4),
            Text('삭제', style: TextStyle(color: theme.colorScheme.onErrorContainer, fontWeight: FontWeight.bold)),
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
        onTap: () => context.push('/detail/${accommodation.id}'),
        child: Hero(
          tag: 'saved-${accommodation.id}',
          child: AccommodationListItem(accommodation: accommodation),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primary.withOpacity(0.1),
              ),
              child: Icon(Icons.favorite_border_rounded, color: theme.colorScheme.primary, size: 60),
            ),
            const SizedBox(height: 24),
            Text('찜한 숙소가 없어요', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              '마음에 드는 숙소를 찜하고\n나중에 편하게 확인하세요.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home_outlined),
              label: const Text('홈으로 가기'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, WidgetRef ref, String error) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 60),
            const SizedBox(height: 24),
            Text('데이터를 불러올 수 없어요', style: theme.textTheme.headlineSmall, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            Text(
              '네트워크 연결을 확인하거나\n잠시 후 다시 시도해 주세요.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => ref.refresh(accommodationListProvider),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool?> _showRemoveDialog(BuildContext context, String accommodationName) {
    final theme = Theme.of(context);
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [Icon(Icons.delete_outline_rounded), SizedBox(width: 8), Text('찜 삭제')],
          ),
          content: Text('$accommodationName을(를) 정말 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _showClearAllDialog(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [Icon(Icons.delete_sweep_outlined), SizedBox(width: 8), Text('전체 삭제')],
          ),
          content: const Text('찜한 모든 숙소를 삭제할까요?\n이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(savedProvider.notifier).clearAll();
                Navigator.of(context).pop();
                _showSnackBar(context, '모든 찜 목록이 삭제되었습니다.');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
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
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}