import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/search_provider.dart';
import 'package:yanolja_clone/presentation/screen/map_screen.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';
import 'package:yanolja_clone/presentation/widget/animated_search_field.dart';
import 'package:yanolja_clone/presentation/widget/google_maps_style_suggestions.dart';

enum SearchDisplayMode { list, map }

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen>
    with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  
  // 🎬 TikTok 스타일 애니메이션 컨트롤러들
  late AnimationController _fabAnimationController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _fabAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  SearchDisplayMode _displayMode = SearchDisplayMode.list;

  @override
  void initState() {
    super.initState();
    
    // 🚀 TikTok 스타일 애니메이션 초기화
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fabAnimation = CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut, // TikTok 스타일의 탄성 곡선
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 🎪 애니메이션 순차 실행
    _slideController.forward();
    _pulseController.repeat(reverse: true);

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
    _fabAnimationController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
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
    final theme = Theme.of(context);
    final searchState = ref.watch(searchProvider);
    final searchResults = ref.watch(searchResultsProvider);
    final suggestedSearches = ref.watch(suggestedSearchesProvider);
    final popularSearches = ref.watch(popularSearchesProvider);

    // FAB 애니메이션 제어
    if (searchState.recentSearches.isNotEmpty) {
      _fabAnimationController.forward();
    } else {
      _fabAnimationController.reverse();
    }

    return GestureDetector(
      onTap: () => _searchFocusNode.unfocus(),
      child: Scaffold(
        backgroundColor: theme.colorScheme.surface,
        body: Column(
          children: [
            // 🎯 구글 맵 스타일 상단 헤더
            _buildGoogleMapsStyleHeader(context, theme),
            
            // 🔍 애니메이션 검색 필드
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
            if (searchState.query.isNotEmpty)
              _buildDisplayModeToggle(context, theme),
            
            // 📋 검색 내용 영역
            Expanded(
              child: searchState.query.isEmpty
                  ? _buildGoogleMapsStyleSuggestions(context, searchState, suggestedSearches, popularSearches)
                  : _displayMode == SearchDisplayMode.list
                      ? _buildSearchResults()
                      : _buildMapResults(searchResults),
            ),
          ],
        ),
      ),
    );
  }

  /// 🎬 TikTok 스타일 SliverAppBar
  Widget _buildTikTokStyleSliverAppBar(ThemeData theme, bool showToggle) {
    return SliverAppBar.medium( // Context7 최신 기능
      expandedHeight: 150,
      pinned: true,
      floating: true,
      snap: true,
      elevation: 0,
      scrolledUnderElevation: 3,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: theme.colorScheme.surfaceTint,
      automaticallyImplyLeading: false,
      
      // ✨ TikTok 스타일 애니메이션 타이틀
      title: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 600),
        tween: Tween(begin: 0.0, end: 1.0),
        builder: (context, value, child) {
          return Transform.translate(
            offset: Offset(-30 * (1 - value), 0),
            child: Opacity(
              opacity: value,
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.travel_explore_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '어디로',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: theme.colorScheme.onSurface,
                      letterSpacing: -0.4,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      centerTitle: false,
      
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
        centerTitle: false,
        title: _buildInstagramStyleSearchField(theme),
                 background: _buildAppBarBackground(theme),
      ),
      
      actions: [
        if (showToggle)
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                  ),
                ),
                child: Icon(
                  _displayMode == SearchDisplayMode.list
                      ? Icons.map_outlined
                      : Icons.view_list_rounded,
                  color: theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              onPressed: _toggleDisplayMode,
            ),
          ),
        const SizedBox(width: 16),
      ],
    );
  }

  /// 🎨 Instagram 스타일 검색 필드
  Widget _buildInstagramStyleSearchField(ThemeData theme) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: '여행지나 숙소를 검색해보세요',
          hintStyle: TextStyle(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w400,
          ),
          prefixIcon: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _pulseAnimation.value,
                child: Icon(
                  Icons.search_rounded,
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
              );
            },
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(
                    Icons.clear_rounded,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  onPressed: () {
                    _searchController.clear();
                    ref.read(searchProvider.notifier).updateQuery('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w500,
        ),
        onSubmitted: _handleSearch,
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

  /// 🎯 구글 맵 스타일 헤더
  Widget _buildGoogleMapsStyleHeader(BuildContext context, ThemeData theme) {
    return SafeArea(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            IconButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.pop();
              },
              icon: Icon(
                Icons.arrow_back_rounded,
                color: theme.colorScheme.onSurface,
              ),
            ),
            Expanded(
              child: Text(
                '여행지 검색',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
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

  /// 📱 디스플레이 모드 토글
  Widget _buildDisplayModeToggle(BuildContext context, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.2),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildToggleButton(
                  theme,
                  Icons.view_list_rounded,
                  '목록',
                  _displayMode == SearchDisplayMode.list,
                  () => _toggleDisplayMode(),
                ),
                _buildToggleButton(
                  theme,
                  Icons.map_rounded,
                  '지도',
                  _displayMode == SearchDisplayMode.map,
                  () => _toggleDisplayMode(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(
    ThemeData theme,
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected 
              ? theme.colorScheme.primary 
              : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? Colors.white 
                  : theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected 
                    ? Colors.white 
                    : theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🗂️ 구글 맵 스타일 제안 화면
  Widget _buildGoogleMapsStyleSuggestions(
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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

  Widget _buildAppBarBackground(ThemeData theme) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 16, right: 20),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Material(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.pop(),
                  borderRadius: BorderRadius.circular(12),
                  child: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Text(
                '어디로 떠나볼까요?',
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryFilter(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final categories = ['호텔', '펜션', '리조트', '한옥', '게스트하우스', '캠핑'];
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: categories.map((category) {
            final isSelected = searchState.selectedCategory == category;
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: (selected) {
                  ref.read(searchProvider.notifier).selectCategory(
                      selected ? category : null);
                },
                selectedColor: theme.colorScheme.primary.withOpacity(0.2),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                labelStyle: TextStyle(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                side: BorderSide(
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.outline,
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildSortOptions(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          DropdownButton<String>(
            value: searchState.sortBy,
            icon: Icon(Icons.sort, color: theme.colorScheme.primary),
            elevation: 16,
            style: theme.textTheme.bodyMedium,
            underline: Container(height: 0),
            onChanged: (String? newValue) {
              if (newValue != null) {
                ref.read(searchProvider.notifier).changeSortBy(newValue);
              }
            },
            items: const <DropdownMenuItem<String>>[
              DropdownMenuItem(
                value: 'rating',
                child: Text('평점순'),
              ),
              DropdownMenuItem(
                value: 'price_low',
                child: Text('낮은 가격순'),
              ),
              DropdownMenuItem(
                value: 'price_high',
                child: Text('높은 가격순'),
              ),
              DropdownMenuItem(
                value: 'distance',
                child: Text('거리순'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptySearchContent(SearchState searchState) {
    final suggestedSearches = ref.watch(suggestedSearchesProvider);
    final popularSearches = ref.watch(popularSearchesProvider);

    return SliverList(
      delegate: SliverChildListDelegate(
        AnimationConfiguration.toStaggeredList(
          duration: const Duration(milliseconds: 375),
          childAnimationBuilder: (widget) => SlideAnimation(
            verticalOffset: 50.0,
            child: FadeInAnimation(child: widget),
          ),
          children: [
            if (searchState.recentSearches.isNotEmpty) ...[
              _buildSectionTitle('최근 검색어', Icons.history_rounded),
              _buildRecentSearchChips(searchState.recentSearches),
            ],
            _buildSectionTitle('인기 검색어', Icons.local_fire_department_rounded),
            _buildPopularSearchGrid(popularSearches),
            _buildSectionTitle('추천 여행지', Icons.lightbulb_outline_rounded),
            _buildSuggestedSearchList(suggestedSearches),
          ],
        ),
      ),
    );
  }

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
        // 🔢 검색 결과 헤더
        Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            children: [
              Icon(
                Icons.search_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              RichText(
                text: TextSpan(
                  style: Theme.of(context).textTheme.titleMedium,
                  children: [
                    const TextSpan(text: '검색 결과 '),
                    TextSpan(
                      text: '${searchResults.length}건',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        // 📋 검색 결과 리스트
        Expanded(
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final accommodation = searchResults[index];
                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 375),
                  child: SlideAnimation(
                    verticalOffset: 30.0,
                    child: FadeInAnimation(
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _handleSearch(searchState.query);
                              context.push('/detail/${accommodation.id}');
                            },
                            borderRadius: BorderRadius.circular(16),
                            child: Hero(
                              tag: 'search-${accommodation.id}',
                              child: AccommodationListItem(accommodation: accommodation),
                            ),
                          ),
                        ),
                      ),
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

  /// 🔄 로딩 위젯
  Widget _buildLoadingWidget() {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
            strokeWidth: 3,
          ),
          const SizedBox(height: 16),
          Text(
            '검색 중...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// ❌ 검색 결과 없음 위젯
  Widget _buildNoResultsWidget([String? query]) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.colorScheme.primaryContainer,
              ),
              child: Icon(
                Icons.search_off_rounded,
                color: theme.colorScheme.primary,
                size: 48,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              query != null 
                  ? "'$query'에 대한 결과가 없어요"
                  : '검색 결과가 없습니다',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '다른 키워드로 검색해보세요.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          Icon(icon, color: theme.colorScheme.primary, size: 22),
          const SizedBox(width: 12),
          Text(title, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }

  Widget _buildRecentSearchChips(List<String> recentSearches) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: recentSearches.map((search) {
          return Chip(
            label: Text(search),
            onDeleted: () => ref.read(searchProvider.notifier).removeRecentSearch(search),
            deleteIcon: const Icon(Icons.close_rounded, size: 16),
            backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPopularSearchGrid(List<String> popularSearches) {
    final theme = Theme.of(context);
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: popularSearches.length,
      itemBuilder: (context, index) {
        final search = popularSearches[index];
        return Card(
          elevation: 0,
          color: theme.colorScheme.surfaceContainerHighest,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
          ),
          child: InkWell(
            onTap: () => _handleSearch(search),
            borderRadius: BorderRadius.circular(16),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${index + 1}', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        search,
                        style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedSearchList(List<String> suggestedSearches) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: suggestedSearches.length,
      itemBuilder: (context, index) {
        final search = suggestedSearches[index];
        return ListTile(
          onTap: () => _handleSearch(search),
          leading: const Icon(Icons.explore_outlined),
          title: Text(search),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        );
      },
    );
  }

  Widget _buildNoResults(String query) {
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
              child: Icon(Icons.search_off_rounded, color: theme.colorScheme.primary, size: 60),
            ),
            const SizedBox(height: 24),
            Text(
              "'$query'에 대한 결과가 없어요",
              style: theme.textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              '오타가 없는지 확인하거나 다른 키워드로 검색해보세요.',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.7)),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showClearHistoryDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.delete_sweep_outlined),
              SizedBox(width: 8),
              Text('기록 전체 삭제'),
            ],
          ),
          content: const Text('모든 검색 기록을 삭제할까요?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(searchProvider.notifier).clearRecentSearches();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('검색 기록이 모두 삭제되었습니다.'),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
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
}
