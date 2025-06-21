import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedProvider);
    final allAccommodationsAsync = ref.watch(accommodationListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('찜한 숙소'),
        centerTitle: true,
      ),
      body: allAccommodationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('오류: $err')),
        data: (allAccommodations) {
          final savedAccommodations = allAccommodations
              .where((acc) => savedIds.contains(acc.id))
              .toList();

          if (savedAccommodations.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '마음에 드는 숙소를 찜 해보세요!',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: savedAccommodations.length,
            itemBuilder: (context, index) {
              final accommodation = savedAccommodations[index];
              return Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
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
                    child: AccommodationListItem(accommodation: accommodation),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
} 