import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/booking.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// 결제 완료 화면 — 성공 애니메이션 · 예약 번호 · 요약 · 후속 액션
class PaymentCompleteScreen extends StatefulWidget {
  final Booking booking;
  const PaymentCompleteScreen({super.key, required this.booking});

  @override
  State<PaymentCompleteScreen> createState() => _PaymentCompleteScreenState();
}

class _PaymentCompleteScreenState extends State<PaymentCompleteScreen>
    with SingleTickerProviderStateMixin {
  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  late final AnimationController _controller;
  late final Animation<double> _badgeScale;
  late final Animation<double> _contentFade;
  late final Animation<Offset> _contentSlide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _badgeScale = Tween<double>(begin: 0.82, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.55, curve: YanoljaMotion.curve),
      ),
    );
    _contentFade = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 1.0, curve: YanoljaMotion.curve),
    );
    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.32, 1.0, curve: YanoljaMotion.curve),
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String get _reservationNo {
    final digits = widget.booking.id.replaceAll(RegExp(r'[^0-9]'), '');
    final tail =
        digits.length >= 8 ? digits.substring(digits.length - 8) : digits;
    return 'NOL-$tail';
  }

  String _fmtDate(DateTime d) =>
      '${d.year}.${d.month.toString().padLeft(2, '0')}.${d.day.toString().padLeft(2, '0')} '
      '(${_weekdays[d.weekday - 1]})';

  @override
  Widget build(BuildContext context) {
    final booking = widget.booking;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go('/home');
      },
      child: Scaffold(
        backgroundColor: YanoljaColors.surfaceAlt,
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                  children: [
                    Center(
                      child: ScaleTransition(
                        scale: _badgeScale,
                        child: _buildSuccessBadge(),
                      ),
                    ),
                    const SizedBox(height: 28),
                    FadeTransition(
                      opacity: _contentFade,
                      child: SlideTransition(
                        position: _contentSlide,
                        child: Column(
                          children: [
                            const Text(
                              '결제가 완료되었어요',
                              style: TextStyle(
                                fontSize: 23,
                                fontWeight: FontWeight.w900,
                                color: YanoljaColors.textPrimary,
                                letterSpacing: -0.6,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              '예약이 정상적으로 접수되었습니다.\n즐거운 여행 되세요!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                height: 1.5,
                                fontWeight: FontWeight.w500,
                                color: YanoljaColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 24),
                            _buildReservationNoChip(),
                            const SizedBox(height: 16),
                            _buildSummaryCard(booking),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              FadeTransition(
                opacity: _contentFade,
                child: _buildActions(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessBadge() {
    return Container(
      width: 104,
      height: 104,
      decoration: BoxDecoration(
        color: YanoljaColors.primary,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: YanoljaColors.primary.withValues(alpha: 0.32),
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: const Icon(Icons.check_rounded, size: 60, color: Colors.white),
    );
  }

  Widget _buildReservationNoChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
      decoration: BoxDecoration(
        color: YanoljaColors.primaryLight,
        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.confirmation_number_rounded,
              size: 16, color: YanoljaColors.primary),
          const SizedBox(width: 7),
          Text(
            '예약번호 $_reservationNo',
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.primary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Booking booking) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            booking.accommodationName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: YanoljaColors.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const Divider(height: 24, color: YanoljaColors.divider),
          _summaryRow('체크인', _fmtDate(booking.checkInDate)),
          const SizedBox(height: 10),
          _summaryRow('체크아웃', _fmtDate(booking.checkOutDate)),
          const SizedBox(height: 10),
          _summaryRow('숙박', '${booking.numberOfNights}박'),
          const Divider(height: 24, color: YanoljaColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '결제 금액',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: YanoljaColors.textPrimary,
                ),
              ),
              Text(
                '${YanoljaFormat.price(booking.totalPrice)}원',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.primary,
                  letterSpacing: -0.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: YanoljaColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: YanoljaColors.border)),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: () => context.go('/home'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: YanoljaColors.textPrimary,
                    side: const BorderSide(color: YanoljaColors.border),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                  ),
                  child: const Text('홈으로',
                      style: TextStyle(
                          fontSize: 15.5, fontWeight: FontWeight.w800)),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 2,
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () => context.go('/bookings'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: YanoljaColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(YanoljaRadius.md),
                    ),
                  ),
                  child: const Text('예약 내역 보기',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w900)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
