import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/data/model/app_notification.dart';

/// 알림 목록 상태. (mock — 백엔드 없음)
///
/// 초기 시드는 "안 읽은" 알림 여러 건을 포함한다. 따라서 앱을 켜면 홈 벨 배지에
/// 실제 미확인 개수가 숫자로 표시되고, 알림 화면에서 확인할 때마다 줄어든다.
/// 수신 시각은 앱 실행 시점을 기준으로 최근/어제/이전 날짜에 분산 생성된다.
/// 최근 4건은 now 기준 상대 오프셋이므로 자정 직후 실행 시 일부가 어제 날짜가
/// 될 수 있으며, 이 경우 날짜 기준 그룹핑에 따라 '어제' 섹션에 표시된다(정상).
class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super(_buildSeed(DateTime.now()));

  static List<AppNotification> _buildSeed(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    DateTime daysAgo(int days, int hour, int minute) =>
        today.subtract(Duration(days: days)).add(
              Duration(hours: hour, minutes: minute),
            );

    return [
      // ── 최근 (now 기준 상대 오프셋 — 자정 직후 실행이면 일부는 어제로 분류될 수 있음)
      AppNotification(
        id: 'n1',
        title: 'NOLDAY 특가 오픈',
        body: '오늘만 국내 인기 숙소 최대 40% 쿠폰이 열렸어요.',
        receivedAt: now.subtract(const Duration(minutes: 8)),
        group: NotificationGroup.benefit,
        icon: Icons.local_fire_department_rounded,
      ),
      AppNotification(
        id: 'n2',
        title: '예약 확정 안내',
        body: '제주 신라스테이 6/28 체크인 예약이 확정되었습니다.',
        receivedAt: now.subtract(const Duration(minutes: 42)),
        group: NotificationGroup.booking,
        icon: Icons.check_circle_rounded,
      ),
      AppNotification(
        id: 'n3',
        title: '찜한 숙소 가격 인하',
        body: '부산 오션뷰 호텔이 18,000원 더 저렴해졌어요.',
        receivedAt: now.subtract(const Duration(hours: 2, minutes: 15)),
        group: NotificationGroup.wish,
        icon: Icons.trending_down_rounded,
      ),
      AppNotification(
        id: 'n4',
        title: '공연 티켓 예매 오픈',
        body: '관심 등록한 뮤지컬 <라이온킹>의 예매가 곧 시작됩니다.',
        receivedAt: now.subtract(const Duration(hours: 5, minutes: 40)),
        group: NotificationGroup.ticket,
        icon: Icons.confirmation_number_rounded,
      ),
      // ── 어제 (시간대가 갈리도록 절대 시각 지정)
      AppNotification(
        id: 'n5',
        title: '주말 캠핑 얼리버드',
        body: '가평 글램핑 초여름 얼리버드가 시작됐어요. 최대 35% 할인!',
        receivedAt: daysAgo(1, 20, 24),
        group: NotificationGroup.benefit,
        icon: Icons.forest_rounded,
      ),
      AppNotification(
        id: 'n6',
        title: '체크인 D-1 리마인드',
        body: '내일은 여수 베네치아 호텔 체크인 날이에요. 준비되셨나요?',
        receivedAt: daysAgo(1, 14, 5),
        group: NotificationGroup.booking,
        icon: Icons.luggage_rounded,
      ),
      AppNotification(
        id: 'n7',
        title: '찜한 펜션 마감 임박',
        body: '남해 스테이 온 펜션, 이번 주말 객실이 2개 남았어요.',
        receivedAt: daysAgo(1, 9, 12),
        group: NotificationGroup.wish,
        icon: Icons.hourglass_bottom_rounded,
        isRead: true,
      ),
      AppNotification(
        id: 'n8',
        title: '포인트 적립 완료',
        body: '지난 예약 리워드 3,200P가 적립되었습니다.',
        receivedAt: daysAgo(1, 0, 47),
        group: NotificationGroup.activity,
        icon: Icons.savings_rounded,
        isRead: true,
      ),
      // ── 이번 주 이전 날짜들
      AppNotification(
        id: 'n9',
        title: '리뷰 작성 요청',
        body: '지난 숙소는 어떠셨나요? 리뷰를 남기고 포인트를 받으세요.',
        receivedAt: daysAgo(2, 18, 30),
        group: NotificationGroup.activity,
        icon: Icons.rate_review_rounded,
        isRead: true,
      ),
      AppNotification(
        id: 'n10',
        title: '콘서트 좌석 오픈',
        body: '기다리던 내한 공연의 추가 좌석이 열렸어요.',
        receivedAt: daysAgo(2, 11, 3),
        group: NotificationGroup.ticket,
        icon: Icons.music_note_rounded,
        isRead: true,
      ),
      AppNotification(
        id: 'n11',
        title: '6월 결제 혜택 안내',
        body: '토스페이 결제 시 5% 즉시 할인 쿠폰이 도착했어요.',
        receivedAt: daysAgo(4, 15, 48),
        group: NotificationGroup.benefit,
        icon: Icons.card_giftcard_rounded,
        isRead: true,
      ),
      AppNotification(
        id: 'n12',
        title: '예약 취소 환불 완료',
        body: '강릉 씨마크 호텔 예약 환불이 정상 처리되었습니다.',
        receivedAt: daysAgo(4, 10, 21),
        group: NotificationGroup.booking,
        icon: Icons.currency_exchange_rounded,
        isRead: true,
      ),
      AppNotification(
        id: 'n13',
        title: '등급 승급 안내',
        body: '축하해요! NOL 멤버십이 GOLD로 승급되었습니다.',
        receivedAt: daysAgo(6, 19, 55),
        group: NotificationGroup.activity,
        icon: Icons.workspace_premium_rounded,
        isRead: true,
      ),
    ];
  }

  /// 알림 한 건을 읽음 처리한다.
  void markAsRead(String id) {
    state = [
      for (final n in state)
        if (n.id == id && !n.isRead) n.copyWith(isRead: true) else n,
    ];
  }

  /// 모든 알림을 읽음 처리한다.
  void markAllAsRead() {
    state = [
      for (final n in state)
        if (n.isRead) n else n.copyWith(isRead: true),
    ];
  }
}

final notificationProvider =
    StateNotifierProvider<NotificationNotifier, List<AppNotification>>(
  (ref) => NotificationNotifier(),
);

/// 안 읽은(미확인) 알림 개수 — 홈 벨 배지에 사용.
final unreadNotificationCountProvider = Provider<int>((ref) {
  final list = ref.watch(notificationProvider);
  return list.where((n) => !n.isRead).length;
});

/// 알림 화면에서 선택된 그룹 필터. null 이면 전체 보기.
///
/// autoDispose — 화면을 벗어나면 필터가 초기화되어, 벨 배지를 보고 재진입했을 때
/// 이전 필터 때문에 새 알림이 안 보이는 배지↔화면 불일치를 막는다.
final selectedNotificationGroupProvider =
    StateProvider.autoDispose<NotificationGroup?>((ref) => null);

/// 그룹별 미확인 개수 — 필터 칩의 배지에 사용.
final unreadCountByGroupProvider = Provider<Map<NotificationGroup, int>>((ref) {
  final list = ref.watch(notificationProvider);
  final counts = <NotificationGroup, int>{};
  for (final n in list) {
    if (!n.isRead) counts[n.group] = (counts[n.group] ?? 0) + 1;
  }
  return counts;
});
