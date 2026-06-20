import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/nol_category_list_screen.dart';

class PensionScreen extends StatelessWidget {
  const PensionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NolCategoryListScreen(
      title: '펜션',
      serviceLabel: '펜션',
      heroTitle: '펜션/풀빌라 NOLDAY 특가',
      heroSubtitle: '가평·제주·속초 인기 펜션 쿠폰 적용가',
      heroIcon: Icons.cottage_rounded,
      accentColor: YanoljaColors.primary,
      filters: const ['전체', '가족', '연인', '수영장', '바베큐', '특가'],
      baseFilter: (accommodation) => accommodation.category == '펜션',
      filterPredicate: (accommodation, filter) {
        switch (filter) {
          case '가족':
            return accommodation.theme == '가족' ||
                nolAccommodationContains(
                  accommodation,
                  ['가족', '키즈', '놀이시설', '대형정원'],
                );
          case '연인':
            return accommodation.theme == '연인' ||
                nolAccommodationContains(
                  accommodation,
                  ['연인', '로맨틱', '프라이빗', '오션뷰'],
                );
          case '수영장':
            return nolAccommodationContains(
              accommodation,
              ['수영장', '풀', '온수풀', '풀빌라'],
            );
          case '바베큐':
            return nolAccommodationContains(
              accommodation,
              ['바베큐', 'bbq', '캠프파이어', '그릴'],
            );
          case '특가':
            return accommodation.isPopular ||
                accommodation.isNew ||
                accommodation.price <= 150000;
          default:
            return true;
        }
      },
      emptyIcon: Icons.cottage_outlined,
      emptyTitle: '조건에 맞는 펜션이 없어요',
    );
  }
}
