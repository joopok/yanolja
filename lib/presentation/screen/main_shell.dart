import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';

/// NOL(야놀자) 스타일 메인 셸
///
/// 실제 NOL 앱처럼 플랫한 흰색 하단 탭바를 사용합니다.
/// - 탭: 검색 / 내주변 / 홈 / 찜 / 마이
/// - 선택 시 진한 텍스트, 미선택 시 회색
/// - 상단 헤어라인 구분선, 부동 버튼/글래스 효과 없음
class MainShell extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const MainShell({
    super.key,
    required this.navigationShell,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        if (navigationShell.currentIndex != 0) {
          HapticFeedback.selectionClick();
          navigationShell.goBranch(0, initialLocation: true);
          return;
        }
        final shouldExit = await showYanoljaConfirmDialog(
          context: context,
          icon: Icons.logout_rounded,
          title: '앱을 종료할까요?',
          message: '진행 중인 검색과 선택 내용은 저장되지 않을 수 있어요.',
          confirmText: '종료',
          cancelText: '계속 둘러보기',
          isDestructive: true,
        );
        if (shouldExit) {
          await SystemNavigator.pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: navigationShell,
        bottomNavigationBar: YanoljaBottomNav(
          selectedBranchIndex: navigationShell.currentIndex,
          onBranchTap: _onTap,
        ),
      ),
    );
  }

  void _onTap(int branchIndex) {
    navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == navigationShell.currentIndex,
    );
  }
}
