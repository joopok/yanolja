import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/nol_category_list_screen.dart';

class HanokScreen extends StatelessWidget {
  const HanokScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return NolCategoryListScreen(
      title: '한옥',
      serviceLabel: '한옥',
      heroTitle: '한옥스테이 감성 특가',
      heroSubtitle: '전주·안동·경주 전통 숙소를 NOL 혜택으로',
      heroIcon: Icons.temple_buddhist_rounded,
      accentColor: YanoljaColors.mint,
      filters: const ['전체', '전통', '모던', '프리미엄', '한옥스테이', '체험'],
      baseFilter: (accommodation) {
        final text =
            '${accommodation.name} ${accommodation.address} ${accommodation.description}';
        return text.contains('한옥') ||
            text.contains('하회마을') ||
            text.contains('전통문화');
      },
      filterPredicate: (accommodation, filter) {
        switch (filter) {
          case '전통':
            return nolAccommodationContains(
              accommodation,
              ['전통', '한옥', '한식당', '전통차'],
            );
          case '모던':
            return nolAccommodationContains(
              accommodation,
              ['모던', '부티크', '현대적', '세련'],
            );
          case '프리미엄':
            return accommodation.isPopular ||
                accommodation.rating >= 4.7 ||
                accommodation.price >= 180000;
          case '한옥스테이':
            return nolAccommodationContains(accommodation, ['한옥', '스테이']);
          case '체험':
            return nolAccommodationContains(
              accommodation,
              ['체험', '전통문화', '전통차', '자연산책로'],
            );
          default:
            return true;
        }
      },
      emptyIcon: Icons.temple_buddhist_outlined,
      emptyTitle: '조건에 맞는 한옥 숙소가 없어요',
    );
  }
}
