import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

typedef AccommodationMatcher = bool Function(Accommodation accommodation);
typedef AccommodationFilterMatcher = bool Function(
  Accommodation accommodation,
  String filter,
);

bool nolAccommodationContains(
  Accommodation accommodation,
  Iterable<String> terms,
) {
  final searchable = <String?>[
    accommodation.name,
    accommodation.address,
    accommodation.description,
    accommodation.category,
    accommodation.theme,
    accommodation.tags?.join(' '),
    accommodation.amenities.join(' '),
  ].whereType<String>().join(' ').toLowerCase();

  return terms.any((term) => searchable.contains(term.toLowerCase()));
}

class NolCategoryListScreen extends ConsumerStatefulWidget {
  final String title;
  final String serviceLabel;
  final String heroTitle;
  final String heroSubtitle;
  final IconData heroIcon;
  final Color accentColor;
  final List<String> filters;
  final String initialFilter;
  final AccommodationMatcher baseFilter;
  final AccommodationFilterMatcher filterPredicate;
  final IconData emptyIcon;
  final String emptyTitle;

  const NolCategoryListScreen({
    super.key,
    required this.title,
    required this.serviceLabel,
    required this.heroTitle,
    required this.heroSubtitle,
    required this.heroIcon,
    required this.filters,
    required this.baseFilter,
    required this.filterPredicate,
    required this.emptyIcon,
    required this.emptyTitle,
    this.accentColor = YanoljaColors.primary,
    this.initialFilter = '전체',
  });

  @override
  ConsumerState<NolCategoryListScreen> createState() =>
      _NolCategoryListScreenState();
}

class _NolCategoryListScreenState extends ConsumerState<NolCategoryListScreen> {
  late String _selectedFilter;
  String _sortBy = '추천순';

  static const List<String> _sortOptions = [
    '추천순',
    '낮은가격순',
    '높은가격순',
    '평점순',
    '거리순',
  ];

  @override
  void initState() {
    super.initState();
    _selectedFilter = widget.initialFilter;
  }

