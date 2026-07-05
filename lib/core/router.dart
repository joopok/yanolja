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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/provider/accommodation_provider.dart';
import 'package:yanolja_clone/presentation/provider/screen/detail_screen.dart';
import 'package:yanolja_clone/presentation/provider/screen/home_screen.dart';
import 'package:yanolja_clone/presentation/screen/login_screen.dart';
import 'package:yanolja_clone/presentation/screen/main_shell.dart';
import 'package:yanolja_clone/presentation/screen/map_screen.dart';
import 'package:yanolja_clone/presentation/screen/more_screen.dart';
import 'package:yanolja_clone/presentation/screen/nearby_screen.dart';
import 'package:yanolja_clone/presentation/screen/nol_service_screen.dart';
import 'package:yanolja_clone/presentation/screen/notification_screen.dart';
import 'package:yanolja_clone/presentation/screen/profile_screen.dart';
import 'package:yanolja_clone/presentation/screen/saved_screen.dart';
import 'package:yanolja_clone/presentation/screen/search_screen.dart';
import 'package:yanolja_clone/presentation/screen/settings_screen.dart';
import 'package:yanolja_clone/presentation/screen/forgot_password_screen.dart';
import 'package:yanolja_clone/presentation/screen/profile_edit_screen.dart';
import 'package:yanolja_clone/presentation/screen/signup_screen.dart';
import 'package:yanolja_clone/presentation/screen/splash_screen.dart';
import 'package:yanolja_clone/presentation/screen/booking_screen.dart';
import 'package:yanolja_clone/presentation/screen/hanok_screen.dart';
import 'package:yanolja_clone/presentation/screen/hotel_screen.dart';
import 'package:yanolja_clone/presentation/screen/pension_screen.dart';
import 'package:yanolja_clone/presentation/screen/resort_screen.dart';
import 'package:yanolja_clone/presentation/screen/hotel_search_screen.dart';
import 'package:yanolja_clone/presentation/screen/masgib_screen.dart';
import 'package:yanolja_clone/presentation/screen/all_categories_screen.dart';
import 'package:yanolja_clone/presentation/screen/ticket_screen.dart';
import 'package:yanolja_clone/presentation/screen/live_screen.dart';
import 'package:yanolja_clone/presentation/screen/payment_screen.dart';
import 'package:yanolja_clone/presentation/screen/payment_complete_screen.dart';
import 'package:yanolja_clone/presentation/screen/review_detail_screen.dart';
import 'package:yanolja_clone/presentation/screen/review_editor_screen.dart';
import 'package:yanolja_clone/presentation/screen/review_list_screen.dart';
import 'package:yanolja_clone/data/model/booking.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

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
    initialLocation: '/settings', // TEMP-SCREENSHOT: 원복 필요 ('/splash')

    /// 앱의 모든 라우트 정의
    routes: [
      /// 로그인 화면 라우트
      /// 경로: /login
      /// 사용자 인증을 위한 화면입니다.
      GoRoute(
        path: '/splash',
        builder: (context, state) => const SplashScreen(),
      ),

      GoRoute(
        path: '/login',
        builder: (context, state) {
          // 로그아웃 직후 진입 시 extra로 fromLogout 플래그를 전달받습니다.
          final extra = state.extra;
          final fromLogout = extra is Map && extra['fromLogout'] == true;
          return LoginScreen(fromLogout: fromLogout);
        },
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

      /// 결제 확인 화면 라우트
      /// 경로: /payment
      /// 객실 선택 완료 후 예약 정보 확인 및 결제 진행
      GoRoute(
        path: '/payment',
        builder: (context, state) {
          final args = state.extra as PaymentArgs;
          return PaymentScreen(args: args);
        },
      ),

      /// 결제 완료 화면 라우트
      /// 경로: /payment-complete
      GoRoute(
        path: '/payment-complete',
        builder: (context, state) {
          final booking = state.extra as Booking;
          return PaymentCompleteScreen(booking: booking);
        },
      ),
      GoRoute(
        path: '/service/:type',
        builder: (context, state) {
          final type = state.pathParameters['type'] ?? 'deals';
          if (type == 'settings') {
            return const SettingsScreen();
          }
          return NolServiceScreen(type: type);
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (context, state) => const SettingsScreen(),
      ),

      /// 알림 목록 화면 라우트
      /// 경로: /notifications
      /// 안 읽은 알림 개수가 홈 상단 벨 배지에 반영된다.
      GoRoute(
        path: '/notifications',
        builder: (context, state) => const NotificationScreen(),
      ),

      /// 비밀번호 찾기 화면 라우트
      /// 경로: /forgot-password
      /// 가입 이메일로 비밀번호 재설정 링크 발송을 안내합니다.
      GoRoute(
        path: '/forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),

      /// 프로필 수정 화면 라우트
      /// 경로: /profile-edit
      /// 닉네임, 이메일, 휴대폰 번호를 편집합니다.
      GoRoute(
        path: '/profile-edit',
        builder: (context, state) => const ProfileEditScreen(),
      ),
      GoRoute(
        path: '/map',
        builder: (context, state) {
          return Consumer(
            builder: (context, ref, _) {
              final accommodationsAsync = ref.watch(accommodationListProvider);
              return accommodationsAsync.when(
                data: (items) => MapScreen(accommodations: items),
                loading: () => const Scaffold(
                  appBar: YanoljaAppBar.sub(
                    title: '지도',
                    fallbackRoute: '/nearby',
                  ),
                  body: Center(child: CircularProgressIndicator()),
                ),
                error: (error, _) => Scaffold(
                  appBar: const YanoljaAppBar.sub(
                    title: '지도',
                    fallbackRoute: '/nearby',
                  ),
                  body: Center(child: Text('지도를 불러오지 못했어요\n$error')),
                ),
              );
            },
          );
        },
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
      GoRoute(
        path: '/detail/:id/reviews',
        builder: (context, state) {
          return ReviewListScreen(
            accommodationId: state.pathParameters['id']!,
          );
        },
      ),
      GoRoute(
        path: '/detail/:id/reviews/:reviewId',
        builder: (context, state) {
          return ReviewDetailScreen(
            accommodationId: state.pathParameters['id']!,
            reviewId: state.pathParameters['reviewId']!,
          );
        },
      ),
      GoRoute(
        path: '/detail/:id/review-editor',
        builder: (context, state) {
          return ReviewEditorScreen(
            accommodationId: state.pathParameters['id']!,
            reviewId: state.uri.queryParameters['reviewId'],
          );
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

      /// 전체 카테고리 화면
      /// 경로: /all-categories
      /// NOL의 모든 메뉴(티켓·국내여행·해외여행·서비스)를 모아 보여줍니다.
      GoRoute(
        path: '/all-categories',
        builder: (context, state) => const AllCategoriesScreen(),
      ),

      /// NOL 티켓 화면
      /// 경로: /ticket (?genre=뮤지컬 등으로 초기 장르 선택)
      GoRoute(
        path: '/ticket',
        builder: (context, state) {
          final genre = state.uri.queryParameters['genre'];
          return TicketScreen(initialGenre: genre);
        },
      ),

      /// NOL 라이브 화면
      /// 경로: /live
      GoRoute(
        path: '/live',
        builder: (context, state) => const LiveScreen(),
      ),
    ],
  );
});
