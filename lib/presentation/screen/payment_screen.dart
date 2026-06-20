import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/data/model/booking.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/provider/booking_provider.dart';

/// 결제 화면으로 전달되는 예약 정보
class PaymentArgs {
  final Accommodation accommodation;
  final DateTimeRange dateRange;
  final int nights;
  final int adults;
  final int rooms;

  const PaymentArgs({
    required this.accommodation,
    required this.dateRange,
    required this.nights,
    this.adults = 2,
    this.rooms = 1,
  });
}

/// 결제 수단 정의
class _PayMethod {
  final String label;
  final String desc;
  final IconData icon;
  final Color color;
  const _PayMethod(this.label, this.desc, this.icon, this.color);
}

const List<_PayMethod> _payMethods = [
  _PayMethod('NOL 페이', '간편결제 · 최대 5% 적립', Icons.account_balance_wallet_rounded,
      YanoljaColors.primary),
  _PayMethod('신용·체크카드', '국내 모든 카드 사용 가능', Icons.credit_card_rounded,
      YanoljaColors.accentBlue),
  _PayMethod(
      '카카오페이', '카카오 간편결제', Icons.chat_bubble_rounded, YanoljaColors.yellow),
  _PayMethod(
      '계좌이체', '실시간 계좌이체', Icons.account_balance_rounded, YanoljaColors.mint),
];

/// 약관 항목
class _Term {
  final String label;
  const _Term(this.label);
}

const List<_Term> _terms = [
  _Term('만 14세 이상이며, 예약 내용을 확인했습니다 (필수)'),
  _Term('개인정보 수집·이용 동의 (필수)'),
  _Term('취소·환불 규정 동의 (필수)'),
];

class PaymentScreen extends ConsumerStatefulWidget {
  final PaymentArgs args;
  const PaymentScreen({super.key, required this.args});

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  static const List<String> _weekdays = ['월', '화', '수', '목', '금', '토', '일'];

