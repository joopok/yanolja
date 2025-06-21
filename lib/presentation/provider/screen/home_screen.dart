import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // accommodationListProvider를 구독하여 데이터의 변화를 감지합니다.
    final accommodationsAsyncValue = ref.watch(accommodationListProvider);

    final List<String> imageList = [
      'https://images.unsplash.com/photo-1520250497591-112f2f40a3f4?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1566073771259-6a8506099945?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1542314831-068cd1dbb5eb?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D',
      'https://images.unsplash.com/photo-1445019980597-93e8fb7ce46b?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D'
    ];

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(accommodationListProvider.future),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 200.0,
              floating: true,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('여기어때',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0)),
                background: CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    viewportFraction: 1.0,
                    enlargeCenterPage: false,
                  ),
                  items: imageList.map((i) {
                    return Builder(
                      builder: (BuildContext context) {
                        return Image.network(
                          i,
                          fit: BoxFit.fill,
                          width: MediaQuery.of(context).size.width,
                        );
                      },
                    );
                  }).toList(),
                ),
                stretchModes: const [StretchMode.zoomBackground],
              ),
            ),
            accommodationsAsyncValue.when(
              loading: () =>
                  const SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
              error: (err, stack) =>
                  SliverFillRemaining(child: Center(child: Text('에러가 발생했습니다: $err'))),
              data: (accommodations) {
                return AnimationLimiter(
                  child: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final accommodation = accommodations[index];
                        return AnimationConfiguration.staggeredList(
                          position: index,
                          duration: const Duration(milliseconds: 375),
                          child: SlideAnimation(
                            verticalOffset: 50.0,
                            child: FadeInAnimation(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0, vertical: 4.0),
                                child: Card(
                                  elevation: 3,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      context.push('/detail/${accommodation.id}');
                                    },
                                    borderRadius: BorderRadius.circular(15.0),
                                    child: AccommodationListItem(
                                        accommodation: accommodation),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: accommodations.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
