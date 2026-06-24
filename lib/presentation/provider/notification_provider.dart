import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/app_notification.dart';

/// 알림 목록 상태. (mock — 백엔드 없음)
///
/// 초기 시드는 "안 읽은" 알림 여러 건을 포함한다. 따라서 앱을 켜면 홈 벨 배지에
/// 실제 미확인 개수가 숫자로 표시되고, 알림 화면에서 확인할 때마다 줄어든다.
class NotificationNotifier extends StateNotifier<List<AppNotification>> {
  NotificationNotifier() : super(_seed);

  static const List<AppNotification> _seed = [
    AppNotification(
      id: 'n1',
      title: 'NOLDAY 특가 오픈',
      body: '오늘만 국내 인기 숙소 최대 40% 쿠폰이 열렸어요.',
      time: '방금 전',
      icon: Icons.local_fire_department_rounded,
      accent: YanoljaColors.sale,
    ),
    AppNotification(
      id: 'n2',
      title: '예약 확정 안내',
      body: '제주 신라스테이 6/28 체크인 예약이 확정되었습니다.',
      time: '12분 전',
      icon: Icons.check_circle_rounded,
      accent: YanoljaColors.primary,
    ),
    AppNotification(
      id: 'n3',
      title: '찜한 숙소 가격 인하',
      body: '부산 오션뷰 호텔이 18,000원 더 저렴해졌어요.',
      time: '1시간 전',
      icon: Icons.favorite_rounded,
      accent: YanoljaColors.primaryPurple,
    ),
    AppNotification(
      id: 'n4',
      title: '공연 티켓 예매 오픈',
      body: '관심 등록한 뮤지컬의 예매가 곧 시작됩니다.',
      time: '3시간 전',
      icon: Icons.confirmation_number_rounded,
      accent: YanoljaColors.mint,
    ),
    AppNotification(
      id: 'n5',
      title: '리뷰 작성 요청',
      body: '지난 숙소는 어떠셨나요? 리뷰를 남기고 포인트를 받으세요.',
      time: '어제',
      icon: Icons.rate_review_rounded,
      accent: YanoljaColors.primary,
      isRead: true,
    ),
  ];

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
