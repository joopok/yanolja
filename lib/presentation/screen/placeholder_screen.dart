import 'package:flutter/material.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

class PlaceholderScreen extends StatelessWidget {
  final String title;
  const PlaceholderScreen({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: YanoljaAppBar.sub(
        title: title,
      ),
      body: Center(
        child: Text(
          '$title 화면',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
