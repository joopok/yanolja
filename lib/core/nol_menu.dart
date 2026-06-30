/// 🧭 NOL 전체 메뉴 정의
///
/// 실제 NOL(nol.yanolja.com) "전체 카테고리" 메뉴 트리를 그대로 옮긴 데이터입니다.
/// 전체 카테고리 화면(AllCategoriesScreen)과 진입점들이 이 정의를 참조합니다.
library;

import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// 단일 메뉴 항목
class NolMenuItem {
  final String label;
  final String asset;
  final IconData icon;
  final Color color;

  /// 이동 라우트 (GoRouter 경로)
  final String route;

  const NolMenuItem({
    required this.label,
    required this.asset,
    required this.icon,
    required this.color,
    required this.route,
  });
}

/// image 2.0으로 생성한 전체메뉴 전용 PNG 아이콘 자산.
class NolMenuIcons {
  NolMenuIcons._();

  static const String quickHotelResort =
      'assets/menu_icons/quick_hotel_resort.png';
  static const String quickPensionPoolvilla =
      'assets/menu_icons/quick_pension_poolvilla.png';
  static const String quickMotel = 'assets/menu_icons/quick_motel.png';
  static const String quickDomesticLeisure =
      'assets/menu_icons/quick_domestic_leisure.png';
  static const String quickTransport = 'assets/menu_icons/quick_transport.png';
  static const String quickNolTicket = 'assets/menu_icons/quick_nol_ticket.png';

  static const String ticketMusical = 'assets/menu_icons/ticket_musical.png';
  static const String ticketConcert = 'assets/menu_icons/ticket_concert.png';
  static const String ticketSports = 'assets/menu_icons/ticket_sports.png';
  static const String ticketExhibition =
      'assets/menu_icons/ticket_exhibition.png';
  static const String ticketClassicDance =
      'assets/menu_icons/ticket_classic_dance.png';
  static const String ticketKidsFamily =
      'assets/menu_icons/ticket_kids_family.png';
  static const String ticketTheater = 'assets/menu_icons/ticket_theater.png';

  static const String domesticHotelResort =
      'assets/menu_icons/domestic_hotel_resort.png';
  static const String domesticPensionPoolvilla =
      'assets/menu_icons/domestic_pension_poolvilla.png';
  static const String domesticMotel = 'assets/menu_icons/domestic_motel.png';
  static const String domesticGuesthouse =
      'assets/menu_icons/domestic_guesthouse.png';
  static const String domesticCamping =
      'assets/menu_icons/domestic_camping.png';
  static const String domesticHanok = 'assets/menu_icons/domestic_hanok.png';
  static const String domesticTransport =
      'assets/menu_icons/domestic_transport.png';
  static const String domesticLeisure =
      'assets/menu_icons/domestic_leisure.png';
  static const String domesticFlight = 'assets/menu_icons/domestic_flight.png';

  static const String overseasFlight = 'assets/menu_icons/overseas_flight.png';
  static const String overseasHotel = 'assets/menu_icons/overseas_hotel.png';
  static const String overseasTourTicket =
      'assets/menu_icons/overseas_tour_ticket.png';
  static const String overseasPackage =
      'assets/menu_icons/overseas_package.png';

  static const String serviceLive = 'assets/menu_icons/service_live.png';
  static const String serviceDeals = 'assets/menu_icons/service_deals.png';
  static const String serviceCouponBenefit =
      'assets/menu_icons/service_coupon_benefit.png';
  static const String serviceEvent = 'assets/menu_icons/service_event.png';
}

/// 메뉴 그룹 (NOL티켓 / 국내여행 / 해외여행 / 서비스)
class NolMenuGroup {
  final String title;
  final String subtitle;
  final List<NolMenuItem> items;

  const NolMenuGroup({
    required this.title,
    required this.subtitle,
    required this.items,
  });
}

