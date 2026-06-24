import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// NOL 공통 확인 다이얼로그
///
/// 기본 [AlertDialog] 대신 NOL 디자인 언어에 맞춘 확인 모달을 띄웁니다.
/// - 상단 컨텍스트 배지로 액션 성격을 즉시 전달
/// - 짧고 명확한 타이틀 + 읽기 쉬운 설명
/// - 모바일 친화적인 풀폭 세로 버튼(주요 액션 강조)
///
/// [isDestructive]가 true면 로그아웃·삭제처럼 되돌리기 어려운 액션을
/// 빨강 계열 톤으로 표현합니다.
///
/// 사용자가 확인을 누르면 `true`, 취소하거나 바깥을 탭하면 `false`를 반환합니다.
Future<bool> showYanoljaConfirmDialog({
  required BuildContext context,
  required IconData icon,
  required String title,
  required String message,
  String confirmText = '확인',
  String cancelText = '취소',
  bool isDestructive = false,
}) async {
  HapticFeedback.mediumImpact();
  final result = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: title,
    barrierColor: Colors.black.withValues(alpha: 0.50),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return Opacity(
        opacity: animation.value.clamp(0.0, 1.0),
        child: Transform.scale(
          scale: 0.92 + 0.08 * curved.value.clamp(0.0, 1.0),
          child: _ConfirmDialogBody(
            icon: icon,
            title: title,
            message: message,
            confirmText: confirmText,
            cancelText: cancelText,
            isDestructive: isDestructive,
          ),
        ),
      );
    },
  );
  return result ?? false;
}

class _ConfirmDialogBody extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String confirmText;
  final String cancelText;
  final bool isDestructive;

  const _ConfirmDialogBody({
    required this.icon,
    required this.title,
    required this.message,
    required this.confirmText,
    required this.cancelText,
    required this.isDestructive,
  });

  @override
  Widget build(BuildContext context) {
    final Color accent =
        isDestructive ? YanoljaColors.sale : YanoljaColors.primary;
    final Color badgeBg =
        isDestructive ? const Color(0xFFFFEAF0) : YanoljaColors.primaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: YanoljaColors.background,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: YanoljaColors.border),
                boxShadow: [
                  BoxShadow(
                    color: YanoljaColors.shadowStrong,
                    blurRadius: 34,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(22, 22, 22, 18),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                      border: Border.all(color: accent.withValues(alpha: 0.10)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(icon, color: accent, size: 22),
                        const SizedBox(width: 8),
                        Text(
                          isDestructive ? '확인이 필요한 작업' : '선택을 확인해 주세요',
                          style: TextStyle(
                            color: accent,
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.4,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: YanoljaColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // 주요(확인) 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.lightImpact();
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                        ),
                      ),
                      child: Text(
                        confirmText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  // 보조(취소) 버튼
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: TextButton(
                      onPressed: () {
                        HapticFeedback.selectionClick();
                        Navigator.of(context).pop(false);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: YanoljaColors.textSecondary,
                        backgroundColor: YanoljaColors.surfaceAlt,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                        ),
                      ),
                      child: Text(
                        cancelText,
                        style: const TextStyle(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
