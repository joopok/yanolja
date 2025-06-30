import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 🆕 햅틱 피드백용
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';
import 'package:yanolja_clone/presentation/widget/fullscreen_image_gallery.dart'; // 🆕 풀스크린 갤러리 import

class DetailScreen extends ConsumerStatefulWidget {
  final String accommodationId;
  const DetailScreen({super.key, required this.accommodationId});

  @override
  ConsumerState<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends ConsumerState<DetailScreen> {
  DateTimeRange? _selectedDateRange;
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController = CarouselSliderController();

  Future<void> _selectDateRange(BuildContext context) async {
    final initialDateRange = _selectedDateRange ??
        DateTimeRange(
          start: DateTime.now(),
          end: DateTime.now().add(const Duration(days: 1)),
        );

    final newDateRange = await showDateRangePicker(
      context: context,
      initialDateRange: initialDateRange,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Colors.white,
                ),
          ),
          child: child!,
        );
      },
    );

    if (newDateRange != null) {
      setState(() {
        _selectedDateRange = newDateRange;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final detailAsyncValue = ref.watch(accommodationDetailProvider(widget.accommodationId));

    return Scaffold(
      body: detailAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러: $err')),
        data: (accommodation) {
          return CustomScrollView(
            slivers: [
              _buildSliverAppBar(context, ref, accommodation),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTitleSection(context, accommodation),
                      const SizedBox(height: 24),
                      _buildInfoSection(context, accommodation),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle(context, '숙소 소개', Icons.article_outlined),
                      const SizedBox(height: 16),
                      Text(accommodation.description, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.6)),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle(context, '근처 가볼만한 곳', Icons.attractions_outlined),
                      const SizedBox(height: 16),
                      _buildNearbyPlacesSection(context, accommodation.nearbyAttractions, isAttraction: true),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle(context, '근처 맛집', Icons.restaurant_menu_outlined),
                      const SizedBox(height: 16),
                      _buildNearbyPlacesSection(context, accommodation.nearbyRestaurants, isAttraction: false),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle(context, '추천 포인트', Icons.thumb_up_alt_outlined),
                      const SizedBox(height: 16),
                      _buildAmenitiesGrid(context, accommodation),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle(context, '오시는 길', Icons.map_outlined),
                      const SizedBox(height: 16),
                      _buildLocationSection(context, accommodation),
                      const Divider(height: 48, thickness: 1),
                      _buildSectionTitle(context, '실제 이용객 후기', Icons.reviews_outlined),
                      const SizedBox(height: 16),
                      _buildReviewSection(context, accommodation),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: _buildBookingBottomBar(context, ref, detailAsyncValue.asData?.value),
    );
  }

  Widget _buildNearbyPlacesSection(BuildContext context, List<dynamic> items, {required bool isAttraction}) {
    if (items.isEmpty) {
      return Center(child: Text(isAttraction ? '근처 가볼만한 곳이 없습니다.' : '근처 맛집이 없습니다.'));
    }

    return SizedBox(
      height: 180, // Adjust height as needed
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 150, // Adjust width as needed
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedNetworkImage(
                    imageUrl: isAttraction ? (item as Attraction).imageUrl : (item as Restaurant).imageUrl,
                    width: 150,
                    height: 100,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(color: Colors.grey[200]),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  isAttraction ? (item as Attraction).name : (item as Restaurant).name,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  isAttraction ? (item as Attraction).distance : '${(item as Restaurant).cuisine} - ${(item as Restaurant).distance}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, WidgetRef ref, Accommodation accommodation) {
    final isSaved = ref.watch(savedProvider).contains(accommodation.id);
    return SliverAppBar(
      expandedHeight: 300.0,
      floating: false,
      pinned: true,
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.5),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isSaved ? Theme.of(context).colorScheme.secondary : Colors.white,
          ),
          onPressed: () {
            ref.read(savedProvider.notifier).toggleSaved(accommodation.id);
          },
          style: IconButton.styleFrom(
            backgroundColor: Colors.black.withOpacity(0.5),
          ),
        ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            GestureDetector(
              // 스와이핑 제스처를 가로채서 CarouselSlider로 전달
              onHorizontalDragUpdate: (details) {
                // 가로 드래그 제스처가 감지되면 스크롤 무시
              },
              child: CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: true,
                  autoPlay: false,
                  // 스와이핑 감도 개선
                  scrollPhysics: const BouncingScrollPhysics(),
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: accommodation.imageUrls.asMap().entries.map((entry) {
                  final index = entry.key;
                  final imageUrl = entry.value;
                  return GestureDetector(
                    onTap: () {
                      // 🚀 풀스크린 이미지 갤러리 열기
                      HapticFeedback.lightImpact();
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          opaque: false, // 투명 배경
                          pageBuilder: (context, animation, secondaryAnimation) => 
                            FullscreenImageGallery(
                              imageUrls: accommodation.imageUrls,
                              initialIndex: index,
                              heroTag: 'accommodation-image-$index',
                            ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 300),
                        ),
                      );
                    },
                    child: Hero(
                      tag: 'accommodation-image-$index', // Hero 애니메이션용 태그
                      child: CachedNetworkImage(
                        imageUrl: imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: Colors.grey[200],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          color: Colors.grey[200],
                          child: const Icon(Icons.error, size: 50),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
                  stops: const [0.5, 1.0],
                ),
              ),
            ),
            if (accommodation.imageUrls.length > 1)
              Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: Center(
                  child: AnimatedSmoothIndicator(
                    activeIndex: _currentImageIndex,
                    count: accommodation.imageUrls.length,
                    effect: WormEffect(
                      dotWidth: 8,
                      dotHeight: 8,
                      spacing: 4,
                      dotColor: Colors.white.withValues(alpha: 0.5),
                      activeDotColor: Colors.white,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitleSection(BuildContext context, Accommodation accommodation) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            accommodation.name,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 16),
        Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.white, size: 20),
                  const SizedBox(width: 4),
                  Text(
                    accommodation.rating.toString(),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text('(${accommodation.reviewCount}개 후기)', style: Theme.of(context).textTheme.bodySmall)
          ],
        ),
      ],
    );
  }

  Widget _buildInfoSection(BuildContext context, Accommodation accommodation) {
    return Column(
      children: [
        _buildInfoRow(context, Icons.category_outlined, accommodation.category),
        const SizedBox(height: 12),
        _buildInfoRow(context, Icons.access_time_rounded, '체크인 ${accommodation.checkInTime} / 체크아웃 ${accommodation.checkOutTime}'),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 12),
        Text(text, style: Theme.of(context).textTheme.bodyLarge),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
        const SizedBox(width: 12),
        Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildAmenitiesGrid(BuildContext context, Accommodation accommodation) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: accommodation.amenities.length,
      itemBuilder: (context, index) {
        final amenity = accommodation.amenities[index];
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.green, size: 18),
              const SizedBox(width: 8),
              Expanded(child: Text(amenity, style: Theme.of(context).textTheme.bodyMedium, overflow: TextOverflow.ellipsis)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationSection(BuildContext context, Accommodation accommodation) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.location_on_outlined, color: Theme.of(context).colorScheme.primary, size: 24),
                const SizedBox(width: 12),
                Expanded(child: Text(accommodation.address, style: Theme.of(context).textTheme.bodyLarge)),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              height: 150,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
              ),
              child: const Center(child: Text('[지도 영역]', style: TextStyle(color: Colors.grey))),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () { /* TODO: 지도 앱 연동 */ },
              icon: const Icon(Icons.open_in_new_rounded),
              label: const Text('지도에서 보기'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSection(BuildContext context, Accommodation accommodation) {
    final reviews = accommodation.reviews ?? [];
    if (reviews.isEmpty) {
      return const Center(child: Text('아직 작성된 후기가 없습니다.'));
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: reviews.length,
      itemBuilder: (context, index) {
        final review = reviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(review.userName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Row(
                      children: List.generate(5, (i) => Icon(
                        i < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                        color: Colors.amber, size: 18,
                      )),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(review.comment, style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.5)),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(onPressed: () {}, icon: const Icon(Icons.thumb_up_alt_outlined, size: 20)),
                    Text(review.likes.toString()),
                    const SizedBox(width: 16),
                    IconButton(onPressed: () {}, icon: const Icon(Icons.thumb_down_alt_outlined, size: 20)),
                    Text(review.dislikes.toString()),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBookingBottomBar(BuildContext context, WidgetRef ref, Accommodation? accommodation) {
    if (accommodation == null) return const SizedBox.shrink();
    final formatter = NumberFormat('#,###');
    final nights = _selectedDateRange != null ? _selectedDateRange!.duration.inDays : 0;
    final totalPrice = nights * accommodation.price;

    return BottomAppBar(
      height: 90,
      elevation: 10,
      shadowColor: Colors.black.withOpacity(0.2),
      surfaceTintColor: Theme.of(context).colorScheme.surface,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              onTap: () => _selectDateRange(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        const Text('숙박 기간', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (_selectedDateRange == null)
                      Text('날짜를 선택해주세요', style: Theme.of(context).textTheme.bodyLarge)
                    else
                      Text(
                        '${DateFormat('M월 d일').format(_selectedDateRange!.start)} - ${DateFormat('M월 d일').format(_selectedDateRange!.end)} ($nights박)',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                      ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          ElevatedButton(
              onPressed: _selectedDateRange == null
                  ? null
                  : () {
                      final user = ref.read(authStateChangesProvider).asData?.value;
                      if (user == null) {
                        context.push('/login');
                      } else {
                        _showBookingConfirmationDialog(context, accommodation, nights, totalPrice);
                      }
                    },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('예약하기'),
                if (totalPrice > 0)
                  Text('(${formatter.format(totalPrice)}원)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showBookingConfirmationDialog(BuildContext context, Accommodation accommodation, int nights, int totalPrice) {
    final formatter = NumberFormat('#,###');
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('예약 확인', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('숙소: ${accommodation.name}'),
              Text('기간: ${DateFormat('M월 d일').format(_selectedDateRange!.start)} - ${DateFormat('M월 d일').format(_selectedDateRange!.end)}'),
              Text('숙박: $nights박'),
              Text('총 금액: ${formatter.format(totalPrice)}원', style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${accommodation.name} 예약이 완료되었습니다!'),
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: const Text('확인'),
            ),
          ],
        );
      },
    );
  }
}