/// NOL 전체 메뉴 트리
const List<NolMenuGroup> nolMenuGroups = [
  NolMenuGroup(
    title: 'NOL 티켓',
    subtitle: '공연·전시·스포츠 예매',
    items: [
      NolMenuItem(
          label: '뮤지컬',
          asset: NolMenuIcons.ticketMusical,
          icon: Icons.theater_comedy_rounded,
          color: Color(0xFFFF6D3D),
          route: '/ticket?genre=뮤지컬'),
      NolMenuItem(
          label: '콘서트',
          asset: NolMenuIcons.ticketConcert,
          icon: Icons.music_note_rounded,
          color: Color(0xFFFF4FB7),
          route: '/ticket?genre=콘서트'),
      NolMenuItem(
          label: '스포츠',
          asset: NolMenuIcons.ticketSports,
          icon: Icons.sports_basketball_rounded,
          color: Color(0xFF2F6BFF),
          route: '/ticket?genre=스포츠'),
      NolMenuItem(
          label: '전시/행사',
          asset: NolMenuIcons.ticketExhibition,
          icon: Icons.auto_awesome_rounded,
          color: Color(0xFF9B51E0),
          route: '/ticket?genre=전시/행사'),
      NolMenuItem(
          label: '클래식/무용',
          asset: NolMenuIcons.ticketClassicDance,
          icon: Icons.piano_rounded,
          color: YanoljaColors.accentBlue,
          route: '/ticket?genre=클래식/무용'),
      NolMenuItem(
          label: '아동/가족',
          asset: NolMenuIcons.ticketKidsFamily,
          icon: Icons.family_restroom_rounded,
          color: Color(0xFF00B894),
          route: '/ticket?genre=아동/가족'),
      NolMenuItem(
          label: '연극',
          asset: NolMenuIcons.ticketTheater,
          icon: Icons.masks_rounded,
          color: Color(0xFFFF8A3D),
          route: '/ticket?genre=연극'),
    ],
  ),
  NolMenuGroup(
    title: '국내여행',
    subtitle: '숙소·교통·레저를 한 번에',
    items: [
      NolMenuItem(
          label: '호텔/리조트',
          asset: NolMenuIcons.domesticHotelResort,
          icon: Icons.hotel_rounded,
          color: YanoljaColors.primary,
          route: '/hotel'),
      NolMenuItem(
          label: '펜션/풀빌라',
          asset: NolMenuIcons.domesticPensionPoolvilla,
          icon: Icons.cottage_rounded,
          color: Color(0xFF00B894),
          route: '/pension'),
      NolMenuItem(
          label: '모텔',
          asset: NolMenuIcons.domesticMotel,
          icon: Icons.bed_rounded,
          color: YanoljaColors.primaryPurple,
          route: '/service/motel'),
      NolMenuItem(
          label: '게스트하우스',
          asset: NolMenuIcons.domesticGuesthouse,
          icon: Icons.holiday_village_rounded,
          color: Color(0xFFFF8A3D),
          route: '/service/guesthouse'),
      NolMenuItem(
          label: '글램핑/캠핑',
          asset: NolMenuIcons.domesticCamping,
          icon: Icons.park_rounded,
          color: YanoljaColors.success,
          route: '/service/camping'),
      NolMenuItem(
          label: '한옥',
          asset: NolMenuIcons.domesticHanok,
          icon: Icons.temple_buddhist_rounded,
          color: Color(0xFFC0894B),
          route: '/hanok'),
      NolMenuItem(
          label: '국내교통',
          asset: NolMenuIcons.domesticTransport,
          icon: Icons.directions_bus_rounded,
          color: Color(0xFFFF4D5C),
          route: '/service/transport'),
      NolMenuItem(
          label: '국내레저',
          asset: NolMenuIcons.domesticLeisure,
          icon: Icons.attractions_rounded,
          color: Color(0xFFFF4FB7),
          route: '/service/leisure'),
      NolMenuItem(
          label: '국내항공',
          asset: NolMenuIcons.domesticFlight,
          icon: Icons.flight_takeoff_rounded,
          color: Color(0xFF2F6BFF),
          route: '/service/flight'),
    ],
  ),
  NolMenuGroup(
    title: '해외여행',
    subtitle: '항공·숙소·투어·패키지',
    items: [
      NolMenuItem(
          label: '해외항공',
          asset: NolMenuIcons.overseasFlight,
          icon: Icons.flight_rounded,
          color: YanoljaColors.primary,
          route: '/service/flight'),
      NolMenuItem(
          label: '해외숙소',
          asset: NolMenuIcons.overseasHotel,
          icon: Icons.apartment_rounded,
          color: Color(0xFF4C6FFF),
          route: '/service/overseas'),
      NolMenuItem(
          label: '해외투어/티켓',
          asset: NolMenuIcons.overseasTourTicket,
          icon: Icons.tour_rounded,
          color: YanoljaColors.mint,
          route: '/service/overseas-tour'),
      NolMenuItem(
          label: '해외패키지',
          asset: NolMenuIcons.overseasPackage,
          icon: Icons.card_travel_rounded,
          color: Color(0xFF9B51E0),
          route: '/service/package'),
    ],
  ),
  NolMenuGroup(
    title: '서비스',
    subtitle: 'NOL의 특별한 혜택',
    items: [
      NolMenuItem(
          label: 'NOL 라이브',
          asset: NolMenuIcons.serviceLive,
          icon: Icons.live_tv_rounded,
          color: YanoljaColors.sale,
          route: '/live'),
      NolMenuItem(
          label: 'NOL 특가',
          asset: NolMenuIcons.serviceDeals,
          icon: Icons.bolt_rounded,
          color: YanoljaColors.yellow,
          route: '/service/deals'),
      NolMenuItem(
          label: '쿠폰/혜택',
          asset: NolMenuIcons.serviceCouponBenefit,
          icon: Icons.confirmation_number_rounded,
          color: YanoljaColors.primary,
          route: '/service/coupons'),
      NolMenuItem(
          label: '기획전',
          asset: NolMenuIcons.serviceEvent,
          icon: Icons.campaign_rounded,
          color: Color(0xFFFF6D3D),
          route: '/service/event'),
    ],
  ),
];

