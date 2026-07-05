import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/app_notification.dart';
import 'package:yanolja_clone/presentation/provider/notification_provider.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// 알림 목록 화면 — 그룹 필터 × 날짜 섹션 × 시간대 타임라인.
///
/// - 상단 칩으로 그룹(혜택/예약/찜/티켓/포인트)을 거르고,
/// - 날짜(오늘/어제/그 이전)별 sticky 헤더로 구간을 나누며,
/// - 각 날짜 안에서는 새벽/아침/오후/저녁 시간대 노드가 달린
///   좌측 타임라인 레일을 따라 알림 카드가 흐른다.
///
/// 안 읽은 알림은 강조 표시되며, 항목을 탭하거나 "모두 읽음"을 누르면 읽음
/// 처리되어 홈 상단 벨 배지의 미확인 카운트가 즉시 줄어든다.
class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationProvider);
    final unread = ref.watch(unreadNotificationCountProvider);
    final selectedGroup = ref.watch(selectedNotificationGroupProvider);

    final filtered = selectedGroup == null
        ? notifications
        : notifications.where((n) => n.group == selectedGroup).toList();
    final sections = _buildDaySections(filtered, DateTime.now());

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
      body: Column(
        children: [
          const _GroupFilterBar(),
          Expanded(
            child: notifications.isEmpty
                ? const _EmptyState()
                : filtered.isEmpty
                    ? _FilteredEmptyState(group: selectedGroup!)
                    : _NotificationTimeline(sections: sections),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 그룹 필터 칩 바
// ─────────────────────────────────────────────────────────────

class _GroupFilterBar extends ConsumerWidget {
  const _GroupFilterBar();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedNotificationGroupProvider);
    final unreadByGroup = ref.watch(unreadCountByGroupProvider);
    final totalUnread = ref.watch(unreadNotificationCountProvider);

    void select(NotificationGroup? group) {
      HapticFeedback.selectionClick();
      ref.read(selectedNotificationGroupProvider.notifier).state = group;
    }

    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.background,
        border: Border(bottom: BorderSide(color: YanoljaColors.divider)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(
            YanoljaSpacing.gutter, 10, YanoljaSpacing.gutter, 12),
        child: Row(
          children: [
            _GroupChip(
              label: '전체',
              icon: Icons.notifications_rounded,
              accent: YanoljaColors.primary,
              unreadCount: totalUnread,
              isSelected: selected == null,
              onTap: () => select(null),
            ),
            for (final group in NotificationGroup.values) ...[
              const SizedBox(width: 8),
              _GroupChip(
                label: group.label,
                icon: group.icon,
                accent: group.accent,
                unreadCount: unreadByGroup[group] ?? 0,
                isSelected: selected == group,
                onTap: () => select(group),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GroupChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color accent;
  final int unreadCount;
  final bool isSelected;
  final VoidCallback onTap;

  const _GroupChip({
    required this.label,
    required this.icon,
    required this.accent,
    required this.unreadCount,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      // 칩 시각 높이는 ~38이지만 투명 세로 패딩으로 히트 영역을
      // YanoljaSpacing.tapMin(44) 이상으로 확장한다.
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: AnimatedContainer(
          duration: YanoljaMotion.base,
          curve: YanoljaMotion.curve,
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
          decoration: BoxDecoration(
            color:
                isSelected ? YanoljaColors.primary : YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            border: Border.all(
              color: isSelected ? YanoljaColors.primary : YanoljaColors.border,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 15,
                color: isSelected ? Colors.white : YanoljaColors.textSecondary,
              ),
              const SizedBox(width: 5),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                  color:
                      isSelected ? Colors.white : YanoljaColors.textSecondary,
                ),
              ),
              if (unreadCount > 0) ...[
                const SizedBox(width: 5),
                Container(
                  // 고정 height 대신 패딩 — 큰 글꼴 설정에서도 배지가 넘치지 않는다.
                  padding: const EdgeInsets.symmetric(
                      horizontal: 5.5, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.24)
                        : accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                  ),
                  child: Text(
                    '$unreadCount',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w900,
                      color: isSelected ? Colors.white : accent,
                      height: 1.1,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 날짜 섹션 × 시간대 타임라인 본문
// ─────────────────────────────────────────────────────────────

/// 하루치 알림 묶음. [rows]는 시간대 헤더와 알림 카드가 섞인 렌더 순서 목록.
class _DaySection {
  final String label;
  final List<_TimelineRow> rows;
  final int itemCount;
  final int unreadCount;

  const _DaySection({
    required this.label,
    required this.rows,
    required this.itemCount,
    required this.unreadCount,
  });
}

/// 타임라인의 한 줄 — 시간대 서브헤더이거나 알림 카드.
class _TimelineRow {
  final DayPart? partHeader;
  final AppNotification? item;
  final bool isFirst;
  final bool isLast;

  const _TimelineRow.part(this.partHeader, {required this.isFirst})
      : item = null,
        isLast = false;

  const _TimelineRow.item(this.item, {required this.isLast})
      : partHeader = null,
        isFirst = false;
}

List<_DaySection> _buildDaySections(
  List<AppNotification> items,
  DateTime now,
) {
  final sorted = [...items]
    ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt));

  final today = DateTime(now.year, now.month, now.day);
  const weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  String labelOf(DateTime day) {
    // 로컬 DateTime 차이는 DST 전환일에 23/25시간이 될 수 있어 달력 일수가
    // 어긋난다. UTC 자정끼리 비교해 항상 정확한 일수 차이를 얻는다.
    final diff = DateTime.utc(today.year, today.month, today.day)
        .difference(DateTime.utc(day.year, day.month, day.day))
        .inDays;
    if (diff == 0) return '오늘';
    if (diff == 1) return '어제';
    return '${day.month}월 ${day.day}일 ${weekdays[day.weekday - 1]}요일';
  }

  final sections = <_DaySection>[];
  DateTime? currentDay;
  var bucket = <AppNotification>[];

  void flush() {
    if (currentDay == null || bucket.isEmpty) return;
    final rows = <_TimelineRow>[];
    DayPart? lastPart;
    for (final n in bucket) {
      if (n.dayPart != lastPart) {
        rows.add(_TimelineRow.part(n.dayPart, isFirst: rows.isEmpty));
        lastPart = n.dayPart;
      }
      rows.add(_TimelineRow.item(n, isLast: false));
    }
    // 마지막 카드 아래로는 레일 라인을 그리지 않는다.
    rows[rows.length - 1] = _TimelineRow.item(bucket.last, isLast: true);
    sections.add(_DaySection(
      label: labelOf(currentDay),
      rows: rows,
      itemCount: bucket.length,
      unreadCount: bucket.where((n) => !n.isRead).length,
    ));
    bucket = <AppNotification>[];
  }

  for (final n in sorted) {
    final day = DateTime(
      n.receivedAt.year,
      n.receivedAt.month,
      n.receivedAt.day,
    );
    if (day != currentDay) {
      flush();
      currentDay = day;
    }
    bucket.add(n);
  }
  flush();

  return sections;
}

class _NotificationTimeline extends ConsumerWidget {
  final List<_DaySection> sections;

  const _NotificationTimeline({required this.sections});

  /// 진입 stagger 애니메이션을 적용할 상단 행 수.
  /// 이보다 뒤의 행은 스크롤로 드러날 때 지연·재애니메이션 없이 즉시 보인다.
  static const int _entranceRowLimit = 8;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = DateTime.now();

    // 섹션별 시작 행 번호를 미리 계산해 lazy itemBuilder 호출 순서와 무관하게
    // 행마다 결정적인 전역 인덱스를 얻는다. (빌드 부수효과로 카운터를 올리면
    // 뷰포트 재진입 때마다 지연이 달라지고 매번 재애니메이션된다.)
    final sectionStarts = <int>[];
    var offset = 0;
    for (final section in sections) {
      sectionStarts.add(offset);
      offset += section.rows.length;
    }

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        for (var si = 0; si < sections.length; si++)
          SliverMainAxisGroup(
            slivers: [
              SliverPersistentHeader(
                pinned: true,
                delegate: _DateHeaderDelegate(section: sections[si]),
              ),
              SliverList.builder(
                itemCount: sections[si].rows.length,
                itemBuilder: (context, index) {
                  final row = sections[si].rows[index];
                  final globalIndex = sectionStarts[si] + index;

                  Widget child;
                  if (row.partHeader != null) {
                    child = _DayPartHeaderRow(
                      part: row.partHeader!,
                      isFirst: row.isFirst,
                    );
                  } else {
                    final item = row.item!;
                    child = _TimelineItemRow(
                      item: item,
                      isLast: row.isLast,
                      timeLabel: item.timeLabel(now),
                      onTap: item.isRead
                          ? null
                          : () {
                              HapticFeedback.selectionClick();
                              ref
                                  .read(notificationProvider.notifier)
                                  .markAsRead(item.id);
                            },
                    );
                  }
                  if (globalIndex >= _entranceRowLimit) return child;
                  return YanoljaEntrance(
                    delay: YanoljaMotion.stagger(globalIndex),
                    child: child,
                  );
                },
              ),
            ],
          ),
        SliverPadding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.paddingOf(context).bottom + 32,
          ),
        ),
      ],
    );
  }
}

/// sticky 날짜 헤더 — 스크롤 시 상단에 고정되어 현재 보는 날짜를 알려준다.
class _DateHeaderDelegate extends SliverPersistentHeaderDelegate {
  final _DaySection section;

  const _DateHeaderDelegate({required this.section});

  static const double _height = 46;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final hasUnread = section.unreadCount > 0;
    return Container(
      height: _height,
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.gutter),
      decoration: BoxDecoration(
        color: YanoljaColors.background,
        border: Border(
          bottom: BorderSide(
            color: overlapsContent ? YanoljaColors.divider : Colors.transparent,
          ),
        ),
      ),
      child: Row(
        children: [
          Text(
            section.label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(width: 7),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
            decoration: BoxDecoration(
              color: hasUnread
                  ? YanoljaColors.primaryLight
                  : YanoljaColors.surfaceAlt,
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
            ),
            child: Text(
              hasUnread
                  ? '새 알림 ${section.unreadCount}'
                  : '${section.itemCount}건',
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                color: hasUnread
                    ? YanoljaColors.primary
                    : YanoljaColors.textSecondary,
                height: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _DateHeaderDelegate oldDelegate) {
    return oldDelegate.section.label != section.label ||
        oldDelegate.section.itemCount != section.itemCount ||
        oldDelegate.section.unreadCount != section.unreadCount;
  }
}

// ─────────────────────────────────────────────────────────────
// 타임라인 레일 (좌측 수직 라인 + 노드)
// ─────────────────────────────────────────────────────────────

const double _railWidth = 34;
const double _railLineWidth = 1.5;

/// 레일 한 칸: 위/아래 라인 연결 여부와 노드 위젯을 받아 그린다.
class _RailSlot extends StatelessWidget {
  final bool drawTop;
  final bool drawBottom;
  final double nodeTop;
  final Widget node;

  const _RailSlot({
    required this.drawTop,
    required this.drawBottom,
    required this.nodeTop,
    required this.node,
  });

  @override
  Widget build(BuildContext context) {
    const lineLeft = (_railWidth - _railLineWidth) / 2;
    return SizedBox(
      width: _railWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (drawTop)
            Positioned(
              left: lineLeft,
              top: 0,
              height: nodeTop,
              child: Container(
                width: _railLineWidth,
                color: YanoljaColors.border,
              ),
            ),
          if (drawBottom)
            Positioned(
              left: lineLeft,
              top: nodeTop,
              bottom: 0,
              child: Container(
                width: _railLineWidth,
                color: YanoljaColors.border,
              ),
            ),
          Positioned(
            top: nodeTop,
            left: 0,
            right: 0,
            child: FractionalTranslation(
              translation: const Offset(0, -0.5),
              child: Center(child: node),
            ),
          ),
        ],
      ),
    );
  }
}

/// 시간대 서브헤더 줄 — 레일 노드(시간대 아이콘) + 라벨.
class _DayPartHeaderRow extends StatelessWidget {
  final DayPart part;
  final bool isFirst;

  const _DayPartHeaderRow({required this.part, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.gutter),
      child: SizedBox(
        height: isFirst ? 40 : 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RailSlot(
              drawTop: !isFirst,
              drawBottom: true,
              nodeTop: isFirst ? 20 : 28,
              node: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: YanoljaColors.surfaceAlt,
                  shape: BoxShape.circle,
                  border: Border.all(color: YanoljaColors.border),
                ),
                child: Icon(
                  part.icon,
                  size: 13,
                  color: YanoljaColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Align(
                alignment: isFirst
                    ? const Alignment(-1, 0.45)
                    : const Alignment(-1, 0.72),
                child: Text(
                  part.label,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textSecondary,
                    letterSpacing: -0.2,
                    height: 1,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 알림 카드 한 줄 — 레일 도트 + 카드.
class _TimelineItemRow extends StatelessWidget {
  final AppNotification item;
  final bool isLast;
  final String timeLabel;

  /// null 이면(이미 읽은 알림) 눌림 효과·햅틱 없이 정적으로 렌더된다.
  final VoidCallback? onTap;

  const _TimelineItemRow({
    required this.item,
    required this.isLast,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: YanoljaSpacing.gutter),
      // 카드 높이(본문 1~2줄)에 맞춰 레일이 늘어나도록 IntrinsicHeight 사용.
      // SliverList 안에서는 세로 제약이 무한이라 stretch 를 쓰면 안 된다.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _RailSlot(
              drawTop: true,
              drawBottom: !isLast,
              nodeTop: 34,
              node: Container(
                width: unread ? 9 : 7,
                height: unread ? 9 : 7,
                decoration: BoxDecoration(
                  color: unread ? item.accent : YanoljaColors.background,
                  shape: BoxShape.circle,
                  border: unread
                      ? null
                      : Border.all(
                          color: YanoljaColors.border,
                          width: 1.5,
                        ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 4 : 10),
                child: _NotificationCard(
                  item: item,
                  timeLabel: timeLabel,
                  onTap: onTap,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;
  final String timeLabel;
  final VoidCallback? onTap;

  const _NotificationCard({
    required this.item,
    required this.timeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final unread = !item.isRead;

    return YanoljaPressable(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      child: AnimatedContainer(
        duration: YanoljaMotion.base,
        curve: YanoljaMotion.curve,
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: item.accent.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(YanoljaRadius.md),
              ),
              child: Icon(item.icon, color: item.accent, size: 21),
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
                  Row(
                    children: [
                      Text(
                        item.group.label,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: item.accent,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const Text(
                        '  ·  ',
                        style: TextStyle(
                          fontSize: 11,
                          color: YanoljaColors.textTertiary,
                        ),
                      ),
                      Text(
                        timeLabel,
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          // textTertiary 는 흰 배경 대비 ~2.25:1 로 읽기 어렵다.
                          color: YanoljaColors.textSecondary,
                        ),
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────
// 빈 상태
// ─────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
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

/// 그룹 필터 결과가 비었을 때 — 전체 보기로 돌아갈 길을 함께 제공한다.
class _FilteredEmptyState extends ConsumerWidget {
  final NotificationGroup group;

  const _FilteredEmptyState({required this.group});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: YanoljaEntrance(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: group.accent.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(group.icon, size: 36, color: group.accent),
            ),
            const SizedBox(height: 16),
            Text(
              '${group.label} 알림이 없어요',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: YanoljaColors.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              '새 소식이 도착하면 이곳에 모아드릴게요',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: YanoljaColors.textTertiary,
              ),
            ),
            const SizedBox(height: 18),
            YanoljaPressable(
              onTap: () {
                HapticFeedback.selectionClick();
                ref.read(selectedNotificationGroupProvider.notifier).state =
                    null;
              },
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              child: Container(
                height: 44,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
                child: const Text(
                  '전체 알림 보기',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
