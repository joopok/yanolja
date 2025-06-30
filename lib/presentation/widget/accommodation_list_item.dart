import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

// 목록의 각 항목을 표시하는 재사용 가능한 위젯
class AccommodationListItem extends ConsumerStatefulWidget {
  final Accommodation accommodation;
  const AccommodationListItem({super.key, required this.accommodation});

  @override
  ConsumerState<AccommodationListItem> createState() => _AccommodationListItemState();
}

class _AccommodationListItemState extends ConsumerState<AccommodationListItem> {
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat('#,###');

    return GestureDetector(
      onTap: () {
        // 아이템 클릭 시 상세 화면으로 이동
        context.push('/detail/${widget.accommodation.id}');
      },
      child: Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.95),
            Colors.white.withOpacity(0.85),
          ],
        ),
        border: Border.all(
          color: Colors.white.withOpacity(0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(0.08),
            blurRadius: 32,
            offset: const Offset(0, 12),
            spreadRadius: 0,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 이미지 섹션 - Modern style
            _buildModernImageSection(),
            // 콘텐츠 섹션 - Enhanced
            _buildModernContentSection(formatter, context),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildModernImageSection() {
    return Stack(
      children: [
        // 메인 이미지
        SizedBox(
          height: 280,
          width: double.infinity,
          child: widget.accommodation.imageUrls.length > 1 
            ? CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: 280,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: widget.accommodation.imageUrls.map((imageUrl) {
                  return CachedNetworkImage(
                    imageUrl: imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[100],
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).primaryColor,
                          ),
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[100],
                      child: const Icon(Icons.image_not_supported, 
                        color: Colors.grey, size: 40),
                    ),
                  );
                }).toList(),
              )
            : CachedNetworkImage(
                imageUrl: widget.accommodation.imageUrls.first,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  color: Colors.grey[100],
                  child: Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).primaryColor,
                      ),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.image_not_supported, 
                    color: Colors.grey, size: 40),
                ),
              ),
        ),
        
        // 상단 오버레이 (배지들)
        Positioned(
          top: 16,
          left: 16,
          right: 16,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  if (widget.accommodation.isNew) _buildBadge('NEW', const Color(0xFF10B981)),
                  if (widget.accommodation.isPopular) 
                    _buildBadge('인기', const Color(0xFFFF6B6B)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  widget.accommodation.category,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // 하트 버튼
        Positioned(
          top: 16,
          right: 16,
          child: Consumer(
            builder: (context, ref, child) {
              return _buildHeartButton(context, ref);
            },
          ),
        ),
        
        // 하단 그라데이션
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 60,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.3),
                ],
              ),
            ),
          ),
        ),
        
        // 이미지 인디케이터
        if (widget.accommodation.imageUrls.length > 1)
          Positioned(
            bottom: 12,
            right: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '${_currentImageIndex + 1} / ${widget.accommodation.imageUrls.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeartButton(BuildContext context, WidgetRef ref) {
    final savedNotifier = ref.read(savedProvider.notifier);
    final isSaved = ref.watch(savedProvider).contains(widget.accommodation.id);
    
    return GestureDetector(
      onTap: () {
        savedNotifier.toggleSaved(widget.accommodation.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSaved 
                ? '${widget.accommodation.name}이(가) 찜 목록에서 제거되었습니다'
                : '${widget.accommodation.name}이(가) 찜 목록에 추가되었습니다',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: const Color(0xFF1F2937),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSaved 
            ? const Color(0xFFFF6B6B)
            : Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: Colors.white,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withValues(alpha: 0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildModernContentSection(NumberFormat formatter, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 호텔명과 평점
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.accommodation.name,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                    fontSize: 20,
                    color: const Color(0xFF1F2937),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 16),
              _buildRatingChip(),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 주소
          Row(
            children: [
              Icon(Icons.location_on_outlined, 
                size: 16, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  widget.accommodation.address,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${widget.accommodation.distanceFromCenter}km',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // 편의시설
          _buildAmenities(),
          
          const SizedBox(height: 16),
          
          // 가격과 리뷰
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildPriceSection(formatter, context),
              _buildReviewSection(context),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRatingChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFFFB74D)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB74D).withValues(alpha: 0.3),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded, 
            color: Colors.white, size: 16),
          const SizedBox(width: 4),
          Text(
            widget.accommodation.rating.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    final displayAmenities = widget.accommodation.amenities.take(3).toList();
    if (displayAmenities.isEmpty) return const SizedBox.shrink();
    
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ...displayAmenities.map((amenity) => Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFE2E8F0),
                width: 1,
              ),
            ),
            child: Text(
              amenity,
              style: const TextStyle(
                fontSize: 11,
                color: Color(0xFF64748B),
                fontWeight: FontWeight.w500,
              ),
            ),
          )),
          if (widget.accommodation.amenities.length > 3)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                '+${widget.accommodation.amenities.length - 3}',
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF475569),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPriceSection(NumberFormat formatter, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFFF6B6B).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text(
            '1박 기준',
            style: TextStyle(
              color: Color(0xFFFF6B6B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: formatter.format(widget.accommodation.price),
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFFFF6B6B),
                  fontFamily: 'SF Pro Display',
                  letterSpacing: -0.5,
                ),
              ),
              const TextSpan(
                text: '원',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF6B6B),
                  fontFamily: 'SF Pro Display',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReviewSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE2E8F0),
              width: 1,
            ),
          ),
          child: Text(
            '${widget.accommodation.reviewCount}개 후기',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...List.generate(5, (index) => Padding(
              padding: const EdgeInsets.only(left: 1),
              child: Icon(
                index < widget.accommodation.rating.floor() 
                  ? Icons.star_rounded 
                  : Icons.star_outline_rounded,
                size: 16,
                color: index < widget.accommodation.rating.floor()
                  ? const Color(0xFFFFD700)
                  : const Color(0xFFE2E8F0),
              ),
            )),
          ],
        ),
      ],
    );
  }
}
