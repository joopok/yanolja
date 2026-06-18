/// 앱의 라우팅을 관리하는 파일
/// GoRouter를 사용하여 화면 전환을 처리하고,
/// StatefulShellRoute를 통해 하단 탭 네비게이션의 상태를 유지합니다.
///
/// 주요 기능:
/// - 로그인/회원가입 라우트
/// - 하단 탭 네비게이션 (홈, 검색, 찜, 내정보, 예약내역, 더보기)
/// - 숙소 상세 화면
/// - 카테고리별 숙소 화면 (호텔, 펜션, 리조트, 한옥)
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/provider/screen/detail_screen.dart';
import 'package:yanolja_clone/presentation/provider/screen/home_screen.dart';
import 'package:yanolja_clone/presentation/screen/login_screen.dart';
import 'package:yanolja_clone/presentation/screen/main_shell.dart';
import 'package:yanolja_clone/presentation/screen/more_screen.dart';
import 'package:yanolja_clone/presentation/screen/nearby_screen.dart';
import 'package:yanolja_clone/presentation/screen/profile_screen.dart';
import 'package:yanolja_clone/presentation/screen/saved_screen.dart';
import 'package:yanolja_clone/presentation/screen/search_screen.dart';
import 'package:yanolja_clone/presentation/screen/signup_screen.dart';
import 'package:yanolja_clone/presentation/screen/booking_screen.dart';
import 'package:yanolja_clone/presentation/screen/hanok_screen.dart';
import 'package:yanolja_clone/presentation/screen/hotel_screen.dart';
import 'package:yanolja_clone/presentation/screen/pension_screen.dart';
import 'package:yanolja_clone/presentation/screen/resort_screen.dart';
import 'package:yanolja_clone/presentation/screen/hotel_search_screen.dart';
import 'package:yanolja_clone/presentation/screen/masgib_screen.dart';

/// GoRouter 인스턴스를 제공하는 Provider
///
/// 앱 전체에서 사용되는 라우팅 설정을 관리합니다.
/// ref를 통해 다른 Provider에 접근할 수 있습니다.
///
/// @return GoRouter 라우터 인스턴스
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    /// 앱 시작 시 표시될 초기 경로
    /// 홈 화면이 기본 화면으로 설정되어 있습니다.
    initialLocation: '/home',

    /// 앱의 모든 라우트 정의
    routes: [
      /// 로그인 화면 라우트
      /// 경로: /login
      /// 사용자 인증을 위한 화면입니다.
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),

      /// 회원가입 화면 라우트
      /// 경로: /signup
      /// 새로운 사용자 등록을 위한 화면입니다.
      GoRoute(
        path: '/signup',
        builder: (context, state) => const SignUpScreen(),
      ),

      /// StatefulShellRoute를 사용한 하단 탭 네비게이션
      ///
      /// indexedStack을 사용하여 각 탭의 상태를 유지합니다.
      /// 탭을 전환해도 이전 탭의 스크롤 위치나 데이터가 보존됩니다.
      ///
      /// @param context BuildContext
      /// @param state GoRouterState 현재 라우트 상태
      /// @param navigationShell StatefulNavigationShell 네비게이션 컨트롤러
      /// @return MainShell 하단 탭이 있는 메인 화면
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        branches: [
          /// 홈 탭 (인덱스: 0)
          /// 앱의 메인 화면으로 인기 숙소, 신규 숙소 등을 표시합니다.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          /// 검색 탭 (인덱스: 1)
          /// 숙소 검색 기능을 제공하는 화면입니다.
          /// 검색어 입력, 검색 기록, 최근 검색 등의 기능을 포함합니다.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/search',
                builder: (context, state) => const SearchScreen(),
              ),
            ],
          ),

          /// 내 주변 탭 (인덱스: 2)
          /// 현재 위치 기준 근처 숙소를 표시합니다.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/nearby',
                builder: (context, state) => const NearbyScreen(),
              ),
            ],
          ),

          /// 찜 탭 (인덱스: 3)
          /// 사용자가 저장한 숙소 목록을 표시하는 화면입니다.
          /// 나중에 예약하고 싶은 숙소를 모아볼 수 있습니다.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/saved',
                builder: (context, state) => const SavedScreen(),
              ),
            ],
          ),

          /// 내 정보 탭 (인덱스: 4)
          /// 사용자 프로필 정보를 표시하고 관리하는 화면입니다.
          /// 로그인 상태, 개인정보 수정 등의 기능을 제공합니다.
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/my-info',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/bookings',
        builder: (context, state) => const BookingScreen(),
      ),
      GoRoute(
        path: '/more',
        builder: (context, state) => const MoreScreen(),
      ),

      /// 숙소 상세 화면 라우트
      ///
      /// 동적 경로 파라미터를 사용하여 특정 숙소의 상세 정보를 표시합니다.
      /// 경로: /detail/{숙소ID}
      ///
      /// @param id 숙소 고유 ID (pathParameter로 전달)
      /// @return DetailScreen 해당 숙소의 상세 정보 화면
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return DetailScreen(accommodationId: id);
        },
      ),

      /// 호텔 카테고리 화면 라우트
      /// 경로: /hotel
      /// 호텔 타입의 숙소 목록을 표시하는 전용 화면입니다.
      GoRoute(
        path: '/hotel',
        builder: (context, state) => const HotelScreen(),
      ),

      /// 펜션 카테고리 화면 라우트
      /// 경로: /pension
      /// 펜션 타입의 숙소 목록을 표시하며, 계절별 테마를 제공합니다.
      GoRoute(
        path: '/pension',
        builder: (context, state) => const PensionScreen(),
      ),

      /// 리조트 카테고리 화면 라우트
      /// 경로: /resort
      /// 리조트 타입의 숙소 목록을 표시하며, 고급 편의시설 필터를 제공합니다.
      GoRoute(
        path: '/resort',
        builder: (context, state) => const ResortScreen(),
      ),

      /// 한옥 카테고리 화면 라우트
      /// 경로: /hanok
      /// 전통 한옥 숙소 목록을 표시하는 전용 화면입니다.
      GoRoute(
        path: '/hanok',
        builder: (context, state) => const HanokScreen(),
      ),

      /// 호텔 검색 화면 라우트
      /// 경로: /hotelSearch
      /// 호텔 전용 상세 검색 기능을 제공하는 화면입니다.
      GoRoute(
        path: '/hotelSearch',
        builder: (context, state) => const HotelSearchScreen(),
      ),

      /// 맛집 화면 라우트
      /// 경로: /masgib
      /// T membership 스타일의 맛집 추천 화면입니다.
      GoRoute(
        path: '/masgib',
        builder: (context, state) => const MasgibScreen(),
      ),
    ],
  );
});
