import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 햅틱 피드백용
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/provider/review_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';
import 'package:yanolja_clone/presentation/widget/fullscreen_image_gallery.dart'; // 풀스크린 갤러리 import
import 'package:yanolja_clone/presentation/screen/payment_screen.dart';
import 'package:yanolja_clone/presentation/widget/social_share_sheet.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_date_range_sheet.dart';

/// 🏨 숙소 상세 화면 (에디토리얼 프리미엄 리디자인)
///
/// frontend-design 원칙 적용:
/// - 풀블리드 히어로 이미지 + 이미지 카운터 + 스크롤 시 페이드인되는 앱바 타이틀
/// - 히어로 위로 떠오르는 화이트 시트(둥근 상단)로 깊이감
/// - 한눈에 읽히는 핵심 편의시설 스트립 / 아이콘 기반 편의시설 그리드
/// - 평점 요약 막대그래프 + 아바타 리뷰로 가독성 극대화
class DetailScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  const DetailScreen({super.key, required this.accommodationId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  DateTimeRange? _selectedDateRange;
  int _currentImageIndex = 0;
  bool _descExpanded = false;
  double _titleOpacity = 0;

  final CarouselSliderController _carouselController =
      CarouselSliderController();
  final ScrollController _scrollController = ScrollController();

  static const double _heroHeight = 340;

  bool get _hasSelectedStay =>
      _selectedDateRange != null && _selectedDateRange!.duration.inDays > 0;

  int get _selectedNights =>
      _hasSelectedStay ? _selectedDateRange!.duration.inDays : 0;

  String get _selectedStaySummary {
    final range = _selectedDateRange;
    if (range == null) return '체크인/체크아웃 날짜를 먼저 선택해 주세요';
    return '${_fmtDate(range.start)} - ${_fmtDate(range.end)} ($_selectedNights박)';
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    // 히어로가 접히는 구간에서 앱바 타이틀을 서서히 노출
    final offset = _scrollController.offset;
    final next = ((offset - (_heroHeight - 140)) / 80).clamp(0.0, 1.0);
    if ((next - _titleOpacity).abs() > 0.02) {
      setState(() => _titleOpacity = next);
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final newDateRange = await showYanoljaDateRangeSheet(
      context: context,
      initialRange: _selectedDateRange,
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  void _continueBooking(BuildContext context, Accommodation accommodation) {
    if (!_hasSelectedStay) {
      _selectDateRange(context);
      return;
    }

    final user = ref.read(authStateChangesProvider).asData?.value;
    if (user == null) {
      context.push('/login');
      return;
    }

    context.push(
      '/payment',
      extra: PaymentArgs(
        accommodation: accommodation,
        dateRange: _selectedDateRange!,
        nights: _selectedNights,
      ),
    );
  }

  void _openGallery(
    BuildContext context,
    Accommodation accommodation, {
    int initialIndex = 0,
  }) {
    if (accommodation.imageUrls.isEmpty) return;

    final safeIndex =
        initialIndex.clamp(0, accommodation.imageUrls.length - 1).toInt();
    HapticFeedback.lightImpact();
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            FullscreenImageGallery(
          imageUrls: accommodation.imageUrls,
          initialIndex: safeIndex,
          heroTag: accommodation.imageUrls.length == 1
              ? 'accommodation-image-0'
              : null,
        ),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  Future<void> _shareAccommodation(Accommodation accommodation) async {
    HapticFeedback.lightImpact();
    await showYanoljaSocialShareSheet(
      context: context,
      data: YanoljaShareData.accommodation(accommodation),
    );
  }

  @override
  Widget build(BuildContext context) {
    final detailAsyncValue =
        ref.watch(accommodationDetailProvider(widget.accommodationId));
    final reviewFeedAsync =
        ref.watch(reviewFeedProvider(widget.accommodationId));

    return Scaffold(
      backgroundColor: YanoljaColors.background,
      body: detailAsyncValue.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: YanoljaColors.primary),
        ),
        error: (err, stack) => Center(child: Text('에러: $err')),
        data: (accommodation) {
          return CustomScrollView(
            controller: _scrollController,
            slivers: [
              _buildSliverAppBar(context, ref, accommodation),
              SliverToBoxAdapter(
                child: Transform.translate(
                  offset: const Offset(0, -14),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: YanoljaColors.background,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(24)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeaderSheet(context, accommodation),
                        _buildQuickFacts(accommodation),
                        _buildRoomPreview(context, accommodation),
                        _buildPhotoPreviewStrip(context, accommodation),
                        _buildSectionDivider(),
                        _sectionTitle('숙소 소개'),
                        _buildAbout(accommodation),
                        _buildSectionDivider(),
                        _sectionTitle('편의시설'),
                        _buildAmenitiesGrid(context, accommodation),
                        if (accommodation.nearbyAttractions.isNotEmpty) ...[
                          _buildSectionDivider(),
                          _sectionTitle('근처 가볼만한 곳'),
                          _buildNearbyPlacesSection(
                              context, accommodation.nearbyAttractions,
                              isAttraction: true),
                        ],
                        if (accommodation.nearbyRestaurants.isNotEmpty) ...[
                          _buildSectionDivider(),
                          _sectionTitle('근처 맛집'),
                          _buildNearbyPlacesSection(
                              context, accommodation.nearbyRestaurants,
                              isAttraction: false),
                        ],
                        _buildSectionDivider(),
                        _sectionTitle('오시는 길'),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
                          child: _buildLocationSection(context, accommodation),
                        ),
                        _buildSectionDivider(),
                        _sectionTitle('실제 이용객 후기',
                            action: '전체 보기',
                            onAction: () => context.push(
                                  '/detail/${accommodation.id}/reviews',
                                )),
                        _buildReviewSection(
                          context,
                          accommodation,
                          reviewFeedAsync,
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar:
          _buildBookingBottomBar(context, detailAsyncValue.asData?.value),
    );
  }

  // ───────────────────────────────────────────── 히어로 앱바
  Widget _buildSliverAppBar(
      BuildContext context, WidgetRef ref, Accommodation accommodation) {
    final isSaved = ref.watch(savedProvider).contains(accommodation.id);
    final imageCount = accommodation.imageUrls.length;

    return YanoljaSliverAppBar.detail(
      title: accommodation.name,
      backgroundColor: Colors.white,
      foregroundColor: YanoljaColors.textPrimary,
      titleOpacity: _titleOpacity,
      expandedHeight: _heroHeight,
      leading: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: _circleButton(
          icon: Icons.arrow_back_ios_new_rounded,
          iconColor:
              _titleOpacity > 0.5 ? YanoljaColors.textPrimary : Colors.white,
          onTap: () => Navigator.of(context).pop(),
        ),
      ),
      actions: [
        _circleButton(
          icon: Icons.share_outlined,
          iconColor:
              _titleOpacity > 0.5 ? YanoljaColors.textPrimary : Colors.white,
          onTap: () => _shareAccommodation(accommodation),
        ),
        const SizedBox(width: 8),
        _circleButton(
          icon:
              isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          iconColor: isSaved
              ? YanoljaColors.primary
              : (_titleOpacity > 0.5
                  ? YanoljaColors.textPrimary
                  : Colors.white),
          onTap: () {
            HapticFeedback.lightImpact();
            ref.read(savedProvider.notifier).toggleSaved(accommodation.id);
          },
        ),
        const SizedBox(width: 12),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            if (imageCount == 0)
              _buildHeroImagePlaceholder()
            else
              CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: imageCount > 1,
                  autoPlay: false,
                  scrollPhysics: const BouncingScrollPhysics(),
                  onPageChanged: (index, reason) {
                    setState(() => _currentImageIndex = index);
                  },
                ),
                items: accommodation.imageUrls.asMap().entries.map((entry) {
                  final index = entry.key;
                  final imageUrl = entry.value;
                  final image = CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: YanoljaColors.surfaceAlt),
                    errorWidget: (context, url, error) => Container(
                      color: YanoljaColors.surfaceAlt,
                      child: const Icon(Icons.image_not_supported_outlined,
                          size: 48, color: YanoljaColors.textTertiary),
                    ),
                  );
                  return GestureDetector(
                    onTap: () => _openGallery(context, accommodation,
                        initialIndex: index),
                    child: imageCount == 1
                        ? Hero(tag: 'accommodation-image-0', child: image)
                        : image,
                  );
                }).toList(),
              ),
            // 상단 스크림 (버튼 가독성)
            IgnorePointer(
              child: Container(
                height: 110,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.32),
                      Colors.transparent
                    ],
                  ),
                ),
              ),
            ),
            // 하단 스크림 (화이트 시트로의 자연스러운 전환)
            IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.28)
                    ],
                    stops: const [0.65, 1.0],
                  ),
                ),
              ),
            ),
            // 이미지 카운터 pill
            if (imageCount > 0)
              Positioned(
                left: 16,
                bottom: 40,
                child: GestureDetector(
                  onTap: () => _openGallery(
                    context,
                    accommodation,
                    initialIndex: _currentImageIndex,
                  ),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: YanoljaSpacing.s),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.14),
                          blurRadius: 14,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.grid_view_rounded,
                            size: 14, color: YanoljaColors.textPrimary),
                        SizedBox(width: 6),
                        Text(
                          '사진 모두 보기',
                          style: TextStyle(
                            color: YanoljaColors.textPrimary,
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            if (imageCount > 1)
              Positioned(
                right: 16,
                bottom: 40,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.photo_library_rounded,
                          size: 12, color: Colors.white),
                      const SizedBox(width: 5),
                      Text(
                        '${_currentImageIndex + 1} / $imageCount',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroImagePlaceholder() {
    return Container(
      color: YanoljaColors.surfaceAlt,
      child: const Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          size: 52,
          color: YanoljaColors.textTertiary,
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    final onImage = _titleOpacity <= 0.5;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: onImage
              ? Colors.black.withValues(alpha: 0.32)
              : Colors.transparent,
        ),
        child: Icon(icon, size: 19, color: iconColor),
      ),
    );
  }

  // ───────────────────────────────────────────── 추천 객실 카드
  Widget _buildRoomPreview(BuildContext context, Accommodation a) {
    final rate = YanoljaFormat.discountRate(a.id);
    final original = YanoljaFormat.originalPrice(a.price, rate);
    final tags = _roomTags(a);
    final imageUrl = a.imageUrls.isNotEmpty ? a.imageUrls.first : null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Container(
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '오늘의 추천 객실',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: YanoljaColors.primary,
                            letterSpacing: -0.2,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${a.category} 스탠다드',
                          style: const TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.5,
                            height: 1.18,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '기준 2인 · 체크인 ${a.checkInTime}',
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: YanoljaColors.textSecondary,
                            fontWeight: FontWeight.w600,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '$rate%',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: YanoljaColors.sale,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            '${YanoljaFormat.price(original)}원',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: YanoljaColors.textTertiary,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${YanoljaFormat.price(a.price)}원',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: -0.6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _openGallery(context, a),
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(2),
                ),
                child: SizedBox(
                  height: 168,
                  width: double.infinity,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (imageUrl == null)
                        _buildHeroImagePlaceholder()
                      else
                        CachedNetworkImage(
                          imageUrl: imageUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) =>
                              Container(color: YanoljaColors.surfaceAlt),
                          errorWidget: (context, url, error) =>
                              _buildHeroImagePlaceholder(),
                        ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withValues(alpha: 0.48),
                            ],
                            stops: const [0.45, 1],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 14,
                        right: 14,
                        bottom: 13,
                        child: Row(
                          children: [
                            Expanded(
                              child: Wrap(
                                spacing: 7,
                                runSpacing: 7,
                                children: tags
                                    .map((tag) => _photoOverlayChip(tag))
                                    .toList(),
                              ),
                            ),
                            if (a.imageUrls.isNotEmpty) ...[
                              const SizedBox(width: 10),
                              _photoOverlayChip('${a.imageUrls.length}장'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _roomSpec(
                          Icons.login_rounded,
                          '입실',
                          a.checkInTime,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _roomSpec(
                          Icons.logout_rounded,
                          '퇴실',
                          a.checkOutTime,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: _roomSpec(
                          Icons.wifi_rounded,
                          '인터넷',
                          a.hasWifi ? '무료 Wi-Fi' : '문의',
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _roomSpec(
                          Icons.local_parking_rounded,
                          '주차',
                          a.hasParking ? '가능' : '문의',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _openGallery(context, a),
                          icon:
                              const Icon(Icons.photo_library_rounded, size: 18),
                          label: const Text('사진 보기'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: YanoljaColors.textPrimary,
                            side: const BorderSide(color: YanoljaColors.border),
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.md),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _continueBooking(context, a),
                          icon: Icon(
                            _hasSelectedStay
                                ? Icons.payment_rounded
                                : Icons.calendar_today_rounded,
                            size: 17,
                          ),
                          label: AnimatedSwitcher(
                            duration: YanoljaMotion.fast,
                            child: Text(
                              _hasSelectedStay ? '결제하기' : '날짜 선택',
                              key: ValueKey(_hasSelectedStay),
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _hasSelectedStay
                                ? YanoljaColors.textPrimary
                                : YanoljaColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(YanoljaRadius.md),
                            ),
                            textStyle: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
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
    );
  }

  Widget _buildPhotoPreviewStrip(BuildContext context, Accommodation a) {
    if (a.imageUrls.length < 2) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '사진으로 미리보기',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => _openGallery(
                    context,
                    a,
                    initialIndex: _currentImageIndex,
                  ),
                  behavior: HitTestBehavior.opaque,
                  child: Row(
                    children: [
                      Text(
                        '전체 ${a.imageUrls.length}장',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: YanoljaColors.primary,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(width: 2),
                      const Icon(Icons.chevron_right_rounded,
                          size: 18, color: YanoljaColors.primary),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: a.imageUrls.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openGallery(context, a, initialIndex: index),
                  child: SizedBox(
                    width: 126,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          CachedNetworkImage(
                            imageUrl: a.imageUrls[index],
                            fit: BoxFit.cover,
                            placeholder: (context, url) =>
                                Container(color: YanoljaColors.surfaceAlt),
                            errorWidget: (context, url, error) => Container(
                              color: YanoljaColors.surfaceAlt,
                              child: const Icon(
                                Icons.image_not_supported_outlined,
                                color: YanoljaColors.textTertiary,
                              ),
                            ),
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.transparent,
                                  Colors.black.withValues(alpha: 0.42),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            left: 10,
                            right: 10,
                            bottom: 9,
                            child: Text(
                              _photoLabel(index),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _roomSpec(IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: YanoljaColors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: YanoljaColors.textTertiary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoOverlayChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.52),
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11.5,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
    );
  }

  // ───────────────────────────────────────────── 화이트 시트 헤더
  Widget _buildHeaderSheet(BuildContext context, Accommodation accommodation) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 34, 20, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 34,
              height: 4,
              margin: const EdgeInsets.only(bottom: 18),
              decoration: BoxDecoration(
                color: YanoljaColors.divider,
                borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              ),
            ),
          ),
          _buildPremiumBadgeRail(accommodation),
          const SizedBox(height: 14),
          Text(
            accommodation.name,
            style: const TextStyle(
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: 0,
              height: 1.16,
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFF),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFFE5EAFF)),
            ),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: YanoljaSpacing.s),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [YanoljaColors.primary, Color(0xFF1539C9)],
                    ),
                    borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    boxShadow: [
                      BoxShadow(
                        color: YanoljaColors.primary.withValues(alpha: 0.22),
                        blurRadius: 14,
                        offset: const Offset(0, 7),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.star_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        accommodation.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ratingLabel(accommodation.rating),
                        style: const TextStyle(
                          color: YanoljaColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '리뷰 ${YanoljaFormat.price(accommodation.reviewCount)}개가 검증한 인기 숙소',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: YanoljaColors.textSecondary,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(YanoljaRadius.lg),
              border: Border.all(color: YanoljaColors.border),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: YanoljaColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                  ),
                  child: const Icon(
                    Icons.location_on_rounded,
                    size: 18,
                    color: YanoljaColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '${accommodation.address} · 도심 ${accommodation.distanceFromCenter.toStringAsFixed(1)}km',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      color: YanoljaColors.textSecondary,
                      height: 1.42,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
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

  // ───────────────────────────────────────────── 핵심 편의시설 스트립
  Widget _buildQuickFacts(Accommodation a) {
    final facts = <_Fact>[
      _Fact(Icons.wifi_rounded, a.hasWifi ? '무료 Wi-Fi' : 'Wi-Fi 없음', a.hasWifi),
      _Fact(Icons.local_parking_rounded, a.hasParking ? '주차 가능' : '주차 불가',
          a.hasParking),
      _Fact(Icons.free_breakfast_rounded, a.hasBreakfast ? '조식 포함' : '조식 별도',
          a.hasBreakfast),
      _Fact(Icons.login_rounded, '체크인 ${a.checkInTime}', true),
    ];

    return Container(
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FC),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Row(
        children: facts.map((f) {
          final color =
              f.enabled ? YanoljaColors.primary : YanoljaColors.textTertiary;
          return Expanded(
            child: Container(
              height: 82,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 9),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                border: Border.all(
                  color: f.enabled
                      ? color.withValues(alpha: 0.14)
                      : YanoljaColors.border,
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: f.enabled ? 0.1 : 0.05),
                      borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                    ),
                    child: Icon(f.icon, size: 19, color: color),
                  ),
                  const SizedBox(height: 7),
                  Expanded(
                    child: Text(
                      f.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11.5,
                        height: 1.18,
                        fontWeight: FontWeight.w800,
                        color: f.enabled
                            ? YanoljaColors.textPrimary
                            : YanoljaColors.textTertiary,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ───────────────────────────────────────────── 숙소 소개 (확장형)
  Widget _buildAbout(Accommodation a) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: Text(
              a.description,
              maxLines: _descExpanded ? null : 3,
              overflow:
                  _descExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                height: 1.65,
                color: YanoljaColors.textSecondary,
                letterSpacing: -0.2,
              ),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => setState(() => _descExpanded = !_descExpanded),
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Text(
                  _descExpanded ? '접기' : '더보기',
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: YanoljaColors.primary,
                  ),
                ),
                Icon(
                  _descExpanded
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: YanoljaColors.primary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────── 편의시설 그리드 (아이콘)
  Widget _buildAmenitiesGrid(
      BuildContext context, Accommodation accommodation) {
    if (accommodation.amenities.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
        child: Text('등록된 편의시설이 없습니다.',
            style: TextStyle(fontSize: 14, color: YanoljaColors.textTertiary)),
      );
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 6),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = (constraints.maxWidth - 18) / 2;
          return Wrap(
            spacing: 18,
            runSpacing: 12,
            children: accommodation.amenities.map((amenity) {
              return SizedBox(
                width: itemWidth,
                height: 42,
                child: Row(
                  children: [
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        color: YanoljaColors.primaryLight,
                        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                      ),
                      child: Icon(
                        _amenityIcon(amenity),
                        color: YanoljaColors.primary,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        amenity,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: YanoljaColors.textPrimary,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────── 근처 장소 (가로 스크롤)
  Widget _buildNearbyPlacesSection(BuildContext context, List<dynamic> items,
      {required bool isAttraction}) {
    return SizedBox(
      height: 178,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return SizedBox(
            width: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                  child: CachedNetworkImage(
                    imageUrl: isAttraction
                        ? (item as Attraction).imageUrl
                        : (item as Restaurant).imageUrl,
                    width: 150,
                    height: 104,
                    fit: BoxFit.cover,
                    placeholder: (context, url) =>
                        Container(color: YanoljaColors.surfaceAlt),
                    errorWidget: (context, url, error) => Container(
                      color: YanoljaColors.surfaceAlt,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: YanoljaColors.textTertiary),
                    ),
                  ),
                ),
                const SizedBox(height: 9),
                Text(
                  isAttraction
                      ? (item as Attraction).name
                      : (item as Restaurant).name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Row(
                  children: [
                    const Icon(Icons.directions_walk_rounded,
                        size: 13, color: YanoljaColors.textTertiary),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        isAttraction
                            ? (item as Attraction).distance
                            : '${(item as Restaurant).cuisine} · ${item.distance}',
                        style: const TextStyle(
                            fontSize: 12, color: YanoljaColors.textSecondary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ───────────────────────────────────────────── 오시는 길
  Widget _buildLocationSection(
      BuildContext context, Accommodation accommodation) {
    return Container(
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.location_on_outlined,
                    color: YanoljaColors.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    accommodation.address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: YanoljaColors.textPrimary,
                      height: 1.4,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
              child: Container(
                height: 150,
                color: YanoljaColors.surfaceAlt,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // 지도 자리표시 — 은은한 격자 느낌
                    CustomPaint(painter: _MapGridPainter()),
                    const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.place_rounded,
                              color: YanoljaColors.primary, size: 34),
                          SizedBox(height: 4),
                          Text('지도 미리보기',
                              style: TextStyle(
                                  color: YanoljaColors.textTertiary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: () => context.push('/map'),
                icon: const Icon(Icons.map_outlined, size: 19),
                label: const Text('지도에서 보기'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: YanoljaColors.primary,
                  side:
                      const BorderSide(color: YanoljaColors.primary, width: 1),
                  textStyle: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w700),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(YanoljaRadius.md)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────── 후기 (요약 + 카드)
  Widget _buildReviewSection(
    BuildContext context,
    Accommodation accommodation,
    AsyncValue<List<ReviewFeedItem>> reviewFeedAsync,
  ) {
    final reviews = reviewFeedAsync.asData?.value ??
        accommodation.reviews
            .map((review) => ReviewFeedItem.fromMock(accommodation.id, review))
            .toList();
    final previewReviews = reviews.take(2).toList();
    final storedCount = reviews.where((review) => review.isEditable).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.l),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildRatingSummary(accommodation, storedCount),
          if (reviews.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 16),
              child: Text('아직 작성된 후기가 없습니다.',
                  style: TextStyle(
                      fontSize: 14, color: YanoljaColors.textTertiary)),
            )
          else ...[
            const SizedBox(height: 16),
            ...List.generate(previewReviews.length, (index) {
              final review = previewReviews[index];
              return Padding(
                padding: EdgeInsets.only(
                    bottom: index == previewReviews.length - 1 ? 0 : 12),
                child: _buildReviewCard(
                  review,
                  onTap: () => context.push(
                    '/detail/${accommodation.id}/reviews/${review.id}',
                  ),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildRatingSummary(Accommodation a, int storedReviewCount) {
    final bars = _ratingBars(a.rating);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 큰 평점
          Column(
            children: [
              Text(
                a.rating.toStringAsFixed(1),
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: YanoljaColors.textPrimary,
                  letterSpacing: -1.5,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < a.rating.round();
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 14,
                    color: YanoljaColors.star,
                  );
                }),
              ),
              const SizedBox(height: 6),
              Text(
                '${YanoljaFormat.price(a.reviewCount + storedReviewCount)}개 후기',
                style: const TextStyle(
                    fontSize: 11.5,
                    color: YanoljaColors.textSecondary,
                    fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(width: 22),
          // 분포 막대
          Expanded(
            child: Column(
              children: List.generate(5, (i) {
                final star = 5 - i;
                final fraction = bars[i];
                return Padding(
                  padding: EdgeInsets.only(bottom: i == 4 ? 0 : 7),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 16,
                        child: Text('$star',
                            style: const TextStyle(
                                fontSize: 11.5,
                                color: YanoljaColors.textSecondary,
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: ClipRRect(
                          borderRadius:
                              BorderRadius.circular(YanoljaRadius.pill),
                          child: LinearProgressIndicator(
                            value: fraction,
                            minHeight: 6,
                            backgroundColor: YanoljaColors.border,
                            valueColor: const AlwaysStoppedAnimation(
                                YanoljaColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewCard(
    ReviewFeedItem review, {
    required VoidCallback onTap,
  }) {
    final initial =
        review.userName.isNotEmpty ? review.userName.characters.first : '익';
    return YanoljaPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // 아바타 (이니셜)
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: YanoljaColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    initial,
                    style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: YanoljaColors.primary),
                  ),
                ),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        review.userName,
                        style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.3),
                      ),
                      if (review.isEditable)
                        const Padding(
                          padding: EdgeInsets.only(top: 3),
                          child: Text(
                            '내가 작성한 후기',
                            style: TextStyle(
                              fontSize: 10.5,
                              color: YanoljaColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      const SizedBox(height: 3),
                      Row(
                        children: List.generate(
                          5,
                          (i) => Icon(
                            i < review.rating
                                ? Icons.star_rounded
                                : Icons.star_outline_rounded,
                            color: YanoljaColors.star,
                            size: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  _fmtReviewDate(review.date),
                  style: const TextStyle(
                      fontSize: 11.5, color: YanoljaColors.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              review.comment,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                  fontSize: 14,
                  color: YanoljaColors.textSecondary,
                  height: 1.55,
                  letterSpacing: -0.2),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildReviewReaction(Icons.thumb_up_alt_outlined, review.likes),
                const SizedBox(width: 16),
                _buildReviewReaction(
                    Icons.thumb_down_alt_outlined, review.dislikes),
                const Spacer(),
                const Icon(
                  Icons.chevron_right_rounded,
                  size: 18,
                  color: YanoljaColors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewReaction(IconData icon, int count) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: YanoljaColors.textTertiary),
        const SizedBox(width: 5),
        Text(count.toString(),
            style: const TextStyle(
                fontSize: 12.5, color: YanoljaColors.textSecondary)),
      ],
    );
  }

  // ───────────────────────────────────────────── 예약 바
  Widget _buildBookingBottomBar(
      BuildContext context, Accommodation? accommodation) {
    if (accommodation == null) return const SizedBox.shrink();
    final nights = _selectedNights;
    final unitPrice = accommodation.price;
    final totalPrice = nights > 0 ? nights * unitPrice : unitPrice;

    final rate = YanoljaFormat.discountRate(accommodation.id);
    final original = YanoljaFormat.originalPrice(totalPrice, rate);

    return Container(
      decoration: BoxDecoration(
        color: YanoljaColors.background,
        border: const Border(top: BorderSide(color: YanoljaColors.border)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => _selectDateRange(context),
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _hasSelectedStay
                                ? Icons.event_available_rounded
                                : Icons.calendar_today_rounded,
                            size: 14,
                            color: _hasSelectedStay
                                ? YanoljaColors.primary
                                : YanoljaColors.textSecondary,
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: Text(
                              _selectedStaySummary,
                              style: TextStyle(
                                fontSize: 12.5,
                                fontWeight: _hasSelectedStay
                                    ? FontWeight.w900
                                    : FontWeight.w600,
                                color: _hasSelectedStay
                                    ? YanoljaColors.primary
                                    : YanoljaColors.textSecondary,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Icon(Icons.keyboard_arrow_down_rounded,
                              size: 16, color: YanoljaColors.textTertiary),
                        ],
                      ),
                      const SizedBox(height: 5),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Text(
                              '쿠폰 적용가',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: YanoljaColors.textTertiary,
                                  letterSpacing: -0.2),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '$rate%',
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: YanoljaColors.sale,
                                  letterSpacing: -0.4),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              '${YanoljaFormat.price(original)}원',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: YanoljaColors.textTertiary,
                                  decoration: TextDecoration.lineThrough),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 1),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              '${YanoljaFormat.price(totalPrice)}원',
                              style: const TextStyle(
                                  fontSize: 19,
                                  fontWeight: FontWeight.w800,
                                  color: YanoljaColors.textPrimary,
                                  letterSpacing: -0.5),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              nights > 0 ? '/ $nights박' : '부터',
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: YanoljaColors.textTertiary,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'NOL 카드 결제 시 추가 혜택',
                        style: TextStyle(
                            fontSize: 11.5,
                            color: YanoljaColors.primary,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: () => _continueBooking(context, accommodation),
                  icon: Icon(
                    _hasSelectedStay
                        ? Icons.payment_rounded
                        : Icons.calendar_today_rounded,
                    size: 18,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _hasSelectedStay
                        ? YanoljaColors.textPrimary
                        : YanoljaColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    // 전역 테마의 minimumSize(Size.fromHeight=무한 너비)를 덮어써
                    // Row 안에서 콘텐츠 폭으로 배치되도록 함
                    minimumSize: const Size(0, 54),
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(YanoljaRadius.md)),
                    textStyle: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                  label: AnimatedSwitcher(
                    duration: YanoljaMotion.fast,
                    child: Text(
                      _hasSelectedStay ? '결제하기' : '날짜 선택',
                      key: ValueKey(_hasSelectedStay),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ───────────────────────────────────────────── 공용 헬퍼
  Widget _buildSectionDivider() =>
      Container(height: 8, color: YanoljaColors.surfaceAlt);

  Widget _sectionTitle(
    String title, {
    String? action,
    VoidCallback? onAction,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 26, 20, 14),
      child: Row(
        children: [
          Container(
            width: 3.5,
            height: 18,
            decoration: BoxDecoration(
                color: YanoljaColors.primary,
                borderRadius: BorderRadius.circular(2)),
          ),
          const SizedBox(width: 9),
          Text(
            title,
            style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.4),
          ),
          const Spacer(),
          if (action != null)
            YanoljaPressable(
              onTap: onAction,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Text(action,
                        style: const TextStyle(
                            fontSize: 13,
                            color: YanoljaColors.textSecondary,
                            fontWeight: FontWeight.w500)),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: YanoljaColors.textTertiary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPremiumBadgeRail(Accommodation a) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _premiumBadge(
          icon: Icons.diamond_outlined,
          text: a.category,
          foregroundColor: YanoljaColors.primary,
          backgroundColor: YanoljaColors.primaryLight,
          borderColor: const Color(0xFFDCE5FF),
        ),
        if (a.isPopular)
          _premiumBadge(
            icon: Icons.local_fire_department_rounded,
            text: '인기 숙소',
            foregroundColor: Colors.white,
            backgroundColor: YanoljaColors.primary,
            borderColor: YanoljaColors.primary,
            elevated: true,
          ),
        if (a.isNew)
          _premiumBadge(
            icon: Icons.auto_awesome_rounded,
            text: '신규 오픈',
            foregroundColor: const Color(0xFF0B7E73),
            backgroundColor: const Color(0xFFE7FAF7),
            borderColor: const Color(0xFFC7F1EA),
          ),
      ],
    );
  }

  Widget _premiumBadge({
    required IconData icon,
    required String text,
    required Color foregroundColor,
    required Color backgroundColor,
    required Color borderColor,
    bool elevated = false,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        border: Border.all(color: borderColor),
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.24),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              color: foregroundColor,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }

  String _ratingLabel(double rating) {
    if (rating >= 4.5) return '최고예요';
    if (rating >= 4.0) return '아주 좋아요';
    if (rating >= 3.5) return '좋아요';
    if (rating >= 3.0) return '괜찮아요';
    return '보통이에요';
  }

  List<String> _roomTags(Accommodation a) {
    final source = <String>[
      if (a.theme != null && a.theme!.trim().isNotEmpty) a.theme!,
      ...?a.tags,
      ...a.amenities,
    ];
    final seen = <String>{};
    final tags = <String>[];

    for (final item in source) {
      final trimmed = item.trim();
      if (trimmed.isEmpty || seen.contains(trimmed)) continue;
      seen.add(trimmed);
      tags.add(trimmed);
      if (tags.length == 3) break;
    }

    return tags.isEmpty ? ['예약 추천', '실시간 특가'] : tags;
  }

  String _photoLabel(int index) {
    const labels = ['대표 사진', '객실', '욕실', '부대시설', '전망', '주변'];
    if (index < labels.length) return labels[index];
    return '사진 ${index + 1}';
  }

  /// 평점 기반 5/4/3/2/1점 분포 비율(0~1) — 데모용 결정적 추정
  List<double> _ratingBars(double rating) {
    final r = rating.clamp(0.0, 5.0);
    final five = (r / 5.0).clamp(0.0, 1.0);
    return [
      (0.45 + five * 0.5).clamp(0.05, 1.0),
      (0.35 + five * 0.35).clamp(0.05, 0.95),
      (0.6 - five * 0.35).clamp(0.04, 0.7),
      (0.4 - five * 0.3).clamp(0.02, 0.5),
      (0.3 - five * 0.25).clamp(0.01, 0.4),
    ];
  }

  IconData _amenityIcon(String a) {
    if (a.contains('와이파이') ||
        a.toLowerCase().contains('wifi') ||
        a.contains('인터넷')) {
      return Icons.wifi_rounded;
    }
    if (a.contains('주차')) {
      return Icons.local_parking_rounded;
    }
    if (a.contains('수영') ||
        a.contains('풀') ||
        a.toLowerCase().contains('pool')) {
      return Icons.pool_rounded;
    }
    if (a.contains('조식') || a.contains('아침')) {
      return Icons.free_breakfast_rounded;
    }
    if (a.contains('바베큐') ||
        a.contains('바비큐') ||
        a.toLowerCase().contains('bbq')) {
      return Icons.outdoor_grill_rounded;
    }
    if (a.contains('스파') ||
        a.contains('사우나') ||
        a.contains('온천') ||
        a.contains('월풀')) {
      return Icons.hot_tub_rounded;
    }
    if (a.contains('피트니스') || a.contains('헬스') || a.contains('짐')) {
      return Icons.fitness_center_rounded;
    }
    if (a.contains('레스토랑') || a.contains('식당')) {
      return Icons.restaurant_rounded;
    }
    if (a.contains('카페') ||
        a.contains('라운지') ||
        a.contains('바/') ||
        a.contains('미니바')) {
      return Icons.local_cafe_rounded;
    }
    if (a.contains('반려') || a.contains('애완')) {
      return Icons.pets_rounded;
    }
    if (a.contains('온돌') || a.contains('난방')) {
      return Icons.whatshot_rounded;
    }
    if (a.contains('마당') || a.contains('정원') || a.contains('테라스')) {
      return Icons.deck_rounded;
    }
    if (a.contains('주방') || a.contains('취사') || a.contains('조리')) {
      return Icons.kitchen_rounded;
    }
    if (a.contains('세탁')) {
      return Icons.local_laundry_service_rounded;
    }
    if (a.contains('컨시어지') ||
        a.contains('프런트') ||
        a.contains('룸서비스') ||
        a.contains('24')) {
      return Icons.room_service_rounded;
    }
    if (a.contains('비즈니스') || a.contains('회의')) {
      return Icons.business_center_rounded;
    }
    if (a.contains('금연')) {
      return Icons.smoke_free_rounded;
    }
    if (a.contains('엘리베이터')) {
      return Icons.elevator_rounded;
    }
    if (a.contains('오션') || a.contains('바다') || a.contains('뷰')) {
      return Icons.water_rounded;
    }
    if (a.contains('한복') || a.contains('전통') || a.contains('문화')) {
      return Icons.festival_rounded;
    }
    return Icons.check_circle_rounded;
  }

  String _fmtDate(DateTime date) => '${date.month}.${date.day}';

  String _fmtReviewDate(DateTime date) =>
      '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
}

class _Fact {
  final IconData icon;
  final String label;
  final bool enabled;
  const _Fact(this.icon, this.label, this.enabled);
}

/// 지도 자리표시용 은은한 격자 페인터
class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = YanoljaColors.border
      ..strokeWidth = 1;
    const step = 28.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
