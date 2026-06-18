import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';

class NearbyScreen extends ConsumerWidget {
  const NearbyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accommodations = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(context),
            _buildLocationCard(context),
            Expanded(
              child: accommodations.when(
                data: _buildNearbyList,
                loading: () => const Center(
                  child:
                      CircularProgressIndicator(color: YanoljaColors.primary),
                ),
                error: (error, _) => _buildError(ref),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 12, 10),
      decoration: const BoxDecoration(
        color: YanoljaColors.background,
        border: Border(
          bottom: BorderSide(color: YanoljaColors.border, width: 1),
        ),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text(
              '내 주변',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          IconButton(
            onPressed: () => _showSoon(context, '필터'),
            icon: const Icon(
              Icons.tune_rounded,
              color: YanoljaColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [YanoljaColors.primary, YanoljaColors.primaryPurple],
        ),
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            child: const Icon(
              Icons.near_me_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '서울 시청 기준 가까운 숙소',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  '거리순으로 바로 예약 가능한 곳을 보여드려요',
                  style: TextStyle(
                    color: Color(0xCCFFFFFF),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _showSoon(context, '위치 재설정'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: Colors.white.withValues(alpha: 0.16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('변경'),
          ),
        ],
      ),
    );
  }

  Widget _buildNearbyList(List<Accommodation> items) {
    final nearby = [...items]
      ..sort((a, b) => a.distanceFromCenter.compareTo(b.distanceFromCenter));

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 18),
      itemCount: nearby.length,
      itemBuilder: (context, index) {
        return AccommodationListItem(accommodation: nearby[index]);
      },
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              color: YanoljaColors.textTertiary,
              size: 42,
            ),
            const SizedBox(height: 12),
            const Text(
              '주변 숙소를 불러오지 못했어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: () => ref.invalidate(accommodationListProvider),
              child: const Text('다시 시도'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSoon(BuildContext context, String label) {
    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label 기능은 준비 중이에요'),
          duration: const Duration(seconds: 1),
        ),
      );
  }
}
