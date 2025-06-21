import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/provider/screen/detail_screen.dart';
import 'package:yanolja_clone/presentation/provider/screen/home_screen.dart';
import 'package:yanolja_clone/presentation/screen/main_shell.dart';
import 'package:yanolja_clone/presentation/screen/placeholder_screen.dart';
import 'package:yanolja_clone/presentation/screen/profile_screen.dart';
import 'package:yanolja_clone/presentation/screen/saved_screen.dart';
import 'package:yanolja_clone/presentation/screen/search_screen.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/home',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          // 홈 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          // 검색 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),
          // 찜 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),
          // 내 정보 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-info',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
          // 더보기 탭
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) =>
                const PlaceholderScreen(title: '더보기'),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/detail/:id', // :id는 변수(숙소 ID)를 의미합니다.
        // MainShell 밖에서 전체 화면으로 표시되도록 parentNavigatorKey를 설정할 수 있지만,
        // 지금은 기본 동작으로 둡니다.
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DetailScreen(accommodationId: id);
        },
      ),
    ],
  );
});
