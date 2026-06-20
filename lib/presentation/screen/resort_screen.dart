import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/nol_category_list_screen.dart';

class ResortScreen extends StatelessWidget {
  const ResortScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NolCategoryListScreen(
      title: '리조트',
      serviceLabel: '리조트',
      heroTitle: '리조트 NOLDAY 특가',
      heroSubtitle: '오션뷰·스파·워터파크 숙소를 쿠폰가로',
      heroIcon: Icons.beach_access_rounded,
      accentColor: YanoljaColors.primaryPurple,
      filters: const ['전체', '오션뷰', '스파', '워터파크', '프리미엄', '특가'],
      baseFilter: (accommodation) => accommodation.category == '리조트',
      filterPredicate: (accommodation, filter) {
        switch (filter) {
          case '오션뷰':
            return nolAccommodationContains(
              accommodation,
              ['오션뷰', '바다', '해변', '씨뷰'],
            );
          case '스파':
            return nolAccommodationContains(
              accommodation,
              ['스파', '사우나', '온천', '웰니스'],
            );
          case '워터파크':
            return nolAccommodationContains(
              accommodation,
              ['워터파크', '수영장', '풀', '키즈풀'],
            );
          case '프리미엄':
            return accommodation.isPopular ||
                accommodation.rating >= 4.7 ||
                accommodation.price >= 220000;
          case '특가':
            return accommodation.isNew ||
                accommodation.isPopular ||
                accommodation.price <= 190000;
          default:
            return true;
        }
      },
      emptyIcon: Icons.beach_access_outlined,
      emptyTitle: '조건에 맞는 리조트가 없어요',
    );
  }
}
