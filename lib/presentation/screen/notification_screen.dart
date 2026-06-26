import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/app_notification.dart';
import 'package:yanolja_clone/presentation/provider/notification_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// 알림 목록 화면
///
/// 안 읽은 알림은 강조 표시되며, 항목을 탭하거나 "모두 읽음"을 누르면 읽음 처리되어
/// 홈 상단 벨 배지의 미확인 카운트가 즉시 줄어든다.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final unread = ref.watch(unreadNotificationCountProvider);

    return Scaffold(
      backgroundColor: YanoljaColors.background,
      appBar: YanoljaAppBar.sub(
        title: '알림',
        subtitle: unread > 0 ? '안 읽은 알림 $unread개' : '모두 확인했어요',
        fallbackRoute: '/home',
        actions: [
          if (unread > 0)
            TextButton(
              onPressed: () {
                HapticFeedback.selectionClick();
                ref.read(notificationProvider.notifier).markAllAsRead();
              },
              child: const Text(
                '모두 읽음',
                style: TextStyle(
                  color: YanoljaColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
        ],
      ),
      body: notifications.isEmpty
          ? _buildEmpty()
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final item = notifications[index];
                return YanoljaEntrance(
                  delay: YanoljaMotion.stagger(index, start: 40, step: 40),
                  child: _NotificationTile(
                    item: item,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref
                          .read(notificationProvider.notifier)
                          .markAsRead(item.id);
                    },
                  ),
                );
              },
            ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: YanoljaEntrance(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: const BoxDecoration(
                color: YanoljaColors.primaryLight,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_off_outlined,
                size: 36,
                color: YanoljaColors.primary,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '받은 알림이 없어요',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '특가·예약 소식이 도착하면 알려드릴게요',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: YanoljaColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;

  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

    return YanoljaPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: unread ? YanoljaColors.primaryLight : YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(
            color: unread
                ? YanoljaColors.primary.withValues(alpha: 0.18)
                : YanoljaColors.border,
          ),
          boxShadow: unread
              ? null
              : [
                  BoxShadow(
                    color: YanoljaColors.shadow.withValues(alpha: 0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: item.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(item.icon, color: item.accent, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                unread ? FontWeight.w900 : FontWeight.w700,
                            color: YanoljaColors.textPrimary,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      if (unread)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(left: 6, top: 4),
                          decoration: const BoxDecoration(
                            color: YanoljaColors.sale,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.body,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: YanoljaColors.textSecondary,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    item.time,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: YanoljaColors.textTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
