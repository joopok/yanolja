import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

// 목록의 각 항목을 표시하는 재사용 가능한 위젯 (NOL 숙소 리스트 스타일)
class AccommodationListItem extends ConsumerStatefulWidget {
  final Accommodation accommodation;
  const AccommodationListItem({super.key, required this.accommodation});

  @override
  ConsumerState<AccommodationListItem> createState() =>
      _AccommodationListItemState();
}

class _AccommodationListItemState extends ConsumerState<AccommodationListItem> {
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.push('/detail/${widget.accommodation.id}');
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 12, 20, 14),
        color: YanoljaColors.surface,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildImageSection(),
            _buildContentSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      child: Stack(
        children: [
          SizedBox(
            height: 186,
            width: double.infinity,
            child: widget.accommodation.imageUrls.length > 1
                ? CarouselSlider(
                    carouselController: _carouselController,
                    options: CarouselOptions(
                      height: 186,
                      viewportFraction: 1.0,
                      enableInfiniteScroll: true,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentImageIndex = index;
                        });
                      },
                    ),
                    items: widget.accommodation.imageUrls.map((imageUrl) {
                      return _buildImage(imageUrl);
                    }).toList(),
                  )
                : _buildImage(widget.accommodation.imageUrls.first),
          ),
          if (widget.accommodation.isNew || widget.accommodation.isPopular)
            Positioned(
              top: 12,
              left: 12,
              child: Row(
                children: [
                  if (widget.accommodation.isNew)
                    _buildBadge('신규', YanoljaColors.mint),
                  if (widget.accommodation.isPopular)
                    _buildBadge('많이 찾는 숙소', Colors.black87),
                ],
              ),
            ),
          Positioned(
            top: 8,
            right: 8,
            child: _buildHeartButton(context, ref),
          ),
          if (widget.accommodation.imageUrls.length > 1)
            Positioned(
              bottom: 10,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
                child: Text(
                  '${_currentImageIndex + 1} / ${widget.accommodation.imageUrls.length} +',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImage(String imageUrl) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      placeholder: (context, url) => Container(
        color: YanoljaColors.surfaceAlt,
      ),
      errorWidget: (context, url, error) => Container(
        color: YanoljaColors.surfaceAlt,
        child: const Icon(
          Icons.image_not_supported_outlined,
          color: YanoljaColors.textTertiary,
          size: 36,
        ),
      ),
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
            backgroundColor: YanoljaColors.textPrimary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(YanoljaRadius.md),
            ),
            margin: const EdgeInsets.all(16),
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          color: isSaved ? YanoljaColors.primary : Colors.white,
          size: 26,
          shadows: const [
            Shadow(
              color: Color(0x40000000),
              blurRadius: 4,
              offset: Offset(0, 1),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(YanoljaRadius.sm),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),
    );
  }

  Widget _buildContentSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 12, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(YanoljaRadius.sm),
                ),
                child: Text(
                  widget.accommodation.category,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.primary,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  '${widget.accommodation.address} · ${widget.accommodation.distanceFromCenter}km',
                  style: const TextStyle(
                    fontSize: 12,
                    color: YanoljaColors.textTertiary,
                    letterSpacing: -0.2,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 6),

          Text(
            widget.accommodation.name,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              height: 1.25,
              letterSpacing: -0.4,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          const SizedBox(height: 6),

          YanoljaRating(
            rating: widget.accommodation.rating,
            reviewCount: widget.accommodation.reviewCount,
          ),

          // 편의시설
          if (widget.accommodation.amenities.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildAmenities(),
          ],

          const SizedBox(height: 12),

          _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildAmenities() {
    final displayAmenities = widget.accommodation.amenities.take(3).toList();

    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        ...displayAmenities.map(
          (amenity) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: YanoljaColors.surfaceAlt,
              borderRadius: BorderRadius.circular(YanoljaRadius.sm),
            ),
            child: Text(
              amenity,
              style: const TextStyle(
                fontSize: 11,
                color: YanoljaColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        if (widget.accommodation.amenities.length > 3)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: YanoljaColors.surfaceAlt,
              borderRadius: BorderRadius.circular(YanoljaRadius.sm),
            ),
            child: Text(
              '+${widget.accommodation.amenities.length - 3}',
              style: const TextStyle(
                fontSize: 11,
                color: YanoljaColors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPriceSection() {
    final price = widget.accommodation.price;
    final rate = YanoljaFormat.discountRate(widget.accommodation.id);
    final original = YanoljaFormat.originalPrice(price, rate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${YanoljaFormat.price(original)}원',
          style: const TextStyle(
            fontSize: 12,
            color: YanoljaColors.textTertiary,
            decoration: TextDecoration.lineThrough,
            decorationColor: YanoljaColors.textTertiary,
          ),
        ),
        const SizedBox(height: 2),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            const Text(
              '쿠폰 적용가 ',
              style: TextStyle(
                fontSize: 12,
                color: YanoljaColors.textTertiary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '$rate%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.sale,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              YanoljaFormat.price(price),
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
            const Text(
              '원',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '/ 1박',
              style: TextStyle(
                fontSize: 12,
                color: YanoljaColors.textTertiary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
