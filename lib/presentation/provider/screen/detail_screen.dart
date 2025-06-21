import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/saved_provider.dart';

class DetailScreen extends ConsumerWidget {
  final String accommodationId;
  const DetailScreen({super.key, required this.accommodationId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsyncValue =
        ref.watch(accommodationDetailProvider(accommodationId));
    final formatter = NumberFormat('#,###');

    return Scaffold(
      body: detailAsyncValue.when(
        loading: () => const Center(child: CircularProgressIndicator()), 
        error: (err, stack) => Center(child: Text('에러: $err')),
        data: (accommodation) {
          final isSaved = ref.watch(savedProvider).contains(accommodationId);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 250.0,
                floating: false,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(accommodation.name,
                      style: const TextStyle(shadows: [
                        Shadow(color: Colors.black, blurRadius: 8)
                      ])),
                  background: CachedNetworkImage(
                    imageUrl: accommodation.imageUrls.first,
                    fit: BoxFit.cover,
                  ),
                ),
                actions: [
                  IconButton(
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : Colors.white,
                    ),
                    onPressed: () {
                      ref.read(savedProvider.notifier).toggleSaved(accommodationId);
                    },
                  ),
                ],
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            accommodation.name,
                            style: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.amber),
                              Text('${accommodation.rating}',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                            ],
                          )
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(accommodation.address,
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey[600])),
                      const SizedBox(height: 16),
                      Text(
                        '${formatter.format(accommodation.price)}원 / 1박',
                        style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.pink),
                      ),
                      const Divider(height: 32),
                      const Text('숙소 소개',
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text(
                        accommodation.description,
                        style: const TextStyle(fontSize: 16, height: 1.5),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
