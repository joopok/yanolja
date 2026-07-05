import 'package:flutter/material.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// 알림 그룹(카테고리). 알림 화면의 필터 칩과 카드 강조색이 이 그룹을 따른다.
enum NotificationGroup {
  benefit('혜택·특가', Icons.local_fire_department_rounded, YanoljaColors.sale),
  booking('예약', Icons.event_available_rounded, YanoljaColors.primary),
  wish('찜·가격', Icons.favorite_rounded, YanoljaColors.primaryPurple),
  ticket('티켓·공연', Icons.confirmation_number_rounded, YanoljaColors.mint),
  activity('포인트·리뷰', Icons.stars_rounded, YanoljaColors.yellow);

  final String label;
  final IconData icon;
  final Color accent;

  const NotificationGroup(this.label, this.icon, this.accent);
}

/// 하루를 4개 시간대로 나눈 구간. 날짜 섹션 안의 타임라인 클러스터에 쓰인다.
enum DayPart {
  dawn('새벽', Icons.bedtime_rounded),
  morning('아침', Icons.wb_twilight_rounded),
  afternoon('오후', Icons.wb_sunny_rounded),
  evening('저녁', Icons.nightlight_round);

  final String label;
  final IconData icon;

  const DayPart(this.label, this.icon);

  static DayPart fromHour(int hour) {
    if (hour < 6) return DayPart.dawn;
    if (hour < 12) return DayPart.morning;
    if (hour < 18) return DayPart.afternoon;
    return DayPart.evening;
  }
}

/// 앱 알림 한 건. (백엔드 없이 mock 으로 동작)
///
/// 홈 상단 알림 벨의 미확인(안 읽은) 카운트는 [isRead] 가 false 인 항목 수로
/// 계산된다. 알림 화면에서 항목을 확인하면 [isRead] 가 true 가 되어 카운트가 준다.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final NotificationGroup group;
  final IconData icon;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    required this.group,
    required this.icon,
    this.isRead = false,
  });

  Color get accent => group.accent;

  DayPart get dayPart => DayPart.fromHour(receivedAt.hour);

  /// 수신 시각의 '오전 9:12' 형태 표기.
  String get clockLabel {
    final hour12 = receivedAt.hour % 12 == 0 ? 12 : receivedAt.hour % 12;
    final meridiem = receivedAt.hour < 12 ? '오전' : '오후';
    final minute = receivedAt.minute.toString().padLeft(2, '0');
    return '$meridiem $hour12:$minute';
  }

  /// 목록 카드에 쓰는 상대/절대 혼합 시간 표기.
  /// 1시간 이내는 '방금 전'·'n분 전', 그 외는 정확한 시각을 보여준다.
  String timeLabel(DateTime now) {
    final diff = now.difference(receivedAt);
    if (diff.inMinutes < 1) return '방금 전';
    if (diff.inMinutes < 60) return '${diff.inMinutes}분 전';
    return clockLabel;
  }

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      receivedAt: receivedAt,
      group: group,
      icon: icon,
      isRead: isRead ?? this.isRead,
    );
  }
}