/// 홈 상단 퀵 카테고리 (자주 쓰는 핵심 메뉴 모음)
const List<NolMenuItem> nolQuickMenu = [
  NolMenuItem(
      label: '호텔/리조트',
      asset: NolMenuIcons.quickHotelResort,
      icon: Icons.hotel_rounded,
      color: YanoljaColors.primary,
      route: '/hotel'),
  NolMenuItem(
      label: '펜션/풀빌라',
      asset: NolMenuIcons.quickPensionPoolvilla,
      icon: Icons.cottage_rounded,
      color: Color(0xFF00B894),
      route: '/pension'),
  NolMenuItem(
      label: '모텔',
      asset: NolMenuIcons.quickMotel,
      icon: Icons.bed_rounded,
      color: YanoljaColors.primaryPurple,
      route: '/service/motel'),
  NolMenuItem(
      label: '국내레저',
      asset: NolMenuIcons.quickDomesticLeisure,
      icon: Icons.attractions_rounded,
      color: Color(0xFFFF4FB7),
      route: '/service/leisure'),
  NolMenuItem(
      label: '교통',
      asset: NolMenuIcons.quickTransport,
      icon: Icons.directions_bus_rounded,
      color: Color(0xFFFF4D5C),
      route: '/service/transport'),
  NolMenuItem(
      label: 'NOL 티켓',
      asset: NolMenuIcons.quickNolTicket,
      icon: Icons.confirmation_number_rounded,
      color: Color(0xFFFF6D3D),
      route: '/ticket'),
  NolMenuItem(
      label: '항공',
      asset: NolMenuIcons.domesticFlight,
      icon: Icons.flight_takeoff_rounded,
      color: Color(0xFF2F6BFF),
      route: '/service/flight'),
  NolMenuItem(
      label: '해외숙소',
      asset: NolMenuIcons.overseasHotel,
      icon: Icons.apartment_rounded,
      color: Color(0xFF4C6FFF),
      route: '/service/overseas'),
  NolMenuItem(
      label: '해외투어',
      asset: NolMenuIcons.overseasTourTicket,
      icon: Icons.tour_rounded,
      color: YanoljaColors.mint,
      route: '/service/overseas-tour'),
  NolMenuItem(
      label: '전체보기',
      asset: NolMenuIcons.serviceEvent,
      icon: Icons.grid_view_rounded,
      color: YanoljaColors.textSecondary,
      route: '/all-categories'),
];
