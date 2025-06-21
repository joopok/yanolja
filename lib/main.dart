import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/router.dart';

void main() {
  runApp(
    // Riverpod를 사용하기 위해 ProviderScope로 감싸줍니다.
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // go_router를 앱에 적용합니다.
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: '여기어때',
      theme: ThemeData(
        primarySwatch: Colors.pink,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'NotoSansKR',
      ),
      debugShowCheckedModeBanner: false,
      routerConfig: router,
    );
  }
}