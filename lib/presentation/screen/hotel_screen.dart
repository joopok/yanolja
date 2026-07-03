import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/nol_category_list_screen.dart';

class HotelScreen extends StatelessWidget {
  const HotelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NolCategoryListScreen(
      title: '호텔',
      serviceLabel: '호텔',
      heroTitle: '호텔 NOLDAY 특가',
      heroSubtitle: '5성급부터 시티호텔까지 쿠폰 적용가로',
      heroIcon: Icons.hotel_rounded,
      accentColor: YanoljaColors.primary,
      filters: const ['전체', '서울', '부산', '제주', '강릉', '5성급', '특가'],
      baseFilter: (accommodation) => accommodation.category.contains('호텔'),
      filterPredicate: (accommodation, filter) {
        switch (filter) {
          case '5성급':
            return accommodation.rating >= 4.7 || accommodation.price >= 250000;
          case '특가':
            return accommodation.isNew ||
                accommodation.isPopular ||
                accommodation.price <= 130000;
          default:
            // 지역 필터: 주소에 지역명이 포함되는지 확인
            return accommodation.address.contains(filter);
        }
      },
      emptyIcon: Icons.hotel_outlined,
      emptyTitle: '조건에 맞는 호텔이 없어요',
    );
  }
}
