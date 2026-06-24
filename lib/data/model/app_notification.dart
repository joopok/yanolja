import 'package:flutter/material.dart';

/// 앱 알림 한 건. (백엔드 없이 mock 으로 동작)
///
/// 홈 상단 알림 벨의 미확인(안 읽은) 카운트는 [isRead] 가 false 인 항목 수로
/// 계산된다. 알림 화면에서 항목을 확인하면 [isRead] 가 true 가 되어 카운트가 준다.
class AppNotification {
  final String id;
  final String title;
  final String body;
  final String time; // 표시용 상대 시간 텍스트 (예: '방금 전', '1시간 전')
  final IconData icon;
  final Color accent;
  final bool isRead;

  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.icon,
    required this.accent,
    this.isRead = false,
  });

  AppNotification copyWith({bool? isRead}) {
    return AppNotification(
      id: id,
      title: title,
      body: body,
      time: time,
      icon: icon,
      accent: accent,
      isRead: isRead ?? this.isRead,
    );
  }
}
