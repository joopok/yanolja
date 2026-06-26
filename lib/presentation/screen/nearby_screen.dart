import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

class NearbyScreen extends ConsumerStatefulWidget {
  const NearbyScreen({super.key});

  @override
  ConsumerState<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends ConsumerState<NearbyScreen> {
  String _selectedCategory = '전체';
  String _locationLabel = '서울 시청';

  static const List<String> _categories = [
    '전체',
    '호텔/리조트',
    '펜션',
    '한옥',
    '쿠폰특가',
  ];

  @override
  Widget build(BuildContext context) {
    final accommodations = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      body: accommodations.when(
        data: (items) {
          final nearby = _filterNearby(items);

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              YanoljaSliverAppBar.main(
                title: '내주변',
                subtitle: '$_locationLabel 기준 가까운 숙소 ${nearby.length}곳',
                actions: [
                  _NearbyIconButton(
                    asset: _NearbyIcons.search,
                    tooltip: '검색',
                    onTap: () => context.go('/search'),
                  ),
                  _NearbyIconButton(
                    asset: _NearbyIcons.filter,
                    tooltip: '필터',
                    onTap: _showFilterSheet,
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: YanoljaEntrance(
                  delay: const Duration(milliseconds: 70),
                  child: _buildHeader(context),
                ),
              ),
              SliverToBoxAdapter(
                child: YanoljaEntrance(
                  delay: const Duration(milliseconds: 110),
                  child: _buildServiceTabs(context),
                ),
              ),
              SliverToBoxAdapter(
                child: YanoljaEntrance(
                  delay: const Duration(milliseconds: 150),
                  child: _buildLocationSearch(context),
                ),
              ),
              SliverToBoxAdapter(
                child: YanoljaEntrance(
                  delay: const Duration(milliseconds: 190),
                  child: _buildBenefitBanner(context),
                ),
              ),
              SliverToBoxAdapter(
                child: YanoljaEntrance(
                  delay: const Duration(milliseconds: 220),
                  child: _buildCategoryChips(),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildListHeader(context, nearby.length),
              ),
              if (nearby.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: _buildEmptyState(),
                )
              else
                SliverList.builder(
                  itemCount: nearby.length,
                  itemBuilder: (context, index) {
                    return YanoljaEntrance(
                      delay: YanoljaMotion.stagger(index, start: 180, step: 40),
                      child: AccommodationListItem(
                        accommodation: nearby[index],
                      ),
                    );
                  },
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 88)),
            ],
          );
        },
        loading: () => _buildLoadingSkeleton(),
        error: (error, _) => _buildError(ref),
      ),
    );
  }

