import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/search_provider.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/screen/map_screen.dart';
import 'package:yanolja_clone/presentation/widget/animated_search_field.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

enum SearchDisplayMode { list, map }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final GlobalKey<AnimatedSearchFieldState> _searchFieldKey =
      GlobalKey<AnimatedSearchFieldState>();

  SearchDisplayMode _displayMode = SearchDisplayMode.list;

  @override
  void initState() {
    super.initState();

    // 검색 기능 설정
    _searchController.addListener(() {
      ref.read(searchProvider.notifier).updateQuery(_searchController.text);
    });

    _searchFocusNode.addListener(() {
      if (!_searchFocusNode.hasFocus) {
        FocusManager.instance.primaryFocus?.unfocus();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearch(String query) {
    _searchController.text = query;
    ref.read(searchProvider.notifier).updateQuery(query);
    _searchFocusNode.unfocus();
    if (query.trim().isNotEmpty) {
      ref.read(searchProvider.notifier).addRecentSearch(query.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    // 홈·더보기 검색바의 마이크 탭 시그널을 받으면 음성 검색을 시작한다.
    ref.listen<int>(voiceSearchSignalProvider, (previous, next) {
      if (previous != next && next > 0) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _searchFieldKey.currentState?.startVoiceSearch();
        });
      }
    });

    final searchState = ref.watch(searchProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final suggestedSearches = ref.watch(suggestedSearchesProvider);
    final popularSearches = ref.watch(popularSearchesProvider);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: YanoljaColors.surfaceAlt,
        appBar: YanoljaAppBar.main(
          title: '검색',
          subtitle: '숙소부터 공연까지 한 번에',
          actions: [
            IconButton(
              onPressed: () => _openService('coupons'),
              tooltip: '쿠폰·혜택',
              icon: const Icon(
                Icons.card_giftcard_outlined,
                color: YanoljaColors.textPrimary,
                size: 24,
              ),
            ),
          ],
        ),
        body: Column(
          children: [
            YanoljaEntrance(
              child: Container(
                color: YanoljaColors.background,
                child: AnimatedSearchField(
                  key: _searchFieldKey,
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  onChanged: (query) {
                    ref.read(searchProvider.notifier).updateQuery(query);
                  },
                  onSubmitted: _handleSearch,
                  onClear: () {
                    ref.read(searchProvider.notifier).updateQuery('');
                  },
                  suggestions: _getAutocompleteSuggestions(searchState.query),
                  onSuggestionTap: _handleSearch,
                ),
              ),
            ),
            if (searchState.query.isNotEmpty)
              YanoljaEntrance(
                delay: const Duration(milliseconds: 60),
                beginOffset: const Offset(0, 0.025),
                child: _buildDisplayModeToggle(),
              ),
            Expanded(
              child: searchState.query.isEmpty
                  ? _buildSuggestions(
                      context, searchState, suggestedSearches, popularSearches)
                  : _displayMode == SearchDisplayMode.list
                      ? _buildSearchResults()
                      : _buildMapResults(searchResults),
            ),
          ],
        ),
      ),
    );
  }

  void _selectDisplayMode(SearchDisplayMode mode) {
    if (_displayMode == mode) return;
    setState(() {
      _displayMode = mode;
    });
    HapticFeedback.lightImpact();
  }

  /// 🔍 자동완성 제안 생성
  List<String> _getAutocompleteSuggestions(String query) {
    if (query.isEmpty) return [];

    final allSuggestions = [
      '콘서트',
      '뮤지컬',
      '제주 숙소',
      '도쿄 항공권',
      '부산 오션뷰',
      '서울 호캉스',
      '강릉 펜션',
      '호텔',
      '펜션',
      '리조트',
      '프리미엄 숙소',
      '글램핑',
      '워터파크',
      '전시',
      '액티비티',
      '쿠폰 혜택',
    ];

    return allSuggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  /// 목록 / 지도 세그먼트
  Widget _buildDisplayModeToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(YanoljaSpacing.xs),
            decoration: BoxDecoration(
              color: YanoljaColors.surfaceAlt,
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              border: Border.all(color: YanoljaColors.border, width: 1),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(
                  Icons.view_list_rounded,
                  '목록',
                  _displayMode == SearchDisplayMode.list,
                  () => _selectDisplayMode(SearchDisplayMode.list),
                ),
                _buildToggleButton(
                  Icons.map_rounded,
                  '지도',
                  _displayMode == SearchDisplayMode.map,
                  () => _selectDisplayMode(SearchDisplayMode.map),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.m, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected ? YanoljaColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : YanoljaColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: isSelected ? Colors.white : YanoljaColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 검색어 없을 때: NOL 서비스 허브
  Widget _buildSuggestions(
    BuildContext context,
    SearchState searchState,
    List<String> suggestedSearches,
    List<String> popularSearches,
  ) {
    final shortcuts = [
      const _SearchShortcut(
        label: '숙소',
        assetPath: 'assets/search_icons/stay.png',
        subtitle: '국내 숙소',
        route: '/hotelSearch',
      ),
      const _SearchShortcut(
        label: '항공',
        assetPath: 'assets/search_icons/flight.png',
        subtitle: '항공권',
        route: '/service/flight',
      ),
      const _SearchShortcut(
        label: '티켓',
        assetPath: 'assets/search_icons/ticket.png',
        subtitle: '레저·입장권',
        route: '/service/leisure',
      ),
      const _SearchShortcut(
        label: '쿠폰·혜택',
        assetPath: 'assets/search_icons/coupon.png',
        subtitle: '할인 모음',
        route: '/service/coupons',
      ),
      const _SearchShortcut(
        label: '액티비티',
        assetPath: 'assets/search_icons/activity.png',
        subtitle: '놀거리',
        route: '/service/leisure',
      ),
      const _SearchShortcut(
        label: '공연·전시',
        assetPath: 'assets/search_icons/culture.png',
        subtitle: '컬처',
        route: '/service/performance',
      ),
    ];

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      children: [
        YanoljaEntrance(child: _buildShortcutGrid(shortcuts)),
        if (searchState.recentSearches.isNotEmpty) ...[
          const SizedBox(height: 22),
          YanoljaEntrance(
            delay: const Duration(milliseconds: 70),
            child: _buildRecentSection(searchState.recentSearches),
          ),
        ],
        const SizedBox(height: 22),
        YanoljaEntrance(
          delay: const Duration(milliseconds: 110),
          child: _buildPopularRanking(popularSearches),
        ),
        const SizedBox(height: 22),
        YanoljaEntrance(
          delay: const Duration(milliseconds: 160),
          child: _buildSuggestChips(suggestedSearches),
        ),
      ],
    );
  }

  Widget _buildShortcutGrid(List<_SearchShortcut> shortcuts) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
      decoration: BoxDecoration(
        color: YanoljaColors.background,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(2, 0, 2, 12),
            child: Text(
              '무엇을 찾으세요?',
              style: TextStyle(
                color: YanoljaColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 0.78,
            ),
            itemCount: shortcuts.length,
            itemBuilder: (context, index) {
              final item = shortcuts[index];
              return YanoljaEntrance(
                delay: YanoljaMotion.stagger(index, start: 0, step: 22),
                beginOffset: const Offset(0, 0.03),
                child: YanoljaPressable(
                  onTap: () => _openShortcut(item),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.asset(
                            item.assetPath,
                            width: 62,
                            height: 62,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stack) => Container(
                              width: 62,
                              height: 62,
                              color: YanoljaColors.surfaceAlt,
                              child: const Icon(
                                Icons.image_outlined,
                                color: YanoljaColors.textTertiary,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: YanoljaSpacing.s),
                        Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: YanoljaColors.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: YanoljaColors.textTertiary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRecentSection(List<String> recents) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          '최근 검색',
          trailing: TextButton(
            onPressed: () {
              ref.read(searchProvider.notifier).clearRecentSearches();
              _showSnack('최근 검색어를 모두 지웠어요');
            },
            style: TextButton.styleFrom(
              foregroundColor: YanoljaColors.textSecondary,
              minimumSize: Size.zero,
              padding: EdgeInsets.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('전체삭제'),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: recents.take(8).map((item) {
            return InputChip(
              label: Text(item),
              onPressed: () => _handleSearch(item),
              onDeleted: () =>
                  ref.read(searchProvider.notifier).removeRecentSearch(item),
              deleteIcon: const Icon(Icons.close_rounded, size: 15),
              backgroundColor: YanoljaColors.surfaceAlt,
              side: BorderSide.none,
              labelStyle: const TextStyle(
                color: YanoljaColors.textPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildPopularRanking(List<String> popularSearches) {
    final rankings = {
      '제주 숙소',
      '도쿄 항공권',
      '콘서트',
      '부산 오션뷰',
      ...popularSearches,
    }.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('실시간 인기 검색어'),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
            border: Border.all(color: YanoljaColors.border),
          ),
          child: Column(
            children: rankings.asMap().entries.map((entry) {
              final index = entry.key;
              final keyword = entry.value;
              return YanoljaPressable(
                onTap: () => _handleSearch(keyword),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: YanoljaSpacing.m, vertical: 13),
                  decoration: BoxDecoration(
                    border: index == rankings.length - 1
                        ? null
                        : const Border(
                            bottom: BorderSide(color: YanoljaColors.divider),
                          ),
                  ),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 22,
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: index < 3
                                ? YanoljaColors.primary
                                : YanoljaColors.textTertiary,
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          keyword,
                          style: const TextStyle(
                            color: YanoljaColors.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.north_east_rounded,
                        color: YanoljaColors.textTertiary,
                        size: 15,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestChips(List<String> suggestions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('이런 검색은 어때요?'),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: suggestions.map((item) {
            return ActionChip(
              onPressed: () => _handleSearch(item),
              label: Text(item),
              avatar: const Icon(
                Icons.search_rounded,
                size: 15,
                color: YanoljaColors.primary,
              ),
              backgroundColor: YanoljaColors.primaryLight,
              side: BorderSide.none,
              labelStyle: const TextStyle(
                color: YanoljaColors.primaryDark,
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.2,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, {Widget? trailing}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: YanoljaColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
        ),
        if (trailing != null) trailing,
      ],
    );
  }

  Widget _buildMapResults(List<Accommodation> searchResults) {
    if (searchResults.isEmpty) {
      return _buildNoResultsWidget(ref.read(searchProvider).query);
    }
    return MapScreen(accommodations: searchResults);
  }

  /// 검색 결과 리스트
  Widget _buildSearchResults() {
    final searchState = ref.watch(searchProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final sourceAsync = ref.watch(accommodationListProvider);

    // 데이터 소스 로드 실패 시 리스트-레벨 에러 상태(재시도 동선).
    if (sourceAsync.hasError) {
      return _buildResultsErrorWidget();
    }

    if (searchState.isLoading || sourceAsync.isLoading) {
      return _buildLoadingWidget();
    }

    if (searchResults.isEmpty) {
      return _buildNoResultsWidget(searchState.query);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔢 검색 결과 건수 헤더 (모드 전환은 상단 pill 토글이 단일 컨트롤로 담당)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
          color: YanoljaColors.background,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
                letterSpacing: -0.2,
              ),
              children: [
                TextSpan(
                  text: "'${searchState.query}' ",
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
                const TextSpan(text: '검색 결과 '),
                TextSpan(
                  text: '${searchResults.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.primary,
                  ),
                ),
                const TextSpan(text: '개'),
              ],
            ),
          ),
        ),

        // NOL식 8px surfaceAlt 섹션 구분 띠
        const SizedBox(
          height: 8,
          child: ColoredBox(color: YanoljaColors.surfaceAlt),
        ),

        // 📋 검색 결과 리스트
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(top: 2, bottom: 18),
            itemCount: searchResults.length,
            separatorBuilder: (_, __) => const Divider(
              height: 1,
              thickness: 1,
              indent: 16,
              endIndent: 16,
              color: YanoljaColors.divider,
            ),
            itemBuilder: (context, index) {
              final accommodation = searchResults[index];
              return _buildResultCard(accommodation, searchState.query);
            },
          ),
        ),
      ],
    );
  }

  /// 검색 결과 데이터 소스 로드 실패 시의 에러 상태(재시도).
  Widget _buildResultsErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 52,
              color: YanoljaColors.textTertiary,
            ),
            const SizedBox(height: 14),
            const Text(
              '검색 결과를 불러오지 못했어요',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '잠시 후 다시 시도해주세요',
              style: TextStyle(
                fontSize: 13,
                color: YanoljaColors.textSecondary,
              ),
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
      ),
    );
  }

  /// NOL 검색 결과 카드
  Widget _buildResultCard(Accommodation accommodation, String query) {
    final rate = YanoljaFormat.discountRate(accommodation.id);
    final original = YanoljaFormat.originalPrice(accommodation.price, rate);
    const imageWidth = 112.0;
    const imageHeight = 136.0;

    return Material(
      color: YanoljaColors.background,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _handleSearch(query);
          context.push('/detail/${accommodation.id}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l, vertical: 14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Hero(
                tag: 'search-${accommodation.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: accommodation.imageUrls.first,
                        width: imageWidth,
                        height: imageHeight,
                        fit: BoxFit.cover,
                        memCacheWidth:
                            (imageWidth * MediaQuery.devicePixelRatioOf(context))
                                .round(),
                        placeholder: (context, url) => Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: YanoljaColors.surfaceAlt,
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: imageWidth,
                          height: imageHeight,
                          color: YanoljaColors.surfaceAlt,
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: YanoljaColors.textTertiary,
                            size: 28,
                          ),
                        ),
                      ),
                      Positioned(
                        left: 7,
                        top: 7,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.62),
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.pill),
                          ),
                          child: const Text(
                            'NOL특가',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: YanoljaColors.primaryLight,
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.sm),
                          ),
                          child: Text(
                            accommodation.category,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: YanoljaColors.primary,
                            ),
                          ),
                        ),
                        if (accommodation.isPopular) ...[
                          const SizedBox(width: 5),
                          const Flexible(
                            child: Text(
                              '많이 찾는 숙소',
                              style: TextStyle(
                                color: YanoljaColors.textTertiary,
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      accommodation.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: YanoljaColors.textPrimary,
                        letterSpacing: -0.35,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${_shortAddress(accommodation.address)} · 도심 ${accommodation.distanceFromCenter.toStringAsFixed(1)}km',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: YanoljaColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 5),
                    YanoljaRating(
                      rating: accommodation.rating,
                      reviewCount: accommodation.reviewCount,
                      fontSize: 12,
                    ),
                    const SizedBox(height: YanoljaSpacing.s),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$rate%',
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: YanoljaColors.sale,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            '${YanoljaFormat.price(accommodation.price)}원',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: YanoljaColors.textPrimary,
                              letterSpacing: -0.5,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          '부터',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: YanoljaColors.textTertiary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      '${YanoljaFormat.price(original)}원',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11,
                        color: YanoljaColors.textTertiary,
                        decoration: TextDecoration.lineThrough,
                        decorationColor: YanoljaColors.textTertiary,
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

  String _shortAddress(String address) {
    final parts = address.split(' ');
    if (parts.length >= 2) return '${parts[0]} ${parts[1]}';
    return address;
  }

  void _showSnack(String message) {
    YanoljaToast.show(
      context,
      message,
      icon: Icons.search_rounded,
      duration: const Duration(seconds: 1),
    );
  }

  void _openService(String type) {
    HapticFeedback.selectionClick();
    context.push('/service/$type');
  }

  void _openShortcut(_SearchShortcut shortcut) {
    HapticFeedback.selectionClick();
    context.push(shortcut.route);
  }

  /// 🔄 로딩 위젯 — 결과 카드 골격을 본뜬 스켈레톤
  Widget _buildLoadingWidget() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      itemCount: 3,
      separatorBuilder: (_, __) => const SizedBox(height: YanoljaSpacing.xl),
      itemBuilder: (_, __) => _buildResultSkeleton(),
    );
  }

  Widget _buildResultSkeleton() {
    Widget bar(double width, double height) => Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(YanoljaRadius.sm),
          ),
        );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 112,
          height: 136,
          decoration: BoxDecoration(
            color: YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              bar(54, 18),
              const SizedBox(height: 12),
              bar(double.infinity, 16),
              const SizedBox(height: YanoljaSpacing.s),
              bar(150, 12),
              const SizedBox(height: 12),
              bar(96, 12),
              const SizedBox(height: YanoljaSpacing.m),
              bar(120, 20),
            ],
          ),
        ),
      ],
    );
  }

  /// ❌ 검색 결과 없음 위젯
  Widget _buildNoResultsWidget([String? query]) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: YanoljaColors.primaryLight,
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: YanoljaColors.primary,
                size: 44,
              ),
            ),
            const SizedBox(height: YanoljaSpacing.l),
            Text(
              query != null ? "'$query'에 대한 결과가 없어요" : '검색 결과가 없습니다',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.3,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: YanoljaSpacing.s),
            const Text(
              '다른 키워드로 검색해보세요.',
              style: TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchShortcut {
  final String label;
  final String assetPath;
  final String subtitle;
  final String route;

  const _SearchShortcut({
    required this.label,
    required this.assetPath,
    required this.subtitle,
    required this.route,
  });
}
