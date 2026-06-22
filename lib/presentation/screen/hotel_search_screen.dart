import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_date_range_sheet.dart';

class HotelSearchScreen extends StatefulWidget {
  const HotelSearchScreen({super.key});

  @override
  State<HotelSearchScreen> createState() => _HotelSearchScreenState();
}

class _HotelSearchScreenState extends State<HotelSearchScreen> {
  String _selectedTab = '국내숙소';
  String _selectedRegion = '서울';
  DateTimeRange? _dateRange;
  int _adults = 2;
  int _rooms = 1;

  static const List<String> _tabs = ['국내숙소', '해외숙소'];
  static const List<String> _regions = ['서울', '부산', '제주', '강릉', '여수'];
  static const List<String> _popular = [
    '서울 호캉스',
    '부산 오션뷰',
    '제주 풀빌라',
    '강릉 감성숙소',
    '여수 리조트',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      appBar: const YanoljaAppBar.sub(
        title: '숙소 검색',
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: YanoljaEntrance(child: _buildTabs())),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: const Duration(milliseconds: 55),
              child: _buildSearchPanel(),
            ),
          ),
          SliverToBoxAdapter(child: _sectionGap()),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: const Duration(milliseconds: 105),
              child: _buildPopularRegions(),
            ),
          ),
          SliverToBoxAdapter(child: _sectionGap()),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: const Duration(milliseconds: 155),
              child: _buildBenefitPanel(),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 92)),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: YanoljaColors.background,
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: SizedBox(
            height: 54,
            child: ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                context.push('/hotel');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: YanoljaColors.primary,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
              child: const Text(
                '숙소 검색하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      child: Container(
        height: 46,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        ),
        child: Row(
          children: [
            for (final tab in _tabs)
              Expanded(
                child: YanoljaPressable(
                  pressedScale: 0.985,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedTab = tab);
                  },
                  child: AnimatedContainer(
                    duration: YanoljaMotion.base,
                    curve: YanoljaMotion.curve,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedTab == tab
                          ? YanoljaColors.textPrimary
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                    ),
                    child: Text(
                      tab,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: _selectedTab == tab
                            ? Colors.white
                            : YanoljaColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchPanel() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
      child: Column(
        children: [
          _SearchRow(
            icon: Icons.search_rounded,
            title: '여행지 또는 숙소',
            value: _selectedRegion,
            onTap: _pickRegion,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _SearchMiniCard(
                  icon: Icons.calendar_today_outlined,
                  title: '일정',
                  value: _dateLabel,
                  onTap: _pickDates,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SearchMiniCard(
                  icon: Icons.people_outline_rounded,
                  title: '인원',
                  value: _guestLabel,
                  onTap: _pickGuests,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
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
                  Icons.confirmation_number_rounded,
                  color: YanoljaColors.primary,
                  size: 22,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '쿠폰 적용가로 더 저렴한 숙소를 찾아드려요',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularRegions() {
    return Container(
      color: YanoljaColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const YanoljaSectionHeader(
            title: '인기 지역',
            subtitle: '지금 많이 찾는 국내 숙소',
            padding: EdgeInsets.fromLTRB(20, 22, 20, 14),
          ),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _regions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final region = _regions[index];
                final selected = _selectedRegion == region;
                return YanoljaPressable(
                  pressedScale: 0.985,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    setState(() => _selectedRegion = region);
                  },
                  child: AnimatedContainer(
                    duration: YanoljaMotion.base,
                    curve: YanoljaMotion.curve,
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color:
                          selected ? YanoljaColors.textPrimary : Colors.white,
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                      border: Border.all(
                        color: selected
                            ? YanoljaColors.textPrimary
                            : YanoljaColors.border,
                      ),
                    ),
                    child: Text(
                      region,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: selected
                            ? Colors.white
                            : YanoljaColors.textSecondary,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final keyword in _popular)
                  ActionChip(
                    onPressed: () => _searchKeyword(keyword),
                    label: Text(keyword),
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
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitPanel() {
    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 22),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: YanoljaColors.primary,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: 13),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '숙박세일페스타 진행 중',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.3,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'NOL에서 바로 쓸 수 있는 특가와 쿠폰',
                    style: TextStyle(
                      color: Color(0xFFEAF0FF),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: Colors.white,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionGap() {
    return Container(height: 8, color: YanoljaColors.surfaceAlt);
  }

  String get _dateLabel {
    final range = _dateRange;
    if (range == null) return '날짜 선택';
    String fmt(DateTime d) => '${d.month}.${d.day}';
    return '${fmt(range.start)} - ${fmt(range.end)}';
  }

  String get _guestLabel => '성인 $_adults · 객실 $_rooms';

  Future<void> _pickRegion() async {
    HapticFeedback.selectionClick();
    final isDomestic = _selectedTab == '국내숙소';
    final options =
        isDomestic ? _regions : const ['도쿄', '오사카', '방콕', '다낭', '파리'];
    final picked = await _showSelectSheet(
      title: '여행지 선택',
      options: options,
      selected: _selectedRegion,
    );
    if (picked != null) setState(() => _selectedRegion = picked);
  }

  Future<void> _pickDates() async {
    HapticFeedback.selectionClick();
    final picked = await showYanoljaDateRangeSheet(
      context: context,
      initialRange: _dateRange,
    );
    if (picked != null) setState(() => _dateRange = picked);
  }

  Future<void> _pickGuests() async {
    HapticFeedback.selectionClick();
    int adults = _adults;
    int rooms = _rooms;
    final applied = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            Widget counterRow({
              required IconData icon,
              required Color iconColor,
              required Color iconBg,
              required String label,
              required String sub,
              required int value,
              required bool canMinus,
              required bool canPlus,
              required VoidCallback onMinus,
              required VoidCallback onPlus,
            }) {
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                decoration: BoxDecoration(
                  color: YanoljaColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: iconBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, size: 22, color: iconColor),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(label,
                              style: const TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w800,
                                  color: YanoljaColors.textPrimary,
                                  letterSpacing: -0.3)),
                          const SizedBox(height: 2),
                          Text(sub,
                              style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w500,
                                  color: YanoljaColors.textSecondary)),
                        ],
                      ),
                    ),
                    _StepButton(
                        icon: Icons.remove_rounded,
                        enabled: canMinus,
                        onTap: onMinus),
                    SizedBox(
                      width: 46,
                      child: Text('$value',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: YanoljaColors.textPrimary)),
                    ),
                    _StepButton(
                        icon: Icons.add_rounded,
                        enabled: canPlus,
                        onTap: onPlus),
                  ],
                ),
              );
            }

            return SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 4,
                        decoration: BoxDecoration(
                          color: YanoljaColors.border,
                          borderRadius: BorderRadius.circular(999),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: YanoljaColors.primaryLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.people_alt_rounded,
                              size: 19, color: YanoljaColors.primary),
                        ),
                        const SizedBox(width: 10),
                        const Text('인원 및 객실',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.w900,
                                color: YanoljaColors.textPrimary,
                                letterSpacing: -0.4)),
                      ],
                    ),
                    const SizedBox(height: 5),
                    const Padding(
                      padding: EdgeInsets.only(left: 2),
                      child: Text('여행 인원에 맞춰 객실을 선택하세요',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: YanoljaColors.textSecondary)),
                    ),
                    const SizedBox(height: 18),
                    counterRow(
                      icon: Icons.person_rounded,
                      iconColor: YanoljaColors.primary,
                      iconBg: YanoljaColors.primaryLight,
                      label: '성인',
                      sub: '만 19세 이상',
                      value: adults,
                      canMinus: adults > 1,
                      canPlus: adults < 10,
                      onMinus: () => setSheetState(() {
                        if (adults > 1) adults--;
                      }),
                      onPlus: () => setSheetState(() {
                        if (adults < 10) adults++;
                      }),
                    ),
                    counterRow(
                      icon: Icons.meeting_room_rounded,
                      iconColor: YanoljaColors.primaryPurple,
                      iconBg: const Color(0xFFEDEAFF),
                      label: '객실',
                      sub: '최대 8객실까지 선택 가능',
                      value: rooms,
                      canMinus: rooms > 1,
                      canPlus: rooms < 8,
                      onMinus: () => setSheetState(() {
                        if (rooms > 1) rooms--;
                      }),
                      onPlus: () => setSheetState(() {
                        if (rooms < 8) rooms++;
                      }),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(sheetContext).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: YanoljaColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(YanoljaRadius.md),
                          ),
                        ),
                        child: Text('성인 $adults · 객실 $rooms 적용',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w900)),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
    if (applied == true) {
      setState(() {
        _adults = adults;
        _rooms = rooms;
      });
    }
  }

  void _searchKeyword(String keyword) {
    HapticFeedback.lightImpact();
    setState(() => _selectedRegion = keyword.split(' ').first);
    context.push('/hotel');
  }

  Future<String?> _showSelectSheet({
    required String title,
    required List<String> options,
    required String selected,
  }) {
    return showModalBottomSheet<String>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 14, 22, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: YanoljaColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(title,
                    style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: YanoljaColors.textPrimary,
                        letterSpacing: -0.4)),
                const SizedBox(height: 4),
                for (final option in options)
                  InkWell(
                    onTap: () => Navigator.of(sheetContext).pop(option),
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 4),
                      child: Row(
                        children: [
                          Icon(Icons.place_outlined,
                              size: 20,
                              color: option == selected
                                  ? YanoljaColors.primary
                                  : YanoljaColors.textTertiary),
                          const SizedBox(width: 12),
                          Text(option,
                              style: TextStyle(
                                  fontSize: 15.5,
                                  fontWeight: option == selected
                                      ? FontWeight.w900
                                      : FontWeight.w600,
                                  color: option == selected
                                      ? YanoljaColors.primary
                                      : YanoljaColors.textPrimary)),
                          const Spacer(),
                          if (option == selected)
                            const Icon(Icons.check_rounded,
                                size: 20, color: YanoljaColors.primary),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StepButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool enabled;
  const _StepButton({
    required this.icon,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkResponse(
      onTap: enabled
          ? () {
              HapticFeedback.selectionClick();
              onTap();
            }
          : null,
      radius: 28,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: enabled ? Colors.white : YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: enabled ? YanoljaColors.primary : YanoljaColors.border,
            width: 1.4,
          ),
        ),
        child: Icon(
          icon,
          size: 19,
          color: enabled ? YanoljaColors.primary : YanoljaColors.textTertiary,
        ),
      ),
    );
  }
}

class _SearchRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SearchRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: YanoljaColors.textSecondary, size: 22),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
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
            const Icon(
              Icons.chevron_right_rounded,
              color: YanoljaColors.textTertiary,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchMiniCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final VoidCallback onTap;

  const _SearchMiniCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: YanoljaColors.textSecondary, size: 20),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
