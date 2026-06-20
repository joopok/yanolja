import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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

    expect(find.text('콘서트 예매도 NOL'), findsOneWidget);
    expect(find.byIcon(Icons.search_rounded), findsOneWidget);

    controller.dispose();
    focusNode.dispose();
  });
}
