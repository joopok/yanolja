import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

/// NOL 공통 확인 다이얼로그
///
/// 기본 [AlertDialog] 대신 NOL 디자인 언어에 맞춘 확인 모달을 띄웁니다.
/// - 상단 원형 아이콘 배지로 맥락을 즉시 전달
/// - w900 타이틀 + 부드러운 설명
/// - 모바일 친화적인 풀폭 세로 버튼(주요 액션 강조)
/// - 스케일 + 페이드로 부드럽게 등장
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
    barrierColor: Colors.black.withValues(alpha: 0.46),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
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
    final Color badgeBg = isDestructive
        ? const Color(0xFFFFEAF0)
        : YanoljaColors.primaryLight;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 340),
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: YanoljaColors.background,
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.16),
                    blurRadius: 32,
                    offset: const Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // 아이콘 배지
                  Container(
                    width: 64,
                    height: 64,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: badgeBg,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: accent, size: 30),
                  ),
                  const SizedBox(height: 18),
                  // 타이틀
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 9),
                  // 메시지
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14.5,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
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
                          borderRadius: BorderRadius.circular(YanoljaRadius.md),
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
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(YanoljaRadius.md),
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
