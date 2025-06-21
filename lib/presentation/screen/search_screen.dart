import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/widget/accommodation_list_item.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _searchQuery = '';
  final List<String> _suggestionChips = ['호텔', '펜션', '리조트', '게스트하우스'];
  String? _selectedChip;

  @override
  Widget build(BuildContext context) {
    final accommodationsAsyncValue = ref.watch(accommodationListProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('숙소 검색'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                  _selectedChip = null; // 검색어 입력 시 칩 선택 해제
                });
              },
              decoration: InputDecoration(
                hintText: '어떤 숙소를 찾으세요?',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Wrap(
              spacing: 8.0,
              children: _suggestionChips.map((chip) {
                return FilterChip(
                  label: Text(chip),
                  selected: _selectedChip == chip,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedChip = chip;
                        _searchQuery = chip; // 칩 선택 시 검색어 자동 설정
                      } else {
                        _selectedChip = null;
                        _searchQuery = '';
                      }
                    });
                  },
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: accommodationsAsyncValue.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('에러: $err')),
              data: (accommodations) {
                // 검색어와 선택된 칩으로 숙소 필터링
                final filteredAccommodations = accommodations.where((acc) {
                  final query = _searchQuery.toLowerCase();
                  return acc.name.toLowerCase().contains(query);
                }).toList();

                if (filteredAccommodations.isEmpty) {
                  return const Center(child: Text('검색 결과가 없습니다.'));
                }
                
                return ListView.builder(
                  itemCount: filteredAccommodations.length,
                  itemBuilder: (context, index) {
                    final accommodation = filteredAccommodations[index];
                    return Padding(
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
                          child:
                              AccommodationListItem(accommodation: accommodation),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 