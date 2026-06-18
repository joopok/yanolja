import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/search_provider.dart';
import 'package:yanolja_clone/presentation/screen/map_screen.dart';
import 'package:yanolja_clone/presentation/widget/animated_search_field.dart';
import 'package:yanolja_clone/presentation/widget/google_maps_style_suggestions.dart';

enum SearchDisplayMode { list, map }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

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
    final searchState = ref.watch(searchProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final suggestedSearches = ref.watch(suggestedSearchesProvider);
    final popularSearches = ref.watch(popularSearchesProvider);

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: YanoljaColors.background,
        body: Column(
          children: [
            // 🔍 상단 헤더 (화이트 / 좌측정렬)
            _buildHeader(context),

            // 🔍 검색 필드 (테마 핑크 사용)
            AnimatedSearchField(
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

            // 📱 디스플레이 모드 토글 (검색 중일 때만 표시)
            if (searchState.query.isNotEmpty) _buildDisplayModeToggle(),

            // 📋 검색 내용 영역
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

  /// 🔍 상단 헤더 (야놀자 플랫 스타일 — 화이트 배경 + 하단 헤어라인)
  Widget _buildHeader(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: const BoxDecoration(
          color: YanoljaColors.background,
          border: Border(
            bottom: BorderSide(color: YanoljaColors.border, width: 1),
          ),
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              icon: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: YanoljaColors.textPrimary,
                size: 20,
              ),
            ),
            const Expanded(
              child: Text(
                '여행지 검색',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: YanoljaColors.textPrimary,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleDisplayMode() {
    setState(() {
      _displayMode = _displayMode == SearchDisplayMode.list
          ? SearchDisplayMode.map
          : SearchDisplayMode.list;
    });
    HapticFeedback.lightImpact();
  }

  /// 🔍 자동완성 제안 생성
  List<String> _getAutocompleteSuggestions(String query) {
    if (query.isEmpty) return [];

    final allSuggestions = [
      '제주도', '부산', '서울', '강릉', '여수', '속초', '경주', '전주',
      '호텔', '펜션', '리조트', '한옥', '게스트하우스', '캠핑',
      '바다뷰', '오션뷰', '풀빌라', '스파', '온천', '수영장',
      '애견동반', '바베큐', '카페', '레스토랑',
    ];

    return allSuggestions
        .where((suggestion) =>
            suggestion.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();
  }

  /// 📱 디스플레이 모드 토글 (목록 / 지도) — 핑크 세그먼트
  Widget _buildDisplayModeToggle() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 10, 16, 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
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
                  _toggleDisplayMode,
                ),
                _buildToggleButton(
                  Icons.map_rounded,
                  '지도',
                  _displayMode == SearchDisplayMode.map,
                  _toggleDisplayMode,
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
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
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

  /// 🗂️ 검색어 없을 때 — 최근/인기/추천 제안 (위젯 재사용, 테마 핑크)
  Widget _buildSuggestions(
    BuildContext context,
    SearchState searchState,
    List<String> suggestedSearches,
    List<String> popularSearches,
  ) {
    return GoogleMapsStyleSuggestions(
      suggestions: _getAutocompleteSuggestions(searchState.query),
      recentSearches: searchState.recentSearches,
      popularSearches: popularSearches,
      onSuggestionTap: _handleSearch,
      onRecentSearchDelete: (search) {
        ref.read(searchProvider.notifier).removeRecentSearch(search);
      },
      onClearAllRecents: () {
        ref.read(searchProvider.notifier).clearRecentSearches();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('모든 검색 기록이 삭제되었습니다.'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      },
    );
  }

  Widget _buildMapResults(List<Accommodation> searchResults) {
    if (searchResults.isEmpty) {
      return _buildNoResultsWidget();
    }
    return MapScreen(accommodations: searchResults);
  }

  /// 📋 검색 결과 (야놀자 플랫 카드 리스트)
  Widget _buildSearchResults() {
    final searchState = ref.watch(searchProvider);
    final searchResults = ref.watch(searchResultsProvider);

    if (searchState.isLoading) {
      return _buildLoadingWidget();
    }

    if (searchResults.isEmpty) {
      return _buildNoResultsWidget(searchState.query);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔢 검색 결과 건수 헤더
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
          color: YanoljaColors.background,
          child: RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                color: YanoljaColors.textSecondary,
                letterSpacing: -0.2,
              ),
              children: [
                const TextSpan(text: '검색 결과 '),
                TextSpan(
                  text: '${searchResults.length}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.primary,
                  ),
                ),
                const TextSpan(text: '건'),
              ],
            ),
          ),
        ),

        // 8px surfaceAlt 구분 띠
        const Divider(height: 1, thickness: 1, color: YanoljaColors.border),

        // 📋 검색 결과 리스트
        Expanded(
          child: AnimationLimiter(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
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
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 300),
                  child: SlideAnimation(
                    verticalOffset: 20.0,
                    child: FadeInAnimation(
                      child: _buildResultCard(accommodation, searchState.query),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// 🏨 야놀자 플랫 검색 결과 카드 (이미지 radius 12 + 정가 취소선 + 핑크 할인율 + 굵은 현재가)
  Widget _buildResultCard(Accommodation accommodation, String query) {
    final rate = YanoljaFormat.discountRate(accommodation.id);
    final original = YanoljaFormat.originalPrice(accommodation.price, rate);

    return Material(
      color: YanoljaColors.background,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          _handleSearch(query);
          context.push('/detail/${accommodation.id}');
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 썸네일
              Hero(
                tag: 'search-${accommodation.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: accommodation.imageUrls.first,
                    width: 108,
                    height: 108,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 108,
                      height: 108,
                      color: YanoljaColors.surfaceAlt,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 108,
                      height: 108,
                      color: YanoljaColors.surfaceAlt,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: YanoljaColors.textTertiary,
                        size: 28,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 카테고리 배지
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 3),
                      decoration: BoxDecoration(
                        color: YanoljaColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                      ),
                      child: Text(
                        accommodation.category,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: YanoljaColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 이름
                    Text(
                      accommodation.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15.5,
                        fontWeight: FontWeight.w700,
                        color: YanoljaColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 3),

                    // 주소
                    Text(
                      accommodation.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: YanoljaColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // 평점
                    YanoljaRating(
                      rating: accommodation.rating,
                      reviewCount: accommodation.reviewCount,
                    ),
                    const SizedBox(height: 8),

                    // 가격 (정가 취소선 + 핑크 할인율 + 굵은 현재가)
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${YanoljaFormat.price(original)}원',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: YanoljaColors.textTertiary,
                            decoration: TextDecoration.lineThrough,
                            decorationColor: YanoljaColors.textTertiary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '$rate%',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 1),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          YanoljaFormat.price(accommodation.price),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(width: 1),
                        const Text(
                          '원',
                          style: TextStyle(
                            fontSize: 14,
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
      ),
    );
  }

  /// 🔄 로딩 위젯
  Widget _buildLoadingWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 28,
            height: 28,
            child: CircularProgressIndicator(
              color: YanoljaColors.primary,
              strokeWidth: 2.5,
            ),
          ),
          SizedBox(height: 16),
          Text(
            '검색 중...',
            style: TextStyle(
              fontSize: 14,
              color: YanoljaColors.textSecondary,
            ),
          ),
        ],
      ),
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
            const SizedBox(height: 20),
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
            const SizedBox(height: 8),
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