  @override
  void didUpdateWidget(covariant NolCategoryListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialFilter != widget.initialFilter) {
      _selectedFilter = widget.initialFilter;
    }
  }

  @override
  Widget build(BuildContext context) {
    final accommodationsAsync = ref.watch(accommodationListProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 0),
      appBar: YanoljaAppBar.sub(
        title: widget.title,
        actions: [
          IconButton(
            tooltip: '검색',
            icon: const Icon(Icons.search_rounded),
            onPressed: () => context.go('/search'),
          ),
          IconButton(
            tooltip: '필터',
            icon: const Icon(Icons.tune_rounded),
            onPressed: _showAdvancedFilterSheet,
          ),
        ],
      ),
      body: accommodationsAsync.when(
        loading: () => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeaderPanel()),
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: CircularProgressIndicator(
                  color: YanoljaColors.primary,
                ),
              ),
            ),
          ],
        ),
        error: (error, stackTrace) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildHeaderPanel()),
            SliverFillRemaining(
              hasScrollBody: false,
              child: _buildErrorState(error),
            ),
          ],
        ),
        data: (accommodations) {
          final filtered = _filterAndSort(accommodations);

          return RefreshIndicator(
            color: YanoljaColors.primary,
            onRefresh: _refresh,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(child: _buildHeaderPanel()),
                SliverToBoxAdapter(
                  child: YanoljaEntrance(
                    delay: const Duration(milliseconds: 90),
                    child: _buildCountAndSortRow(filtered),
                  ),
                ),
                if (filtered.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _buildEmptyState(),
                  )
                else
                  SliverList.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return AccommodationListItem(
                        accommodation: filtered[index],
                      );
                    },
                  ),
                SliverToBoxAdapter(
                  child: const SizedBox(height: 28),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  List<Accommodation> _filterAndSort(List<Accommodation> accommodations) {
    final results = accommodations.where(widget.baseFilter).where((item) {
      if (_selectedFilter == '전체') return true;
      return widget.filterPredicate(item, _selectedFilter);
    }).toList();

    switch (_sortBy) {
      case '낮은가격순':
        results.sort((a, b) => a.price.compareTo(b.price));
        break;
      case '높은가격순':
        results.sort((a, b) => b.price.compareTo(a.price));
        break;
      case '평점순':
        results.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case '거리순':
        results.sort(
          (a, b) => a.distanceFromCenter.compareTo(b.distanceFromCenter),
        );
        break;
      case '추천순':
      default:
        results
            .sort((a, b) => _recommendScore(b).compareTo(_recommendScore(a)));
        break;
    }

    return results;
  }

  int _recommendScore(Accommodation accommodation) {
    return (accommodation.isPopular ? 1000 : 0) +
        (accommodation.isNew ? 500 : 0) +
        (accommodation.rating * 100).round() +
        accommodation.reviewCount;
  }

  Future<void> _refresh() async {
    ref.invalidate(accommodationListProvider);
    await ref.read(accommodationListProvider.future);
  }

  void _handleShortcutTap(String label) {
    switch (label) {
      case '홈':
        context.go('/home');
        return;
      case '티켓':
        context.push('/service/leisure');
        return;
      case '쿠폰·혜택':
        context.push('/service/coupons');
        return;
      case '특가':
        context.push('/service/deals');
        return;
    }
  }

  void _showAdvancedFilterSheet() {
    var selectedFilter = _selectedFilter;
    var selectedSort = _sortBy;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              margin: const EdgeInsets.all(12),
              padding: EdgeInsets.fromLTRB(
                20,
                10,
                20,
                20 + MediaQuery.paddingOf(context).bottom,
              ),
              decoration: BoxDecoration(
                color: YanoljaColors.background,
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: YanoljaColors.shadow,
                    blurRadius: 24,
                    offset: Offset(0, 10),
                  ),
                ],
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
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: widget.accentColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(YanoljaRadius.md),
                        ),
                        child: Icon(
                          Icons.tune_rounded,
                          color: widget.accentColor,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${widget.serviceLabel} 상세 조건',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: YanoljaColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              '테마와 정렬 기준을 한 번에 조정하세요',
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: FontWeight.w700,
                                color: YanoljaColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '테마',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.filters.map((filter) {
                      final selected = selectedFilter == filter;
                      return ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: widget.accentColor,
                        backgroundColor: YanoljaColors.surfaceAlt,
                        side: BorderSide(
                          color: selected
                              ? widget.accentColor
                              : YanoljaColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : YanoljaColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (_) {
                          setModalState(() => selectedFilter = filter);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    '정렬',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _sortOptions.map((sort) {
                      final selected = selectedSort == sort;
                      return ChoiceChip(
                        avatar: selected
                            ? const Icon(
                                Icons.check_rounded,
                                size: 16,
                                color: Colors.white,
                              )
                            : null,
                        label: Text(sort),
                        selected: selected,
                        showCheckmark: false,
                        selectedColor: YanoljaColors.textPrimary,
                        backgroundColor: YanoljaColors.surfaceAlt,
                        side: BorderSide(
                          color: selected
                              ? YanoljaColors.textPrimary
                              : YanoljaColors.border,
                        ),
                        labelStyle: TextStyle(
                          color: selected
                              ? Colors.white
                              : YanoljaColors.textPrimary,
                          fontWeight: FontWeight.w800,
                        ),
                        onSelected: (_) {
                          setModalState(() => selectedSort = sort);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setModalState(() {
                              selectedFilter = widget.filters.first;
                              selectedSort = _sortOptions.first;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            side: const BorderSide(color: YanoljaColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.md),
                            ),
                          ),
                          child: const Text(
                            '초기화',
                            style: TextStyle(fontWeight: FontWeight.w900),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        flex: 2,
                        child: FilledButton(
                          onPressed: () {
                            setState(() {
                              _selectedFilter = selectedFilter;
                              _sortBy = selectedSort;
                            });
                            Navigator.pop(context);
                          },
                          style: FilledButton.styleFrom(
                            backgroundColor: widget.accentColor,
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.md),
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
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildHeaderPanel() {
    return Container(
      color: YanoljaColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          YanoljaEntrance(child: _buildSearchPill()),
          YanoljaEntrance(
            delay: const Duration(milliseconds: 50),
            child: _buildShortcutTabs(),
          ),
          YanoljaEntrance(
            delay: const Duration(milliseconds: 90),
            child: _buildBenefitBanner(),
          ),
          YanoljaEntrance(
            delay: const Duration(milliseconds: 130),
            child: _buildFilterBar(),
          ),
          const SizedBox(height: 6),
        ],
      ),
    );
  }

  Widget _buildSearchPill() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: YanoljaPressable(
        onTap: () => context.go('/search'),
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          decoration: BoxDecoration(
            color: YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(YanoljaRadius.md),
            border: Border.all(color: YanoljaColors.border),
          ),
          child: const Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: YanoljaColors.textSecondary,
                size: 22,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  '지역명, 숙소명을 검색해보세요',
                  style: TextStyle(
                    fontSize: 14,
                    color: YanoljaColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '6.19 금 · 1박',
                style: TextStyle(
                  fontSize: 12,
                  color: YanoljaColors.textTertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildShortcutTabs() {
    const shortcuts = [
      _NolShortcut('홈', Icons.home_rounded),
      _NolShortcut('티켓', Icons.confirmation_number_rounded),
      _NolShortcut('쿠폰·혜택', Icons.local_offer_rounded),
      _NolShortcut('특가', Icons.bolt_rounded),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: shortcuts.map((shortcut) {
          final isHome = shortcut.label == '홈';
          return Expanded(
            child: YanoljaPressable(
              onTap: () => _handleShortcutTap(shortcut.label),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    shortcut.icon,
                    color: isHome
                        ? YanoljaColors.primary
                        : YanoljaColors.textPrimary,
                    size: 22,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    shortcut.label,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isHome
                          ? YanoljaColors.primary
                          : YanoljaColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBenefitBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: YanoljaPressable(
        onTap: () => context.push('/service/coupons'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.accentColor,
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
                child: Icon(
                  widget.heroIcon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.heroTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.heroSubtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Colors.white.withValues(alpha: 0.86),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
                child: Text(
                  '쿠폰받기',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: widget.accentColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: widget.filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final filter = widget.filters[index];
          final selected = _selectedFilter == filter;

          return YanoljaPressable(
            pressedScale: 0.985,
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: YanoljaMotion.base,
              curve: YanoljaMotion.curve,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? YanoljaColors.textPrimary : Colors.white,
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                border: Border.all(
                  color: selected
                      ? YanoljaColors.textPrimary
                      : YanoljaColors.border,
                ),
              ),
              child: Text(
                filter,
                style: TextStyle(
                  color: selected ? Colors.white : YanoljaColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCountAndSortRow(List<Accommodation> filtered) {
    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(20, 14, 16, 2),
      child: Row(
        children: [
          Expanded(
            child: Text(
              '총 ${filtered.length}개 숙소',
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
              ),
            ),
          ),
          PopupMenuButton<String>(
            initialValue: _sortBy,
            color: YanoljaColors.background,
            surfaceTintColor: YanoljaColors.background,
            position: PopupMenuPosition.under,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            onSelected: (value) => setState(() => _sortBy = value),
            itemBuilder: (context) => _sortOptions.map((option) {
              final selected = _sortBy == option;
              return PopupMenuItem(
                value: option,
                child: Row(
                  children: [
                    Icon(
                      selected ? Icons.check_rounded : Icons.circle_outlined,
                      size: 18,
                      color:
                          selected ? YanoljaColors.primary : Colors.transparent,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option,
                      style: TextStyle(
                        color: selected
                            ? YanoljaColors.primary
                            : YanoljaColors.textPrimary,
                        fontWeight:
                            selected ? FontWeight.w900 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _sortBy,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    size: 18,
                    color: YanoljaColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            widget.emptyIcon,
            size: 58,
            color: YanoljaColors.textTertiary,
          ),
          const SizedBox(height: 16),
          Text(
            widget.emptyTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            '조건을 바꾸면 더 많은 숙소를 볼 수 있어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: YanoljaColors.textSecondary,
              height: 1.35,
            ),
          ),
          if (_selectedFilter != '전체') ...[
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: () => setState(() => _selectedFilter = '전체'),
              style: OutlinedButton.styleFrom(
                foregroundColor: YanoljaColors.primary,
                side: const BorderSide(color: YanoljaColors.primary),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
              child: const Text(
                '전체 보기',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 34, 32, 48),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            size: 58,
            color: YanoljaColors.textTertiary,
          ),
          const SizedBox(height: 16),
          const Text(
            '숙소 정보를 불러오지 못했어요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
            ),
          ),
          const SizedBox(height: 7),
          Text(
            '$error',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: YanoljaColors.textTertiary,
              height: 1.35,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () => ref.invalidate(accommodationListProvider),
            style: FilledButton.styleFrom(
              backgroundColor: YanoljaColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
            ),
            child: const Text(
              '다시 시도',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _NolShortcut {
  final String label;
  final IconData icon;

  const _NolShortcut(this.label, this.icon);
}
