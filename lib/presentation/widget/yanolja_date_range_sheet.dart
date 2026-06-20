import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// 야놀자(NOL) 스타일 날짜 범위 선택 바텀시트.
///
/// Flutter 기본 [showDateRangePicker] 대신 사용하는 커스텀 캘린더로,
/// 세로 스크롤 멀티 먼스 뷰 · 범위 하이라이트 · 체크인/체크아웃 라벨 ·
/// 한글 요일을 제공한다.
Future<DateTimeRange?> showYanoljaDateRangeSheet({
  required BuildContext context,
  DateTimeRange? initialRange,
  DateTime? firstDate,
  DateTime? lastDate,
  int monthsToShow = 12,
}) {
  final now = DateTime.now();
  final first = firstDate ?? DateTime(now.year, now.month, now.day);
  final last =
      lastDate ?? DateTime(first.year, first.month + monthsToShow, first.day);

  return showModalBottomSheet<DateTimeRange>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    builder: (_) => _DateRangeSheet(
      initialRange: initialRange,
      firstDate: first,
      lastDate: last,
    ),
  );
}

class _DateRangeSheet extends StatefulWidget {
  const _DateRangeSheet({
    required this.initialRange,
    required this.firstDate,
    required this.lastDate,
  });

  final DateTimeRange? initialRange;
  final DateTime firstDate;
  final DateTime lastDate;

  @override
  State<_DateRangeSheet> createState() => _DateRangeSheetState();
}

class _DateRangeSheetState extends State<_DateRangeSheet> {
  static const List<String> _weekdayLabels = [
    '일',
    '월',
    '화',
    '수',
    '목',
    '금',
    '토'
  ];

  DateTime? _start;
  DateTime? _end;
  late final List<DateTime> _months;

  @override
  void initState() {
    super.initState();
    _start = widget.initialRange?.start.dateOnly;
    _end = widget.initialRange?.end.dateOnly;

    // firstDate 가 속한 달부터 lastDate 가 속한 달까지 리스트 생성
    final months = <DateTime>[];
    var cursor = DateTime(widget.firstDate.year, widget.firstDate.month);
    final lastMonth = DateTime(widget.lastDate.year, widget.lastDate.month);
    while (!cursor.isAfter(lastMonth)) {
      months.add(cursor);
      cursor = DateTime(cursor.year, cursor.month + 1);
    }
    _months = months;
  }

  int get _nights {
    if (_start == null || _end == null) return 0;
    return _end!.difference(_start!).inDays;
  }

  void _onDayTap(DateTime day) {
    HapticFeedback.selectionClick();
    setState(() {
      if (_start == null || _end != null) {
        // 새 범위 시작
        _start = day;
        _end = null;
      } else {
        if (day.isAfter(_start!)) {
          _end = day;
        } else {
          // 시작일 이전(혹은 같은 날)을 누르면 시작일 재설정
          _start = day;
          _end = null;
        }
      }
    });
  }

  void _reset() {
    HapticFeedback.lightImpact();
    setState(() {
      _start = null;
      _end = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.9;
    final canApply = _start != null && _end != null;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: const BoxDecoration(
        color: YanoljaColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(),
          _buildHeader(context),
          _buildSummary(),
          _buildWeekdayRow(),
          const Divider(height: 1, color: YanoljaColors.divider),
          Flexible(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 8, bottom: 12),
              itemCount: _months.length,
              itemBuilder: (context, index) => _MonthView(
                month: _months[index],
                firstDate: widget.firstDate,
                lastDate: widget.lastDate,
                start: _start,
                end: _end,
                weekdayLabels: _weekdayLabels,
                onDayTap: _onDayTap,
              ),
            ),
          ),
          _buildFooter(context, canApply),
        ],
      ),
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 44,
      height: 4,
      margin: const EdgeInsets.only(top: 10, bottom: 6),
      decoration: BoxDecoration(
        color: YanoljaColors.border,
        borderRadius: BorderRadius.circular(999),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 6, 8, 8),
      child: Row(
        children: [
          const Text(
            '날짜 선택',
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
            color: YanoljaColors.textSecondary,
            splashRadius: 22,
          ),
        ],
      ),
    );
  }

  Widget _buildSummary() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Row(
        children: [
          Expanded(
            child: _SummaryChip(
              label: '체크인',
              date: _start,
              placeholder: '날짜 선택',
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                const Icon(Icons.arrow_forward_rounded,
                    size: 18, color: YanoljaColors.textTertiary),
                const SizedBox(height: 2),
                Text(
                  _nights > 0 ? '$_nights박' : '',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.primary,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _SummaryChip(
              label: '체크아웃',
              date: _end,
              placeholder: '날짜 선택',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekdayRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
      child: Row(
        children: List.generate(7, (i) {
          final color = i == 0
              ? YanoljaColors.sale
              : (i == 6
                  ? YanoljaColors.accentBlue
                  : YanoljaColors.textSecondary);
          return Expanded(
            child: Center(
              child: Text(
                _weekdayLabels[i],
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool canApply) {
    return Container(
      decoration: const BoxDecoration(
        color: YanoljaColors.background,
        border: Border(top: BorderSide(color: YanoljaColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
          child: Row(
            children: [
              SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: _start == null ? null : _reset,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: YanoljaColors.textPrimary,
                    side: const BorderSide(color: YanoljaColors.border),
                    minimumSize: const Size(0, 54),
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                  ),
                  child: const Text('초기화',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: canApply
                        ? () => Navigator.of(context).pop(
                              DateTimeRange(start: _start!, end: _end!),
                            )
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: YanoljaColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFB9C6FF),
                      disabledForegroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size(0, 54),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(YanoljaRadius.md),
                      ),
                    ),
                    child: Text(
                      canApply ? '$_nights박 선택 완료' : '날짜를 선택하세요',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w900),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 체크인/체크아웃 요약 칩
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.date,
    required this.placeholder,
  });

  final String label;
  final DateTime? date;
  final String placeholder;

  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  @override
  Widget build(BuildContext context) {
    final hasDate = date != null;
    final weekday = hasDate ? _weekdays[date!.weekday - 1] : '';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: hasDate ? YanoljaColors.primaryLight : YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(
          color: hasDate ? YanoljaColors.primary : Colors.transparent,
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color:
                  hasDate ? YanoljaColors.primary : YanoljaColors.textTertiary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            hasDate ? '${date!.month}.${date!.day} ($weekday)' : placeholder,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: hasDate
                  ? YanoljaColors.textPrimary
                  : YanoljaColors.textTertiary,
              letterSpacing: -0.3,
            ),
          ),
        ],
      ),
    );
  }
}

/// 한 달치 캘린더 그리드
class _MonthView extends StatelessWidget {
  const _MonthView({
    required this.month,
    required this.firstDate,
    required this.lastDate,
    required this.start,
    required this.end,
    required this.weekdayLabels,
    required this.onDayTap,
  });

  final DateTime month;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? start;
  final DateTime? end;
  final List<String> weekdayLabels;
  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(month.year, month.month);
    final firstOfMonth = DateTime(month.year, month.month, 1);
    // 일요일 시작 기준 앞쪽 빈 칸 수 (일=0, 월=1 ... 토=6)
    final leadingEmpty = firstOfMonth.weekday % 7;
    final totalCells = leadingEmpty + daysInMonth;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(6, 12, 0, 6),
            child: Text(
              '${month.year}년 ${month.month}월',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: YanoljaColors.textPrimary,
                letterSpacing: -0.4,
              ),
            ),
          ),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 0.84,
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              if (index < leadingEmpty) return const SizedBox.shrink();
              final dayNum = index - leadingEmpty + 1;
              final day = DateTime(month.year, month.month, dayNum);
              return _DayCell(
                day: day,
                firstDate: firstDate,
                lastDate: lastDate,
                start: start,
                end: end,
                onTap: onDayTap,
              );
            },
          ),
        ],
      ),
    );
  }
}

