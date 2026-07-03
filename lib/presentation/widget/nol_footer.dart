import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

/// 라이브 NOL(nol.yanolja.com) 모든 페이지 하단에 공통으로 붙는 사업자 정보 푸터.
///
/// 홈/서브홈 등 스크롤 화면 하단에 부착해 "완성된 서비스" 인상을 준다.
/// 실제 사업자 정보는 라이브 사이트 푸터를 mock으로 재현한 것이다.
class NolFooter extends StatelessWidget {
  const NolFooter({super.key});

  static const List<String> _policyLinks = [
    '회사소개',
    '이용약관',
    '개인정보처리방침',
    '청소년보호정책',
    '고객센터',
  ];

  @override
  Widget build(BuildContext context) {
    return YanoljaEntrance(
      child: Container(
        width: double.infinity,
        color: YanoljaColors.surfaceAlt,
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 고객센터
            Row(
              children: [
                const Icon(
                  Icons.headset_mic_rounded,
                  size: 18,
                  color: YanoljaColors.textSecondary,
                ),
                const SizedBox(width: 8),
                const Text(
                  '고객센터 1644-1346',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: YanoljaSpacing.s, vertical: 3),
                  decoration: BoxDecoration(
                    color: YanoljaColors.background,
                    borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                    border: Border.all(color: YanoljaColors.border),
                  ),
                  child: const Text(
                    '09:00 - 익일 03:00',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // 정책 링크 행
            Wrap(
              spacing: 0,
              runSpacing: 6,
              children: [
                for (var i = 0; i < _policyLinks.length; i++) ...[
                  YanoljaPressable(
                    onTap: () => _onPolicyTap(context, _policyLinks[i]),
                    child: Text(
                      _policyLinks[i],
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: _policyLinks[i] == '개인정보처리방침'
                            ? FontWeight.w900
                            : FontWeight.w600,
                        color: YanoljaColors.textSecondary,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (i != _policyLinks.length - 1)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '·',
                        style: TextStyle(color: YanoljaColors.textTertiary),
                      ),
                    ),
                ],
              ],
            ),
            const SizedBox(height: 18),
            // 사업자 정보
            const Text(
              '(주)놀유니버스 | 대표이사 이철웅\n'
              '사업자 등록번호 824-81-02515 | 통신판매업 2024-성남수정-0912\n'
              '경기도 성남시 수정구 금토로 70 (금토동, 텐엑스타워)',
              style: TextStyle(
                fontSize: 11.5,
                height: 1.6,
                fontWeight: FontWeight.w500,
                color: YanoljaColors.textTertiary,
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              '(주)놀유니버스는 통신판매 중개자로서 통신판매의 당사자가 아니며, '
              '상품의 예약·이용 및 환불 등과 관련한 의무와 책임은 각 판매자에게 있습니다.',
              style: TextStyle(
                fontSize: 11,
                height: 1.55,
                fontWeight: FontWeight.w500,
                color: YanoljaColors.textTertiary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              '© Nol Universe Co., Ltd.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: YanoljaColors.textTertiary.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onPolicyTap(BuildContext context, String label) {
    if (label == '고객센터') {
      context.push('/service/support');
      return;
    }
    if (label == '회사소개') {
      context.push('/service/app-info');
      return;
    }
    // 약관/정책류는 공통 안내 토스트(실제 약관 페이지는 mock 범위 외).
    YanoljaToast.show(context, '$label은(는) 준비 중이에요',
        icon: Icons.description_outlined);
  }
}
