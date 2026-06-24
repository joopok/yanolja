import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';

/// 홈·더보기 화면의 검색바 마이크 탭 → 검색 화면(/search)의 음성 검색을 깨우는 시그널.
/// 탭할 때마다 값이 증가하고, 검색 화면이 변화를 감지해 음성 인식을 시작한다.
/// (검색 탭은 indexedStack으로 keep-alive 되어 라우트 extra로는 깨울 수 없으므로 시그널을 사용.)
final voiceSearchSignalProvider = StateProvider<int>((ref) => 0);

// 검색 상태를 관리하는 클래스
class SearchState {
  final String query;
  final List<String> recentSearches;
  final String? selectedCategory;
  final String sortBy;
  final List<Accommodation> filteredResults;
  final bool isLoading;

  const SearchState({
    this.query = '',
    this.recentSearches = const [],
    this.selectedCategory,
    this.sortBy = 'rating', // rating, price_low, price_high, distance
    this.filteredResults = const [],
    this.isLoading = false,
  });

  SearchState copyWith({
    String? query,
    List<String>? recentSearches,
    String? selectedCategory,
    String? sortBy,
    List<Accommodation>? filteredResults,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      recentSearches: recentSearches ?? this.recentSearches,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      sortBy: sortBy ?? this.sortBy,
      filteredResults: filteredResults ?? this.filteredResults,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// 검색 상태를 관리하는 NotifierProvider
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier() : super(const SearchState());
  
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  // 검색어 업데이트 및 실시간 필터링 (디바운스 적용)
  void updateQuery(String query) {
    // 즉시 상태 업데이트 (타이핑 반응성을 위해)
    state = state.copyWith(query: query);
    
    // 이전 타이머 취소
    _debounceTimer?.cancel();
    
    // 검색어가 비어있으면 즉시 로딩 상태 해제
    if (query.trim().isEmpty) {
      state = state.copyWith(isLoading: false);
      return;
    }
    
    // 로딩 상태 시작
    state = state.copyWith(isLoading: true);
    
    // 디바운스 타이머 설정 (300ms 대기 후 검색 실행)
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (state.query == query) {
        state = state.copyWith(isLoading: false);
      }
    });
  }

  // 최근 검색어에 추가
  void addRecentSearch(String query) {
    if (query.trim().isEmpty) return;
    
    final updatedRecents = [
      query,
      ...state.recentSearches.where((item) => item != query),
    ].take(10).toList(); // 최대 10개까지만 저장
    
    state = state.copyWith(recentSearches: updatedRecents);
  }

  // 최근 검색어 삭제
  void removeRecentSearch(String query) {
    final updatedRecents = state.recentSearches
        .where((item) => item != query)
        .toList();
    state = state.copyWith(recentSearches: updatedRecents);
  }

  // 모든 최근 검색어 삭제
  void clearRecentSearches() {
    state = state.copyWith(recentSearches: []);
  }