  int _selectedMethod = 0;
  late List<bool> _agreed;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _agreed = List<bool>.filled(_terms.length, false);
  }

  bool get _allAgreed => _agreed.every((e) => e);

  Accommodation get _acc => widget.args.accommodation;
  int get _nights => widget.args.nights;

  int get _unitPrice => _acc.price;
  int get _totalPrice => _nights > 0 ? _nights * _unitPrice : _unitPrice;
  int get _rate => YanoljaFormat.discountRate(_acc.id);
  int get _original => YanoljaFormat.originalPrice(_totalPrice, _rate);
  int get _discount => _original - _totalPrice;

  String _fmtFullDate(DateTime d) =>
      '${d.month}월 ${d.day}일 (${_weekdays[d.weekday - 1]})';

  Future<void> _pay() async {
    if (!_allAgreed) {
      HapticFeedback.mediumImpact();
      _showSnack('필수 약관에 모두 동의해 주세요');
      return;
    }
    HapticFeedback.mediumImpact();
    setState(() => _isProcessing = true);

    // 모의 결제 처리 (PG 연동 대체)
    await Future.delayed(const Duration(milliseconds: 1500));

    final booking = Booking(
      id: 'nol_${DateTime.now().millisecondsSinceEpoch}',
      accommodationId: _acc.id,
      accommodationName: _acc.name,
      imageUrl: _acc.imageUrls.isNotEmpty ? _acc.imageUrls.first : '',
      checkInDate: widget.args.dateRange.start,
      checkOutDate: widget.args.dateRange.end,
      numberOfNights: _nights,
      totalPrice: _totalPrice,
      status: 'upcoming',
    );

    ref.read(bookingRepositoryProvider).addBooking(booking);
    ref.invalidate(bookingListProvider);

    if (!mounted) return;
    context.pushReplacement('/payment-complete', extra: booking);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message,
              style: const TextStyle(fontWeight: FontWeight.w700)),
          behavior: SnackBarBehavior.floating,
          backgroundColor: YanoljaColors.textPrimary,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(YanoljaRadius.md)),
          margin: const EdgeInsets.all(16),
          duration: const Duration(seconds: 2),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authStateProvider);

    return Stack(
      children: [
        Scaffold(
          backgroundColor: YanoljaColors.surfaceAlt,
          appBar: AppBar(
            title: const Text('예약 확인 및 결제'),
            backgroundColor: Colors.white,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              onPressed: () => context.pop(),
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
            children: [
              _buildAccommodationCard(),
              const SizedBox(height: 12),
              _buildScheduleCard(),
              const SizedBox(height: 12),
              _buildBookerCard(user),
              const SizedBox(height: 12),
              _buildPaymentMethodCard(),
              const SizedBox(height: 12),
              _buildPriceCard(),
              const SizedBox(height: 12),
              _buildTermsCard(),
              const SizedBox(height: 8),
              _buildNotice(),
            ],
          ),
          bottomNavigationBar: _buildBottomBar(),
        ),
        if (_isProcessing) _buildProcessingOverlay(),
      ],
    );
  }

  // ───────────────────────── 카드 공통 셸
  Widget _card({required Widget child, EdgeInsets? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: child,
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w900,
        color: YanoljaColors.textPrimary,
        letterSpacing: -0.3,
      ),
    );
  }

  // ───────────────────────── 숙소 요약
  Widget _buildAccommodationCard() {
    return _card(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(YanoljaRadius.md),
            child: SizedBox(
              width: 84,
              height: 84,
              child: _acc.imageUrls.isNotEmpty
                  ? Image.network(
                      _acc.imageUrls.first,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: YanoljaColors.surfaceAlt,
                        child: const Icon(Icons.image_not_supported_outlined,
                            color: YanoljaColors.textTertiary),
                      ),
                    )
                  : Container(color: YanoljaColors.surfaceAlt),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: YanoljaColors.primaryLight,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    _acc.category,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _acc.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.star_rounded,
                        size: 15, color: YanoljaColors.star),
                    const SizedBox(width: 2),
                    Text(
                      _acc.rating.toStringAsFixed(1),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: YanoljaColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _acc.address,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          color: YanoljaColors.textTertiary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────── 일정/인원
  Widget _buildScheduleCard() {
    final start = widget.args.dateRange.start;
    final end = widget.args.dateRange.end;
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('예약 일정'),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _scheduleColumn(
                    '체크인', _fmtFullDate(start), _acc.checkInTime),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: YanoljaColors.primaryLight,
                  borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                ),
                child: Text(
                  '$_nights박',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.primary,
                  ),
                ),
              ),
              Expanded(
                child: _scheduleColumn(
                    '체크아웃', _fmtFullDate(end), _acc.checkOutTime,
                    alignEnd: true),
              ),
            ],
          ),
          const Divider(height: 28, color: YanoljaColors.divider),
          Row(
            children: [
              const Icon(Icons.person_outline_rounded,
                  size: 18, color: YanoljaColors.textSecondary),
              const SizedBox(width: 8),
              Text(
                '인원 정보',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: YanoljaColors.textSecondary,
                ),
              ),
              const Spacer(),
              Text(
                '성인 ${widget.args.adults}명 · 객실 ${widget.args.rooms}개',
                style: const TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w800,
                  color: YanoljaColors.textPrimary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _scheduleColumn(String label, String date, String time,
      {bool alignEnd = false}) {
    final cross = alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: cross,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.primary,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          date,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w900,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$time 부터',
          style: const TextStyle(
            fontSize: 11.5,
            color: YanoljaColors.textTertiary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ───────────────────────── 예약자 정보
  Widget _buildBookerCard(AppUser? user) {
    final name = user?.displayName ?? 'NOL러';
    final email = user?.email ?? 'guest@nol.com';
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('예약자 정보'),
          const SizedBox(height: 14),
          _infoRow('이름', name),
          const SizedBox(height: 10),
          _infoRow('이메일', email),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13.5,
              color: YanoljaColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: YanoljaColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────── 결제 수단
  Widget _buildPaymentMethodCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('결제 수단'),
          const SizedBox(height: 14),
          for (int i = 0; i < _payMethods.length; i++) ...[
            _methodTile(i, _payMethods[i]),
            if (i != _payMethods.length - 1) const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }

  Widget _methodTile(int index, _PayMethod method) {
    final selected = _selectedMethod == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _selectedMethod = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          color: selected ? YanoljaColors.primaryLight : YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.md),
          border: Border.all(
            color: selected ? YanoljaColors.primary : YanoljaColors.border,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: method.color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(method.icon, size: 20, color: method.color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    method.label,
                    style: const TextStyle(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w800,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    method.desc,
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: YanoljaColors.textTertiary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              selected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 22,
              color:
                  selected ? YanoljaColors.primary : YanoljaColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────── 결제 금액
  Widget _buildPriceCard() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('결제 금액'),
          const SizedBox(height: 16),
          _priceRow('객실 요금 ($_nights박)', '${YanoljaFormat.price(_original)}원'),
          const SizedBox(height: 10),
          _priceRow(
            '즉시 할인 ($_rate%)',
            '-${YanoljaFormat.price(_discount)}원',
            valueColor: YanoljaColors.sale,
          ),
          const Divider(height: 26, color: YanoljaColors.divider),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '총 결제 금액',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.textPrimary,
                ),
              ),
              Text(
                '${YanoljaFormat.price(_totalPrice)}원',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.primary,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'NOL 카드 결제 시 추가 적립 혜택',
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.primary.withValues(alpha: 0.9),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13.5,
            color: YanoljaColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: valueColor ?? YanoljaColors.textPrimary,
          ),
        ),
      ],
    );
  }

  // ───────────────────────── 약관 동의
  Widget _buildTermsCard() {
    return _card(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: Column(
        children: [
          // 전체 동의
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              HapticFeedback.selectionClick();
              final next = !_allAgreed;
              setState(() {
                for (int i = 0; i < _agreed.length; i++) {
                  _agreed[i] = next;
                }
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Row(
                children: [
                  _checkIcon(_allAgreed, large: true),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      '약관에 모두 동의합니다',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        color: YanoljaColors.textPrimary,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(
              height: 8,
              color: YanoljaColors.divider,
              indent: 10,
              endIndent: 10),
          for (int i = 0; i < _terms.length; i++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() => _agreed[i] = !_agreed[i]);
              },
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                child: Row(
                  children: [
                    _checkIcon(_agreed[i]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _terms[i].label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: YanoljaColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _checkIcon(bool checked, {bool large = false}) {
    final size = large ? 26.0 : 22.0;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 140),
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: checked ? YanoljaColors.primary : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(
          color: checked ? YanoljaColors.primary : YanoljaColors.border,
          width: 1.6,
        ),
      ),
      child: Icon(
        Icons.check_rounded,
        size: large ? 17 : 14,
        color: checked ? Colors.white : YanoljaColors.textTertiary,
      ),
    );
  }

  Widget _buildNotice() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Text(
        '· 체크인 1일 전까지 무료 취소 가능하며, 이후에는 환불 규정에 따라 수수료가 부과될 수 있습니다.\n'
        '· 본 화면은 데모용 모의 결제로, 실제 금액이 청구되지 않습니다.',
        style: TextStyle(
          fontSize: 11.5,
          height: 1.5,
          color: YanoljaColors.textTertiary,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ───────────────────────── 하단 결제 바
  Widget _buildBottomBar() {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: YanoljaColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    '총 결제 금액',
                    style: TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textTertiary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${YanoljaFormat.price(_totalPrice)}원',
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : _pay,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: YanoljaColors.primary,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFB9C6FF),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(YanoljaRadius.md),
                      ),
                    ),
                    child: Text(
                      '${YanoljaFormat.price(_totalPrice)}원 결제하기',
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

  // ───────────────────────── 결제 진행 오버레이
  Widget _buildProcessingOverlay() {
    return Positioned.fill(
      child: ColoredBox(
        color: Colors.black.withValues(alpha: 0.55),
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: YanoljaColors.primary,
                  ),
                ),
                SizedBox(height: 18),
                Text(
                  '결제를 진행하고 있어요',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: YanoljaColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  '잠시만 기다려 주세요',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: YanoljaColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
