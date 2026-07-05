import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/provider/search_provider.dart';
import 'package:yanolja_clone/presentation/provider/settings_provider.dart';
import 'package:yanolja_clone/presentation/widget/nol_my_icon.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';

/// 앱 설정 화면 — 연회색 배경 위 흰 그룹 카드로 섹션을 나누는 구조.
///
/// - 계정 카드(최상단) → 상태 요약 스트립 → 설정 그룹 카드들 순서.
/// - 스위치 타일은 행 전체가 탭 가능하고 스크린리더에 한 덩어리로 읽힌다.
/// - '부드러운 모션'은 main.dart 의 MediaQuery 주입을 통해 앱 전역
///   애니메이션에 실제로 반영된다. 화면 모드(다크)와 언어는 아직 표시만
///   저장되는 준비 중 설정이라 선택 시 그 사실을 그대로 안내한다.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(nolSettingsProvider);
    final user = ref.watch(authStateProvider);
    final recentSearchCount = ref.watch(searchProvider).recentSearches.length;

    // TEMP-SCREENSHOT: 원복 필요 — 지역 시트 자동 오픈
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showRegionSheet(context, ref);
    });

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 4),
      body: CustomScrollView(
        controller: ScrollController(initialScrollOffset: 840), // TEMP-SCREENSHOT: 원복 필요
        physics: const BouncingScrollPhysics(),
        slivers: [
          const YanoljaSliverAppBar.sub(
            title: '앱 설정',
            fallbackRoute: '/my-info',
            backgroundColor: YanoljaColors.surfaceAlt,
          ),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: YanoljaMotion.stagger(0, start: 30, step: 45),
              child: _AccountCard(user: user, onFeedback: () => _feedback(ref)),
            ),
          ),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: YanoljaMotion.stagger(1, start: 30, step: 45),
              child: _StatusStrip(
                settings: settings,
                recentSearchCount: recentSearchCount,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: YanoljaEntrance(
              delay: YanoljaMotion.stagger(2, start: 30, step: 45),
              child: _SettingsGroup(
                title: '알림',
                subtitle: '예약과 혜택을 필요한 만큼만 받아보세요',
                children: [
                  _SettingsSwitchTile(
                    iconAsset: NolMyIconAsset.notification,
                    title: '예약 알림',
                    subtitle: '예약 확정, 체크인, 취소/환불 상태를 알려드려요',
                    value: settings.reservationAlerts,
                    onChanged: (value) {
                      _feedback(ref);
                      ref
                          .read(nolSettingsProvider.notifier)
                          .setReservationAlerts(value);
                    },
                  ),
                  _SettingsSwitchTile(
                    iconAsset: NolMyIconAsset.coupon,
                    title: '혜택·마케팅 알림',
                    subtitle: '쿠폰, 특가, NOLDAY 소식을 받아요',
                    value: settings.marketingAlerts,
                    onChanged: (value) {
                      _feedback(ref);
                      ref
                          .read(nolSettingsProvider.notifier)
                          .setMarketingAlerts(value);
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsGroup(
              title: '개인화',
              subtitle: '여행 취향과 위치 기반 추천을 조정하세요',
              children: [
                _SettingsSwitchTile(
                  iconAsset: NolMyIconAsset.location,
                  title: '위치 기반 추천',
                  subtitle: '${settings.defaultRegion} 기준으로 가까운 숙소와 티켓을 추천',
                  value: settings.locationRecommendations,
                  onChanged: (value) {
                    _feedback(ref);
                    ref
                        .read(nolSettingsProvider.notifier)
                        .setLocationRecommendations(value);
                  },
                ),
                _SettingsActionTile(
                  iconAsset: NolMyIconAsset.location,
                  title: '기본 여행 지역',
                  subtitle: settings.defaultRegion,
                  onTap: () => _showRegionSheet(context, ref),
                ),
                _SettingsSwitchTile(
                  iconAsset: NolMyIconAsset.points,
                  title: '취향 기반 추천',
                  subtitle: '검색과 찜 데이터를 바탕으로 더 맞는 상품을 보여줘요',
                  value: settings.personalization,
                  onChanged: (value) {
                    _feedback(ref);
                    ref
                        .read(nolSettingsProvider.notifier)
                        .setPersonalization(value);
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsGroup(
              title: '화면과 사용감',
              subtitle: '앱을 보는 방식과 인터랙션을 맞춤 설정하세요',
              children: [
                _ThemeModeTile(settings: settings),
                _SettingsActionTile(
                  iconAsset: NolMyIconAsset.language,
                  title: '언어',
                  subtitle: settings.language == NolLanguage.korean
                      ? settings.languageLabel
                      : '${settings.languageLabel} · 준비 중(한국어로 표시)',
                  onTap: () => _showLanguageSheet(context, ref),
                ),
                _SettingsSwitchTile(
                  iconAsset: NolMyIconAsset.settings,
                  title: '터치 피드백',
                  subtitle: '설정을 조작할 때 가벼운 진동을 사용',
                  value: settings.hapticFeedback,
                  onChanged: (value) {
                    ref
                        .read(nolSettingsProvider.notifier)
                        .setHapticFeedback(value);
                    if (value) HapticFeedback.selectionClick();
                  },
                ),
                _SettingsSwitchTile(
                  iconAsset: NolMyIconAsset.theme,
                  title: '부드러운 모션',
                  subtitle: '끄면 화면 전환과 카드 애니메이션을 최소화해요',
                  value: settings.motionEffects,
                  onChanged: (value) {
                    _feedback(ref);
                    ref
                        .read(nolSettingsProvider.notifier)
                        .setMotionEffects(value);
                  },
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsGroup(
              title: '보안과 데이터',
              subtitle: '개인 정보와 앱 데이터를 관리하세요',
              children: [
                _SettingsSwitchTile(
                  iconAsset: NolMyIconAsset.security,
                  title: '앱 잠금',
                  subtitle: '앱 진입 시 생체 인증 사용 · 준비 중이에요',
                  value: settings.biometricLock,
                  onChanged: (value) {
                    _feedback(ref);
                    ref
                        .read(nolSettingsProvider.notifier)
                        .setBiometricLock(value);
                  },
                ),
                _SettingsSwitchTile(
                  iconAsset: NolMyIconAsset.settings,
                  title: '데이터 절약',
                  subtitle: '모바일 네트워크에서 이미지 로딩을 줄여요 · 준비 중',
                  value: settings.dataSaver,
                  onChanged: (value) {
                    _feedback(ref);
                    ref.read(nolSettingsProvider.notifier).setDataSaver(value);
                  },
                ),
                _SettingsActionTile(
                  iconAsset: NolMyIconAsset.recent,
                  title: '검색 기록 삭제',
                  subtitle: recentSearchCount == 0
                      ? '삭제할 최근 검색어가 없어요'
                      : '최근 검색어 $recentSearchCount개',
                  enabled: recentSearchCount > 0,
                  onTap: () =>
                      _clearSearchHistory(context, ref, recentSearchCount),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsGroup(
              title: '설정 관리',
              subtitle: '현재 설정을 내보내거나 기본값으로 되돌려요',
              children: [
                _SettingsActionTile(
                  iconAsset: NolMyIconAsset.review,
                  title: '설정 요약 복사',
                  subtitle: '현재 설정 값을 클립보드에 저장',
                  onTap: () => _copySettingsSummary(context, ref, settings),
                ),
                _SettingsActionTile(
                  iconAsset: NolMyIconAsset.settings,
                  title: '설정 초기화',
                  subtitle: '알림, 개인화, 화면 설정을 기본값으로 되돌려요',
                  onTap: () => _showResetDialog(context, ref),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                YanoljaSpacing.gutter,
                22,
                YanoljaSpacing.gutter,
                30 + MediaQuery.paddingOf(context).bottom,
              ),
              child: const Text(
                'NOL(야놀자) 클론 · 앱 설정',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: YanoljaColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showRegionSheet(BuildContext context, WidgetRef ref) {
    _feedback(ref);
    const regions = ['서울', '부산', '제주', '강릉', '여수', '경주'];
    final selectedRegion = ref.read(nolSettingsProvider).defaultRegion;

    _showOptionSheet<String>(
      context: context,
      title: '기본 여행 지역',
      subtitle: '홈과 내 주변 추천의 기준 지역으로 저장합니다',
      options: regions,
      selected: selectedRegion,
      labelBuilder: (region) => region,
      onSelected: (region) {
        ref.read(nolSettingsProvider.notifier).setDefaultRegion(region);
        _showSnack(context, '기본 여행 지역을 $region(으)로 저장했어요');
      },
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    _feedback(ref);
    final selectedLanguage = ref.read(nolSettingsProvider).language;

    _showOptionSheet<NolLanguage>(
      context: context,
      title: '언어 선택',
      subtitle: '한국어 외 번역은 준비 중이에요 — 선택은 저장됩니다',
      options: NolLanguage.values,
      selected: selectedLanguage,
      labelBuilder: (language) {
        switch (language) {
          case NolLanguage.korean:
            return '한국어';
          case NolLanguage.english:
            return 'English';
          case NolLanguage.japanese:
            return '日本語';
        }
      },
      onSelected: (language) {
        ref.read(nolSettingsProvider.notifier).setLanguage(language);
        _showSnack(
          context,
          language == NolLanguage.korean
              ? '한국어로 표시합니다'
              : '선택을 저장했어요 — 번역이 준비되면 적용돼요',
        );
      },
    );
  }

  /// 단일 선택 옵션 바텀시트.
  ///
  /// 전역 bottomSheetTheme(상단 라운드·드래그 핸들·스크림)을 그대로 쓰고,
  /// 옵션 목록은 스크롤 가능하게 감싸 옵션 수가 늘어도 넘치지 않는다.
  void _showOptionSheet<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<T> options,
    required T selected,
    required String Function(T option) labelBuilder,
    required void Function(T option) onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              YanoljaSpacing.gutter,
              0,
              YanoljaSpacing.gutter,
              YanoljaSpacing.m,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: YanoljaColors.textPrimary,
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: YanoljaColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 10),
                Flexible(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      children: [
                        for (final option in options)
                          _OptionSheetRow(
                            label: labelBuilder(option),
                            selected: option == selected,
                            onTap: () {
                              Navigator.pop(context);
                              onSelected(option);
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _clearSearchHistory(
    BuildContext context,
    WidgetRef ref,
    int count,
  ) async {
    _feedback(ref);
    final confirmed = await showYanoljaConfirmDialog(
      context: context,
      icon: Icons.history_rounded,
      title: '검색 기록을 삭제할까요?',
      message: '최근 검색어 $count개가 모두 삭제됩니다.',
      confirmText: '삭제',
    );
    if (!confirmed || !context.mounted) return;
    ref.read(searchProvider.notifier).clearRecentSearches();
    _showSnack(context, '최근 검색어를 삭제했어요');
  }

  Future<void> _copySettingsSummary(
    BuildContext context,
    WidgetRef ref,
    NolSettingsState settings,
  ) async {
    _feedback(ref);
    final summary = [
      'NOL 설정 요약',
      '알림: ${settings.reservationAlerts ? '예약 알림 켜짐' : '예약 알림 꺼짐'}',
      '혜택 알림: ${settings.marketingAlerts ? '켜짐' : '꺼짐'}',
      '추천 지역: ${settings.defaultRegion}',
      '화면: ${settings.themeLabel}',
      '언어: ${settings.languageLabel}',
      '데이터 절약: ${settings.dataSaver ? '켜짐' : '꺼짐'}',
    ].join('\n');

    await Clipboard.setData(ClipboardData(text: summary));
    if (context.mounted) {
      _showSnack(context, '설정 요약을 복사했어요');
    }
  }

  Future<void> _showResetDialog(BuildContext context, WidgetRef ref) async {
    _feedback(ref);
    final confirmed = await showYanoljaConfirmDialog(
      context: context,
      icon: Icons.restart_alt_rounded,
      title: '설정을 초기화할까요?',
      message: '알림, 추천, 화면 설정이 기본값으로 돌아갑니다.',
      confirmText: '초기화',
    );
    if (!confirmed || !context.mounted) return;
    ref.read(nolSettingsProvider.notifier).reset();
    _showSnack(context, '설정을 기본값으로 초기화했어요');
  }

  static void _feedback(WidgetRef ref) {
    if (ref.read(nolSettingsProvider).hapticFeedback) {
      HapticFeedback.selectionClick();
    }
  }

  static void _showSnack(BuildContext context, String message) {
    YanoljaToast.show(
      context,
      message,
      icon: Icons.settings_rounded,
      duration: const Duration(seconds: 1),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 계정 카드 · 상태 요약 스트립
// ─────────────────────────────────────────────────────────────

class _AccountCard extends StatelessWidget {
  final AppUser? user;
  final VoidCallback onFeedback;

  const _AccountCard({required this.user, required this.onFeedback});

  @override
  Widget build(BuildContext context) {
    final loggedIn = user != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        YanoljaSpacing.gutter,
        4,
        YanoljaSpacing.gutter,
        0,
      ),
      child: Material(
        color: YanoljaColors.surface,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          side: const BorderSide(color: YanoljaColors.border),
          borderRadius: BorderRadius.circular(YanoljaRadius.xl),
        ),
        child: InkWell(
          onTap: () {
            onFeedback();
            // /login 은 일반 라우트라 push 가능하지만, /my-info 는
            // StatefulShellRoute 브랜치이므로 go 로 이동해야 한다.
            // (push 시 ShellRouteMatch 페이지 키 중복으로 크래시)
            if (loggedIn) {
              context.go('/my-info');
            } else {
              context.push('/login');
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                NolMyIcon(
                  asset: NolMyIconAsset.profileEdit,
                  size: 54,
                  semanticLabel: loggedIn ? '내 프로필' : '로그인',
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loggedIn ? user!.displayName : '로그인이 필요해요',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: YanoljaColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        loggedIn ? user!.email : '쿠폰과 예약 내역을 이어서 확인하세요',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: YanoljaColors.textSecondary,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (loggedIn)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: YanoljaColors.textSecondary,
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      color: YanoljaColors.primary,
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                    ),
                    child: const Text(
                      '로그인',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0,
                      ),
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

class _StatusStrip extends StatelessWidget {
  final NolSettingsState settings;
  final int recentSearchCount;

  const _StatusStrip({
    required this.settings,
    required this.recentSearchCount,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      (
        NolMyIconAsset.notification,
        '알림',
        settings.reservationAlerts || settings.marketingAlerts ? '켜짐' : '꺼짐',
      ),
      (NolMyIconAsset.location, '기본 지역', settings.defaultRegion),
      (NolMyIconAsset.settings, '활성 설정', '${settings.enabledCount}개'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        YanoljaSpacing.gutter,
        YanoljaSpacing.cardGap,
        YanoljaSpacing.gutter,
        0,
      ),
      child: Row(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            Expanded(
              child: _StatusCard(
                iconAsset: items[i].$1,
                label: items[i].$2,
                value: items[i].$3,
              ),
            ),
            if (i != items.length - 1) const SizedBox(width: YanoljaSpacing.s),
          ],
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  final String iconAsset;
  final String label;
  final String value;

  const _StatusCard({
    required this.iconAsset,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 13, 13, 12),
      decoration: BoxDecoration(
        color: YanoljaColors.surface,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          NolMyIcon(asset: iconAsset, size: 32),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              color: YanoljaColors.textSecondary,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: YanoljaColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 설정 그룹 카드와 타일
// ─────────────────────────────────────────────────────────────

/// 섹션 라벨(카드 밖) + 흰 라운드 그룹 카드(타일 목록) 한 벌.
class _SettingsGroup extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SettingsGroup({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  /// 타일 좌패딩(16) + 아이콘(44) + 간격(14) — 구분선을 텍스트 시작선에 맞춘다.
  static const double _dividerIndent = 74;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        YanoljaSpacing.gutter,
        YanoljaSpacing.sectionGap,
        YanoljaSpacing.gutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: YanoljaColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: YanoljaColors.textSecondary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: YanoljaColors.surface,
            clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
              side: const BorderSide(color: YanoljaColors.border),
              borderRadius: BorderRadius.circular(YanoljaRadius.xl),
            ),
            child: Column(
              children: [
                for (int i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i != children.length - 1)
                    const Divider(
                      height: 1,
                      color: YanoljaColors.divider,
                      indent: _dividerIndent,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 스위치 설정 한 줄 — 행 전체가 탭 대상이고, 스크린리더에는
/// 라벨과 스위치가 하나의 토글로 읽힌다.
class _SettingsSwitchTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        toggled: value,
        child: InkWell(
          onTap: () => onChanged(!value),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
            child: Row(
              children: [
                NolMyIcon(asset: iconAsset, size: 44),
                const SizedBox(width: 14),
                Expanded(
                  child: _TileTexts(title: title, subtitle: subtitle),
                ),
                const SizedBox(width: 8),
                ExcludeSemantics(
                  child: Switch.adaptive(
                    value: value,
                    // iOS(Cupertino 렌더) 기본 트랙은 시스템 그린이라
                    // 브랜드 블루 트랙 + 흰 썸으로 통일한다.
                    activeTrackColor: YanoljaColors.primary,
                    onChanged: onChanged,
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

/// 이동/실행형 설정 한 줄.
class _SettingsActionTile extends StatelessWidget {
  final String iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _SettingsActionTile({
    required this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.45,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 14, 12),
          child: Row(
            children: [
              NolMyIcon(asset: iconAsset, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: _TileTexts(title: title, subtitle: subtitle),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right_rounded,
                color: YanoljaColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TileTexts extends StatelessWidget {
  final String title;
  final String subtitle;

  const _TileTexts({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: YanoljaColors.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            color: YanoljaColors.textSecondary,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            height: 1.35,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

/// 화면 모드 선택 타일 — 라이트/다크/시스템 pill.
/// 다크 테마는 아직 없으므로(전 화면 라이트 토큰 고정) 다크/시스템 선택 시
/// '준비 중'임을 부제와 토스트로 정직하게 안내한다. 선택 자체는 저장된다.
class _ThemeModeTile extends ConsumerWidget {
  final NolSettingsState settings;

  const _ThemeModeTile({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final options = [
      (NolThemeMode.system, '시스템', Icons.phone_iphone_rounded),
      (NolThemeMode.light, '라이트', Icons.light_mode_rounded),
      (NolThemeMode.dark, '다크', Icons.dark_mode_rounded),
    ];
    final pending = settings.themeMode != NolThemeMode.light;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const NolMyIcon(asset: NolMyIconAsset.theme, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: _TileTexts(
                  title: '화면 모드',
                  subtitle: pending
                      ? '${settings.themeLabel} · 준비 중(라이트로 표시)'
                      : settings.themeLabel,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < options.length; i++) ...[
                Expanded(
                  child: _ModePill(
                    label: options[i].$2,
                    icon: options[i].$3,
                    selected: settings.themeMode == options[i].$1,
                    onTap: () {
                      SettingsScreen._feedback(ref);
                      ref
                          .read(nolSettingsProvider.notifier)
                          .setThemeMode(options[i].$1);
                      if (options[i].$1 != NolThemeMode.light) {
                        SettingsScreen._showSnack(
                          context,
                          '다크 화면은 준비 중이에요 — 지금은 라이트로 보여드려요',
                        );
                      }
                    },
                  ),
                ),
                if (i != options.length - 1)
                  const SizedBox(width: YanoljaSpacing.s),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _ModePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaPressable(
      pressedScale: 0.985,
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
      child: AnimatedContainer(
        duration: YanoljaMotion.base,
        curve: YanoljaMotion.curve,
        constraints: const BoxConstraints(minHeight: YanoljaSpacing.tapMin),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? YanoljaColors.primary : YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          border: Border.all(
            color: selected ? YanoljaColors.primary : YanoljaColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: selected ? Colors.white : YanoljaColors.textSecondary,
            ),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : YanoljaColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// 옵션 바텀시트 행
// ─────────────────────────────────────────────────────────────

class _OptionSheetRow extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OptionSheetRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(YanoljaRadius.md),
      child: Container(
        constraints: const BoxConstraints(minHeight: 52),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: YanoljaColors.textPrimary,
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (selected)
              const Icon(
                Icons.check_circle_rounded,
                color: YanoljaColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