  // 카테고리 선택
  void selectCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
  }

  // 정렬 방식 변경
  void changeSortBy(String sortBy) {
    state = state.copyWith(sortBy: sortBy);
  }

  // 🔍 고급 검색 결과 필터링 및 정렬
  List<Accommodation> filterAndSortAccommodations(List<Accommodation> allAccommodations) {
    var filtered = allAccommodations.where((acc) {
      // 🎯 스마트 검색어 필터링
      final query = state.query.toLowerCase().trim();
      
      if (query.isEmpty) return true;
      
      // 정확한 매칭 우선 체크
      final name = acc.name.toLowerCase();
      final address = acc.address.toLowerCase();
      final category = acc.category.toLowerCase();
      
      // 이름에서 정확한 매칭
      final exactNameMatch = name.contains(query);
      
      // 주소에서 매칭 (도시, 구 등)
      final addressMatch = address.contains(query);
      
      // 카테고리 매칭
      final categoryMatch = category.contains(query);
      
      // 어메니티 매칭
      final amenityMatch = acc.amenities.any((amenity) => 
          amenity.toLowerCase().contains(query));
      
      // 부분 키워드 매칭 (공백으로 분리된 키워드들)
      final keywords = query.split(' ').where((k) => k.isNotEmpty).toList();
      final keywordMatch = keywords.every((keyword) =>
          name.contains(keyword) ||
          address.contains(keyword) ||
          category.contains(keyword) ||
          acc.amenities.any((amenity) => 
              amenity.toLowerCase().contains(keyword)));

      final matchesQuery = exactNameMatch || 
                          addressMatch || 
                          categoryMatch || 
                          amenityMatch || 
                          keywordMatch;

      // 카테고리 필터링
      final matchesCategory = state.selectedCategory == null ||
          acc.category == state.selectedCategory;

      return matchesQuery && matchesCategory;
    }).toList();

    // 🎯 스마트 정렬 (관련성 + 사용자 선택)
    if (state.query.trim().isNotEmpty) {
      // 검색 관련성 기반 정렬
      filtered.sort((a, b) {
        final query = state.query.toLowerCase();
        final aRelevance = _calculateRelevance(a, query);
        final bRelevance = _calculateRelevance(b, query);
        return bRelevance.compareTo(aRelevance);
      });
    }

    // 사용자 선택 정렬 적용
    switch (state.sortBy) {
      case 'rating':
        filtered.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'price_low':
        filtered.sort((a, b) => a.price.compareTo(b.price));
        break;
      case 'price_high':
        filtered.sort((a, b) => b.price.compareTo(a.price));
        break;
      case 'distance':
        filtered.sort((a, b) => a.distanceFromCenter.compareTo(b.distanceFromCenter));
        break;
    }

    return filtered;
  }

  // 🎯 검색 관련성 점수 계산
  int _calculateRelevance(Accommodation acc, String query) {
    int score = 0;
    final name = acc.name.toLowerCase();
    final address = acc.address.toLowerCase();
    final category = acc.category.toLowerCase();
    
    // 이름에서 정확한 매칭 (높은 점수)
    if (name == query) {
      score += 100;
    } else if (name.startsWith(query)) {
      score += 80;
    } else if (name.contains(query)) {
      score += 60;
    }
    
    // 카테고리 매칭
    if (category.contains(query)) {
      score += 40;
    }
    
    // 주소 매칭
    if (address.contains(query)) {
      score += 30;
    }
    
    // 어메니티 매칭
    for (final amenity in acc.amenities) {
      if (amenity.toLowerCase().contains(query)) {
        score += 20;
        break;
      }
    }
    
    // 인기도 보너스
    if (acc.isPopular) {
      score += 10;
    }
    
    // 평점 보너스
    score += (acc.rating * 5).round();
    
    return score;
  }
}

// SearchNotifier를 제공하는 Provider
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((ref) {
  return SearchNotifier();
});

// 검색 결과를 제공하는 Provider
final searchResultsProvider = Provider<List<Accommodation>>((ref) {
  final allAccommodationsAsync = ref.watch(accommodationListProvider);
  
  return allAccommodationsAsync.when(
    data: (accommodations) {
      final searchNotifier = ref.read(searchProvider.notifier);
      return searchNotifier.filterAndSortAccommodations(accommodations);
    },
    loading: () => [],
    error: (_, __) => [],
  );
});

// 추천 검색어 Provider
final suggestedSearchesProvider = Provider<List<String>>((ref) {
  return [
    '제주도 호텔',
    '부산 오션뷰',
    '서울 강남',
    '펜션',
    '리조트',
    '수영장',
    '온천',
    '바베큐',
    '애견동반',
    '카페',
  ];
});

// 인기 검색어 Provider
final popularSearchesProvider = Provider<List<String>>((ref) {
  return [
    '호텔',
    '펜션',
    '리조트',
    '제주도',
    '부산',
    '강릉',
    '여수',
    '속초',
  ];
});