  List<Accommodation> _filterNearby(List<Accommodation> items) {
    final sorted = [...items]
      ..sort((a, b) => a.distanceFromCenter.compareTo(b.distanceFromCenter));

    switch (_selectedCategory) {
      case '호텔/리조트':
        return sorted
            .where((item) => item.category == '호텔' || item.category == '리조트')
            .toList();
      case '펜션':
        return sorted.where((item) => item.category == '펜션').toList();
      case '한옥':
        return sorted
            .where((item) =>
                item.category.contains('한옥') || item.name.contains('한옥'))
            .toList();
      case '쿠폰특가':
        return sorted.where((item) => item.isPopular || item.isNew).toList();
      case '전체':
      default:
        return sorted;
    }
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.background,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFFFF),
            Color(0xFFF6F8FF),
          ],
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 2, 20, 16),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
            decoration: BoxDecoration(
              color: YanoljaColors.surface,
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              border: Border.all(color: YanoljaColors.primaryLight),
              boxShadow: [
                BoxShadow(
                  color: YanoljaColors.primary.withValues(alpha: 0.07),
                  blurRadius: 12,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _NearbyIcon(
                  asset: _NearbyIcons.distance,
                  size: 26,
                  color: YanoljaColors.primary,
                ),
                SizedBox(width: 7),
                Text(
                  '거리순 · 쿠폰특가 우선',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildServiceTabs(BuildContext context) {
    const tabs = [
      _NearServiceSpec('숙소', _NearbyIcons.stay),
      _NearServiceSpec('티켓', _NearbyIcons.ticket),
      _NearServiceSpec('맛집', _NearbyIcons.food),
      _NearServiceSpec('액티비티', _NearbyIcons.activity),
    ];

    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
      child: Row(
        children: [
          for (final tab in tabs) ...[
            Expanded(
              child: _NearServiceTab(
                label: tab.label,
                iconAsset: tab.iconAsset,
                selected: tab.label == '숙소',
                onTap: () => _handleServiceTab(tab.label),
              ),
            ),
            if (tab != tabs.last) const SizedBox(width: YanoljaSpacing.s),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationSearch(BuildContext context) {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: InkWell(
        onTap: _showLocationSheet,
        borderRadius: BorderRadius.circular(YanoljaRadius.xl),
        child: Container(
          padding: const EdgeInsets.fromLTRB(15, 14, 15, 15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(YanoljaRadius.xl),
            border: Border.all(color: YanoljaColors.primaryLight),
            boxShadow: [
              BoxShadow(
                color: YanoljaColors.primary.withValues(alpha: 0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const _NearbyIcon(
                    asset: _NearbyIcons.location,
                    size: 28,
                    color: YanoljaColors.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '현재 기준 위치',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.textTertiary,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '$_locationLabel 근처 숙소',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: YanoljaColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: YanoljaSpacing.s),
                    decoration: BoxDecoration(
                      color: YanoljaColors.primary,
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                    ),
                    child: const Text(
                      '변경',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 13),
              const Row(
                children: [
                  Expanded(
                    child: _NearbyMetric(
                      iconAsset: _NearbyIcons.distance,
                      label: '추천 반경',
                      value: '2km',
                    ),
                  ),
                  SizedBox(width: YanoljaSpacing.s),
                  Expanded(
                    child: _NearbyMetric(
                      iconAsset: _NearbyIcons.coupon,
                      label: '혜택',
                      value: '쿠폰 우선',
                    ),
                  ),
                  SizedBox(width: YanoljaSpacing.s),
                  Expanded(
                    child: _NearbyMetric(
                      iconAsset: _NearbyIcons.map,
                      label: '보기',
                      value: '지도 연결',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBenefitBanner(BuildContext context) {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 18),
      child: InkWell(
        onTap: () => context.push('/service/deals'),
        borderRadius: BorderRadius.circular(YanoljaRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFFFFF),
                Color(0xFFF3F6FF),
              ],
            ),
            borderRadius: BorderRadius.circular(YanoljaRadius.xl),
            border: Border.all(color: YanoljaColors.primaryLight),
          ),
          child: Row(
            children: [
              const _NearbyIcon(
                asset: _NearbyIcons.coupon,
                size: 28,
                color: YanoljaColors.primary,
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '가까운 순 NOL특가',
                      style: TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w900,
                        color: YanoljaColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      '쿠폰 적용가와 거리 정보를 함께 확인하세요',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: YanoljaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const _NearbyIcon(
                asset: _NearbyIcons.chevron,
                size: 28,
                color: YanoljaColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 0, 16),
      child: SizedBox(
        height: 42,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: YanoljaSpacing.s),
          itemBuilder: (context, index) {
            final category = _categories[index];
            final selected = category == _selectedCategory;
            return YanoljaPressable(
              pressedScale: 0.97,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _selectedCategory = category);
              },
              child: AnimatedContainer(
                duration: YanoljaMotion.base,
                curve: YanoljaMotion.curve,
                alignment: Alignment.center,
                padding: const EdgeInsets.only(left: 9, right: 14),
                decoration: BoxDecoration(
                  color: selected ? YanoljaColors.primary : Colors.white,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                  border: Border.all(
                    color: selected
                        ? YanoljaColors.primary
                        : YanoljaColors.border,
                  ),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color:
                                YanoljaColors.primary.withValues(alpha: 0.1),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _NearbyIcon(
                      asset: _categoryIcon(category),
                      size: 26,
                      color:
                          selected ? Colors.white : YanoljaColors.textSecondary,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: selected
                            ? Colors.white
                            : YanoljaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  IconData _categoryIcon(String category) {
    switch (category) {
      case '호텔/리조트':
      case '펜션':
      case '한옥':
        return _NearbyIcons.stay;
      case '쿠폰특가':
        return _NearbyIcons.coupon;
      case '전체':
      default:
        return _NearbyIcons.distance;
    }
  }

  Widget _buildListHeader(BuildContext context, int count) {
    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        border: Border(top: BorderSide(color: YanoljaColors.divider)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
      child: Row(
        children: [
          const _NearbyIcon(
            asset: _NearbyIcons.distance,
            size: 30,
            color: YanoljaColors.primary,
          ),
          const SizedBox(width: YanoljaSpacing.s),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.textPrimary,
                ),
                children: [
                  const TextSpan(text: '가까운 숙소 '),
                  TextSpan(
                    text: '$count',
                    style: const TextStyle(color: YanoljaColors.primary),
                  ),
                ],
              ),
            ),
          ),
          TextButton.icon(
            onPressed: () => context.push('/map'),
            style: TextButton.styleFrom(
              foregroundColor: YanoljaColors.textPrimary,
              padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.s),
              minimumSize: const Size(0, 36),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            icon: const _NearbyIcon(
              asset: _NearbyIcons.map,
              size: 24,
              color: YanoljaColors.textPrimary,
            ),
            label: const Text(
              '지도',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _NearbyIcon(
              asset: _NearbyIcons.empty,
              size: 94,
              color: YanoljaColors.textTertiary,
            ),
            const SizedBox(height: 18),
            const Text(
              '조건에 맞는 주변 숙소가 없어요',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: YanoljaSpacing.s),
            const Text(
              '다른 카테고리로 다시 확인해보세요',
              style: TextStyle(
                fontSize: 13.5,
                color: YanoljaColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        YanoljaSliverAppBar.main(
          title: '내주변',
          subtitle: '$_locationLabel 기준 가까운 숙소를 찾고 있어요',
          actions: [
            _NearbyIconButton(
              asset: _NearbyIcons.search,
              tooltip: '검색',
              onTap: () => context.go('/search'),
            ),
            _NearbyIconButton(
              asset: _NearbyIcons.filter,
              tooltip: '필터',
              onTap: _showFilterSheet,
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Shimmer.fromColors(
            baseColor: YanoljaColors.border,
            highlightColor: const Color(0xFFF7F8FA),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Column(
                children: [
                  for (var i = 0; i < 4; i++)
                    Container(
                      height: 132,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(YanoljaRadius.lg),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildError(WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const _NearbyIcon(
              asset: _NearbyIcons.error,
              size: 88,
              color: YanoljaColors.textTertiary,
            ),
            const SizedBox(height: 12),
            const Text(
              '주변 숙소를 불러오지 못했어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: YanoljaSpacing.m),
            ElevatedButton(
              onPressed: () => ref.invalidate(accommodationListProvider),
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _NearbyIcon(
                    asset: _NearbyIcons.refresh,
                    size: 22,
                    color: Colors.white,
                  ),
                  SizedBox(width: 6),
                  Text('다시 시도'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleServiceTab(String tab) {
    HapticFeedback.selectionClick();
    switch (tab) {
      case '숙소':
        return;
      case '티켓':
        context.push('/service/leisure');
        return;
      case '맛집':
        context.push('/masgib');
        return;
      case '액티비티':
        context.push('/service/leisure');
        return;
    }
  }

  void _showFilterSheet() {
    var selectedCategory = _selectedCategory;

    showModalBottomSheet<void>(
      context: context,
      // 루트 네비게이터에 띄워 하단 탭바 위로 올린다(탭 메뉴 가림).
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: const BoxDecoration(
                color: YanoljaColors.background,
                borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 42,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 18),
                      decoration: BoxDecoration(
                        color: YanoljaColors.border,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  const Row(
                    children: [
                      _NearbyIcon(
                        asset: _NearbyIcons.filter,
                        size: 32,
                        color: YanoljaColors.textPrimary,
                      ),
                      SizedBox(width: YanoljaSpacing.s),
                      Text(
                        '내 주변 조건',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '현재 위치 기준으로 $_selectedCategory 카테고리를 보고 있어요',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _categories.map((category) {
                      final selected = selectedCategory == category;
                      return ChoiceChip(
                        avatar: _NearbyIcon(
                          asset: _categoryIcon(category),
                          size: 22,
                          color:
                              selected ? Colors.white : YanoljaColors.primary,
                        ),
                        label: Text(category),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: YanoljaColors.primary,
                        backgroundColor: YanoljaColors.surfaceAlt,
                        side: BorderSide(
                          color: selected
                              ? YanoljaColors.primary
                              : YanoljaColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : YanoljaColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (_) {
                          setModalState(() => selectedCategory = category);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      onPressed: () {
                        setState(() => _selectedCategory = selectedCategory);
                        Navigator.pop(context);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: YanoljaColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(YanoljaRadius.md),
                        ),
                      ),
                      child: const Text(
                        '적용하기',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showLocationSheet() {
    const locations = [
      '서울 시청',
      '강남역',
      '홍대입구',
      '부산 해운대',
      '제주 공항',
    ];

    showModalBottomSheet<void>(
      context: context,
      // 루트 네비게이터에 띄워 하단 탭바 위로 올린다(탭 메뉴 가림).
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: const BoxDecoration(
            color: YanoljaColors.background,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 42,
                height: 4,
                margin: const EdgeInsets.only(bottom: 18),
                decoration: BoxDecoration(
                  color: YanoljaColors.border,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
              const Row(
                children: [
                  _NearbyIcon(
                    asset: _NearbyIcons.location,
                    size: 34,
                    color: YanoljaColors.primary,
                  ),
                  SizedBox(width: 10),
                  Text(
                    '위치 기준 변경',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              for (final location in locations)
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: _NearbyIcon(
                      asset: location == _locationLabel
                          ? _NearbyIcons.check
                          : _NearbyIcons.place,
                      size: 34,
                      color: location == _locationLabel
                          ? YanoljaColors.primary
                          : YanoljaColors.textTertiary,
                    ),
                    title: Text(
                      '$location 근처',
                      style: TextStyle(
                        fontWeight: location == _locationLabel
                            ? FontWeight.w900
                            : FontWeight.w700,
                        color: YanoljaColors.textPrimary,
                      ),
                    ),
                    onTap: () {
                      setState(() => _locationLabel = location);
                      Navigator.pop(context);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _NearServiceTab extends StatelessWidget {
  final String label;
  final IconData iconAsset;
  final bool selected;
  final VoidCallback onTap;

  const _NearServiceTab({
    required this.label,
    required this.iconAsset,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      onTap: onTap,
      pressedScale: 0.97,
      child: AnimatedContainer(
        duration: YanoljaMotion.base,
        curve: YanoljaMotion.curve,
        height: 78,
        padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.s, vertical: YanoljaSpacing.s),
        decoration: BoxDecoration(
          color: selected ? YanoljaColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(
            color: selected ? YanoljaColors.primary : YanoljaColors.border,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: YanoljaColors.primary.withValues(alpha: 0.12),
                    blurRadius: 14,
                    offset: const Offset(0, 7),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedScale(
              scale: selected ? 1.08 : 1.0,
              duration: YanoljaMotion.base,
              curve: YanoljaMotion.curve,
              child: _NearbyIcon(
                asset: iconAsset,
                size: 34,
                color: selected ? Colors.white : YanoljaColors.primary,
              ),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w900,
                  color: selected ? Colors.white : YanoljaColors.textSecondary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NearServiceSpec {
  final String label;
  final IconData iconAsset;

  const _NearServiceSpec(this.label, this.iconAsset);
}

/// 내주변 화면 아이콘 토큰.
/// 메인화면과 동일한 플랫 라인(Material rounded) 톤으로 통일한다.
class _NearbyIcons {
  static const search = Icons.search_rounded;
  static const filter = Icons.tune_rounded;
  static const stay = Icons.king_bed_rounded;
  static const ticket = Icons.confirmation_number_rounded;
  static const food = Icons.restaurant_rounded;
  static const activity = Icons.hiking_rounded;
  static const location = Icons.my_location_rounded;
  static const coupon = Icons.local_offer_rounded;
  static const map = Icons.map_rounded;
  static const empty = Icons.location_off_rounded;
  static const error = Icons.error_outline_rounded;
  static const check = Icons.check_circle_rounded;
  static const place = Icons.place_outlined;
  static const chevron = Icons.chevron_right_rounded;
  static const distance = Icons.near_me_rounded;
  static const refresh = Icons.refresh_rounded;
}

class _NearbyIcon extends StatelessWidget {
  final IconData asset;
  final double size;
  final Color color;

  const _NearbyIcon({
    required this.asset,
    required this.size,
    this.color = YanoljaColors.textPrimary,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(asset, size: size, color: color);
  }
}

/// 앱바 우측 액션 아이콘. 메인화면 헤더 아이콘과 동일하게
/// 배경 없는 검은색 라인 아이콘(size 24)으로 표시한다.
class _NearbyIconButton extends StatelessWidget {
  final IconData asset;
  final String tooltip;
  final VoidCallback onTap;

  const _NearbyIconButton({
    required this.asset,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(YanoljaSpacing.s),
          child: Icon(asset, color: YanoljaColors.textPrimary, size: 24),
        ),
      ),
    );
  }
}

class _NearbyMetric extends StatelessWidget {
  final IconData iconAsset;
  final String label;
  final String value;

  const _NearbyMetric({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.s),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NearbyIcon(
            asset: iconAsset,
            size: 28,
            color: YanoljaColors.primary,
          ),
          const SizedBox(width: 5),
          Flexible(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textTertiary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