/// 개별 날짜 셀 — 범위 하이라이트 · 선택 원 · 체크인/체크아웃 라벨
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.firstDate,
    required this.lastDate,
    required this.start,
    required this.end,
    required this.onTap,
  });

  final DateTime day;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? start;
  final DateTime? end;
  final ValueChanged<DateTime> onTap;

  @override
  Widget build(BuildContext context) {
    final disabled =
        day.isBefore(firstDate.dateOnly) || day.isAfter(lastDate.dateOnly);
    final isStart = start != null && DateUtils.isSameDay(day, start);
    final isEnd = end != null && DateUtils.isSameDay(day, end);
    final inBetween = start != null &&
        end != null &&
        day.isAfter(start!) &&
        day.isBefore(end!);
    final isSelectedEdge = isStart || isEnd;
    final isToday = DateUtils.isSameDay(day, DateTime.now());

    // 범위 연결 배경 (셀을 좌/우 절반으로 나눠 자연스럽게 이어지도록)
    final hasRange = start != null && end != null;
    final leftFill = hasRange && (isEnd || inBetween);
    final rightFill = hasRange && (isStart || inBetween);

    // 기본 텍스트 색상 (일=빨강, 토=파랑)
    Color textColor;
    if (disabled) {
      textColor = YanoljaColors.textTertiary.withValues(alpha: 0.45);
    } else if (isSelectedEdge) {
      textColor = Colors.white;
    } else if (day.weekday == DateTime.sunday) {
      textColor = YanoljaColors.sale;
    } else if (day.weekday == DateTime.saturday) {
      textColor = YanoljaColors.accentBlue;
    } else {
      textColor = YanoljaColors.textPrimary;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => onTap(day),
      child: Stack(
        children: [
          // 범위 연결 배경
          if (hasRange)
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        color: leftFill
                            ? YanoljaColors.primaryLight
                            : Colors.transparent,
                      ),
                    ),
                    Expanded(
                      child: Container(
                        color: rightFill
                            ? YanoljaColors.primaryLight
                            : Colors.transparent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          // 날짜 + 라벨
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: isSelectedEdge
                      ? const BoxDecoration(
                          color: YanoljaColors.primary,
                          shape: BoxShape.circle,
                        )
                      : null,
                  child: Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 14.5,
                      fontWeight:
                          isSelectedEdge ? FontWeight.w900 : FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ),
                SizedBox(
                  height: 13,
                  child: isStart
                      ? const _EdgeLabel('체크인')
                      : isEnd
                          ? const _EdgeLabel('체크아웃')
                          : (isToday && !isSelectedEdge
                              ? const Text(
                                  '오늘',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: YanoljaColors.textTertiary,
                                  ),
                                )
                              : null),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EdgeLabel extends StatelessWidget {
  const _EdgeLabel(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w900,
        color: YanoljaColors.primary,
        letterSpacing: -0.2,
      ),
    );
  }
}

extension _DateOnly on DateTime {
  DateTime get dateOnly => DateTime(year, month, day);
}
