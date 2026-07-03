import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class GoogleMapsStyleSuggestions extends StatelessWidget {
  final List<String> suggestions;
  final List<String> recentSearches;
  final List<String> popularSearches;
  final Function(String) onSuggestionTap;
  final Function(String)? onRecentSearchDelete;
  final VoidCallback? onClearAllRecents;

  const GoogleMapsStyleSuggestions({
    super.key,
    required this.suggestions,
    required this.recentSearches,
    required this.popularSearches,
    required this.onSuggestionTap,
    this.onRecentSearchDelete,
    this.onClearAllRecents,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      color: theme.colorScheme.surface,
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: YanoljaSpacing.s),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔍 실시간 검색 제안 (타이핑 중일 때)
            if (suggestions.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                '검색 제안',
                Icons.lightbulb_outline_rounded,
              ),
              ...suggestions.asMap().entries.map((entry) {
                final suggestion = entry.value;
                return _buildSuggestionTile(
                  context,
                  suggestion,
                  Icons.search_rounded,
                  onTap: () => onSuggestionTap(suggestion),
                );
              }),
            ],

            // 🕐 최근 검색어
            if (recentSearches.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                '최근 검색',
                Icons.history_rounded,
                trailing: TextButton(
                  onPressed: onClearAllRecents,
                  child: Text(
                    '모두 삭제',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              ...recentSearches.asMap().entries.map((entry) {
                final search = entry.value;
                return _buildSuggestionTile(
                  context,
                  search,
                  Icons.access_time_rounded,
                  onTap: () => onSuggestionTap(search),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.close_rounded,
                      size: 16,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    onPressed: () => onRecentSearchDelete?.call(search),
                  ),
                );
              }),
            ],

            // 🔥 인기 검색어
            if (popularSearches.isNotEmpty) ...[
              _buildSectionHeader(
                context,
                '인기 검색어',
                Icons.local_fire_department_rounded,
              ),
              _buildPopularSearchGrid(context, popularSearches),
            ],

            // 📍 추천 위치 (구글 맵 스타일)
            _buildSectionHeader(
              context,
              '추천 여행지',
              Icons.place_rounded,
            ),
            _buildRecommendedPlaces(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon, {
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildSuggestionTile(
    BuildContext context,
    String text,
    IconData icon, {
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l, vertical: 12),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPopularSearchGrid(BuildContext context, List<String> searches) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 4,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: searches.length,
        itemBuilder: (context, index) {
          final search = searches[index];
          return Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                onSuggestionTap(search);
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.colorScheme.outline.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      margin: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        search,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedPlaces(BuildContext context) {
    final theme = Theme.of(context);

    final recommendedPlaces = [
      {
        'name': '제주도',
        'description': '아름다운 자연과 힐링',
        'icon': '🏝️',
        'color': const Color(0xFF4FC3F7),
      },
      {
        'name': '부산',
        'description': '바다와 도시의 조화',
        'icon': '🌊',
        'color': const Color(0xFF29B6F6),
      },
      {
        'name': '강릉',
        'description': '커피와 바다 여행',
        'icon': '☕',
        'color': const Color(0xFF66BB6A),
      },
      {
        'name': '여수',
        'description': '낭만적인 밤바다',
        'icon': '🌃',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
      child: Column(
        children: recommendedPlaces.map((place) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onSuggestionTap(place['name'] as String);
                },
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        (place['color'] as Color).withValues(alpha: 0.1),
                        (place['color'] as Color).withValues(alpha: 0.05),
                      ],
                    ),
                    border: Border.all(
                      color: (place['color'] as Color).withValues(alpha: 0.2),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: place['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            place['icon'] as String,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              place['name'] as String,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              place['description'] as String,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 16,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
