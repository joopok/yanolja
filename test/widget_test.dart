import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yanolja_clone/presentation/provider/screen/detail_screen.dart';
import 'package:yanolja_clone/presentation/widget/animated_search_field.dart';

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

    await tester.ensureVisible(find.text('${tomorrow.day}').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('${tomorrow.day}').first);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('${dayAfterTomorrow.day}').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('${dayAfterTomorrow.day}').first);
    await tester.pumpAndSettle();

    await tester.tap(find.text('1박 선택 완료'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(ElevatedButton, '결제하기'), findsWidgets);
  });
}
