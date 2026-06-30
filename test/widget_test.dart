import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/provider/screen/detail_screen.dart';
import 'package:yanolja_clone/presentation/screen/splash_screen.dart';
import 'package:yanolja_clone/presentation/widget/animated_search_field.dart';
import 'package:yanolja_clone/presentation/widget/fullscreen_image_gallery.dart';
import 'package:yanolja_clone/presentation/widget/social_share_sheet.dart';

void main() {
  testWidgets('renders NOL search field', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnimatedSearchField(
            controller: controller,
            focusNode: focusNode,
            onChanged: (_) {},
            onSubmitted: (_) {},
          ),
        ),
      ),
    );

    expect(find.text('지역, 숙소, 공연 검색'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    controller.dispose();
    focusNode.dispose();
  });

  testWidgets('renders redesigned launch splash', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    await tester.pump(const Duration(milliseconds: 640));

    expect(find.text('여행을 켜다'), findsOneWidget);
    expect(find.text('NOL'), findsOneWidget);
    expect(find.text('야놀자'), findsOneWidget);
    expect(find.text('놀 준비를 마치는 중'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows payment CTA after selecting stay dates', (tester) async {
    await tester.binding.setSurfaceSize(const Size(390, 1200));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: DetailScreen(accommodationId: '1'),
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 700));

    expect(find.widgetWithText(ElevatedButton, '날짜 선택'), findsWidgets);

    await tester.tap(find.widgetWithText(ElevatedButton, '날짜 선택').last);
    await tester.pumpAndSettle();

    final tomorrow = DateTime.now().add(const Duration(days: 1));
    final dayAfterTomorrow = DateTime.now().add(const Duration(days: 2));

    final checkInKey = ValueKey(
        'stay-date-${tomorrow.year}-${tomorrow.month}-${tomorrow.day}');
    final checkOutKey = ValueKey(
      'stay-date-${dayAfterTomorrow.year}-${dayAfterTomorrow.month}-${dayAfterTomorrow.day}',
    );

    Future<void> scrollUntilDateVisible(ValueKey<String> key) async {
      final calendar = find.byType(ListView).last;
      for (var i = 0; i < 12; i++) {
        if (find.byKey(key).evaluate().isNotEmpty) {
          await tester.ensureVisible(find.byKey(key));
          await tester.pumpAndSettle();
          return;
        }
        await tester.drag(calendar, const Offset(0, -420));
        await tester.pumpAndSettle();
      }
      fail('Could not find date cell $key');
    }

    await scrollUntilDateVisible(checkInKey);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(checkInKey));
    await tester.pumpAndSettle();
    await scrollUntilDateVisible(checkOutKey);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(checkOutKey));
    await tester.pumpAndSettle();

    await tester.tap(find.text('1박 선택 완료'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, '결제하기'), findsWidgets);
  });

  testWidgets('shows social share channels for accommodation', (tester) async {
    final accommodation = Accommodation(
      id: 'share-hotel-1',
      name: '공유 테스트 호텔',
      address: '서울 강남구',
      price: 128000,
      rating: 4.8,
      imageUrls: const ['https://example.com/hotel.jpg'],
      description: '공유 테스트용 숙소입니다.',
      category: '호텔',
      amenities: const ['와이파이'],
      isNew: false,
      isPopular: true,
      reviewCount: 24,
      distanceFromCenter: 1.2,
      hasWifi: true,
      hasParking: true,
      hasBreakfast: false,
      checkInTime: '15:00',
      checkOutTime: '11:00',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () => showYanoljaSocialShareSheet(
                    context: context,
                    data: YanoljaShareData.accommodation(accommodation),
                  ),
                  child: const Text('공유 열기'),
                ),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('공유 열기'));
    await tester.pumpAndSettle();

    expect(find.text('카카오톡'), findsOneWidget);
    expect(find.text('네이버'), findsOneWidget);
    expect(find.text('페이스북'), findsOneWidget);
    expect(find.text('인스타그램'), findsOneWidget);
    expect(find.text('X'), findsOneWidget);
    expect(find.text('링크 복사'), findsOneWidget);
    expect(find.byType(FaIcon), findsWidgets);
    expect(find.byIcon(Icons.open_in_full_rounded), findsOneWidget);
    expect(find.text('미리보기'), findsOneWidget);

    await tester.tap(find.text('미리보기'));
    await tester.pumpAndSettle();
    expect(find.text('공유 문구 미리보기'), findsOneWidget);

    await tester.tap(find.widgetWithText(FilledButton, '문구 복사'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('공유 문구를 복사했어요'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.open_in_full_rounded));
    await tester.pumpAndSettle();
    expect(find.text('공유 미리보기'), findsOneWidget);
    expect(find.text('전체 화면에서 공유'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('링크 복사'),
      220,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.tap(find.text('링크 복사').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('공유 링크를 복사했어요'), findsOneWidget);
  });

  testWidgets('photo gallery clamps invalid initial index', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: FullscreenImageGallery(
          imageUrls: [
            'https://example.com/photo-1.jpg',
            'https://example.com/photo-2.jpg',
          ],
          initialIndex: 99,
        ),
      ),
    );

    await tester.pump(const Duration(milliseconds: 350));

    expect(find.text('사진 전체보기'), findsOneWidget);
    expect(find.text('2 / 2'), findsOneWidget);
    expect(find.text('전체 사진'), findsOneWidget);
  });
}
