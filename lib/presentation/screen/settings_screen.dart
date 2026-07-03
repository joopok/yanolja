import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_confirm_dialog.dart';
import 'package:yanolja_clone/presentation/provider/auth_provider.dart';
import 'package:yanolja_clone/presentation/provider/search_provider.dart';
import 'package:yanolja_clone/presentation/provider/settings_provider.dart';
import 'package:yanolja_clone/presentation/widget/nol_my_icon.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_bottom_nav.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(nolSettingsProvider);
    final user = ref.watch(authStateProvider);
    final recentSearchCount = ref.watch(searchProvider).recentSearches.length;

    return Scaffold(
      backgroundColor: YanoljaColors.surfaceAlt,
      bottomNavigationBar: const YanoljaBottomNav(selectedBranchIndex: 4),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAppBar(context, ref),
          SliverToBoxAdapter(child: _buildHero(context, settings, user)),
          SliverToBoxAdapter(
            child: _buildStatusGrid(settings, recentSearchCount),
          ),
          SliverToBoxAdapter(
            child: _SettingsSection(
              title: '알림',
              subtitle: '예약과 혜택을 필요한 만큼만 받아보세요',
              children: [
                _SettingsSwitchTile(
                  icon: Icons.notifications_active_rounded,
                  iconColor: YanoljaColors.primary,
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
                  icon: Icons.local_offer_rounded,
                  iconColor: YanoljaColors.sale,
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
          SliverToBoxAdapter(
            child: _SettingsSection(
              title: '개인화',
              subtitle: '여행 취향과 위치 기반 추천을 조정하세요',
              children: [
                _SettingsSwitchTile(
                  icon: Icons.near_me_rounded,
                  iconColor: YanoljaColors.mint,
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
                  icon: Icons.place_rounded,
                  iconColor: YanoljaColors.primaryPurple,
                  iconAsset: NolMyIconAsset.location,
                  title: '기본 여행 지역',
                  subtitle: settings.defaultRegion,
                  onTap: () => _showRegionSheet(context, ref),
                ),
                _SettingsSwitchTile(
                  icon: Icons.auto_awesome_rounded,
                  iconColor: YanoljaColors.yellow,
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
            child: _SettingsSection(
              title: '화면과 사용감',
              subtitle: '앱을 보는 방식과 인터랙션을 맞춤 설정하세요',
              children: [
                _ThemeModeTile(settings: settings),
                _SettingsActionTile(
                  icon: Icons.language_rounded,
                  iconColor: YanoljaColors.accentBlue,
                  iconAsset: NolMyIconAsset.language,
                  title: '언어',
                  subtitle: settings.languageLabel,
                  onTap: () => _showLanguageSheet(context, ref),
                ),
                _SettingsSwitchTile(
                  icon: Icons.vibration_rounded,
                  iconColor: YanoljaColors.primary,
                  iconAsset: NolMyIconAsset.settings,
                  title: '터치 피드백',
                  subtitle: '버튼과 토글을 누를 때 가벼운 진동을 사용',
                  value: settings.hapticFeedback,
                  onChanged: (value) {
                    ref
                        .read(nolSettingsProvider.notifier)
                        .setHapticFeedback(value);
                    if (value) HapticFeedback.selectionClick();
                  },
                ),
                _SettingsSwitchTile(
                  icon: Icons.motion_photos_auto_rounded,
                  iconColor: YanoljaColors.mint,
                  iconAsset: NolMyIconAsset.theme,
                  title: '부드러운 모션',
                  subtitle: '화면 전환과 카드 애니메이션을 자연스럽게 표시',
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
            child: _SettingsSection(
              title: '보안과 데이터',
              subtitle: '개인 정보와 앱 데이터를 관리하세요',
              children: [
                _SettingsSwitchTile(
                  icon: Icons.lock_rounded,
                  iconColor: YanoljaColors.primaryPurple,
                  iconAsset: NolMyIconAsset.security,
                  title: '앱 잠금',
                  subtitle: '앱 진입 시 생체 인증을 사용하도록 설정',
                  value: settings.biometricLock,
                  onChanged: (value) {
                    _feedback(ref);
                    ref
                        .read(nolSettingsProvider.notifier)
                        .setBiometricLock(value);
                  },
                ),
                _SettingsSwitchTile(
                  icon: Icons.data_saver_on_rounded,
                  iconColor: YanoljaColors.success,
                  iconAsset: NolMyIconAsset.settings,
                  title: '데이터 절약',
                  subtitle: '모바일 네트워크에서 고해상도 이미지 로딩을 줄여요',
                  value: settings.dataSaver,
                  onChanged: (value) {
                    _feedback(ref);
                    ref.read(nolSettingsProvider.notifier).setDataSaver(value);
                  },
                ),
                _SettingsActionTile(
                  icon: Icons.history_rounded,
                  iconColor: YanoljaColors.sale,
                  iconAsset: NolMyIconAsset.recent,
                  title: '검색 기록 삭제',
                  subtitle: recentSearchCount == 0
                      ? '삭제할 최근 검색어가 없어요'
                      : '최근 검색어 $recentSearchCount개',
                  enabled: recentSearchCount > 0,
                  onTap: () => _clearSearchHistory(context, ref),
                ),
              ],
            ),
          ),
          SliverToBoxAdapter(
            child: _SettingsSection(
              title: '계정',
              subtitle: user == null ? '로그인이 필요해요' : '${user.email}로 이용 중',
              children: [
                _SettingsActionTile(
                  icon: user == null
                      ? Icons.login_rounded
                      : Icons.account_circle_rounded,
                  iconColor: YanoljaColors.primary,
                  iconAsset: NolMyIconAsset.profileEdit,
                  title: user == null ? '로그인하기' : '내 정보 보기',
                  subtitle:
                      user == null ? '쿠폰과 예약 내역을 이어서 확인하세요' : user.displayName,
                  onTap: () {
                    _feedback(ref);
                    // /login 은 일반 라우트라 push 가능하지만, /my-info 는
                    // StatefulShellRoute 브랜치이므로 go 로 이동해야 한다.
                    // (push 시 ShellRouteMatch 페이지 키 중복으로 크래시)
                    if (user == null) {
                      context.push('/login');
                    } else {
                      context.go('/my-info');
                    }
                  },
                ),
                _SettingsActionTile(
                  icon: Icons.content_copy_rounded,
                  iconColor: YanoljaColors.accentBlue,
                  iconAsset: NolMyIconAsset.review,
                  title: '설정 요약 복사',
                  subtitle: '현재 설정 값을 클립보드에 저장',
                  onTap: () => _copySettingsSummary(context, ref, settings),
                ),
                _SettingsActionTile(
                  icon: Icons.restart_alt_rounded,
                  iconColor: YanoljaColors.textSecondary,
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
                20,
                10,
                20,
                30 + MediaQuery.paddingOf(context).bottom,
              ),
              child: const Text(
                'Yanolja Clone · NOL 설정',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: YanoljaColors.textTertiary,
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

  Widget _buildAppBar(BuildContext context, WidgetRef ref) {
    return YanoljaSliverAppBar.sub(
      title: '앱 설정',
      fallbackRoute: '/my-info',
      onBackPress: () {
        _feedback(ref);
        if (context.canPop()) {
          context.pop();
        } else {
          context.go('/my-info');
        }
      },
      actions: [
        IconButton(
          tooltip: '설정 초기화',
          icon: const Icon(Icons.restart_alt_rounded),
          onPressed: () => _showResetDialog(context, ref),
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  Widget _buildHero(
    BuildContext context,
    NolSettingsState settings,
    AppUser? user,
  ) {
    final accountLabel = user?.displayName ?? '게스트';

    return Container(
      color: YanoljaColors.surfaceAlt,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: YanoljaColors.surface,
          borderRadius: BorderRadius.circular(YanoljaRadius.xl),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: const [
            BoxShadow(
              color: YanoljaColors.shadow,
              blurRadius: 22,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Row(
          children: [
            const NolMyIcon(
              asset: NolMyIconAsset.settings,
              size: 78,
              semanticLabel: '앱 설정',
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: YanoljaColors.primaryLight,
                      borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                    ),
                    child: const Text(
                      'NOL CONTROL',
                      style: TextStyle(
                        color: YanoljaColors.primary,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    '내 여행 앱을 내 방식대로',
                    style: TextStyle(
                      color: YanoljaColors.textPrimary,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '$accountLabel님의 알림, 추천, 화면 설정이 바로 반영됩니다.',
                    style: const TextStyle(
                      color: YanoljaColors.textSecondary,
                      fontSize: 12.5,
                      height: 1.35,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 7,
                    runSpacing: 7,
                    children: [
                      _SettingsHeroMetric(
                        label: '활성 설정',
                        value: '${settings.enabledCount}개',
                      ),
                      _SettingsHeroMetric(
                        label: '화면',
                        value: settings.themeLabel,
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

  Widget _buildStatusGrid(NolSettingsState settings, int recentSearchCount) {
    final statusItems = [
      _StatusItem(
        icon: Icons.notifications_rounded,
        iconAsset: NolMyIconAsset.notification,
        label: '알림',
        value: settings.reservationAlerts || settings.marketingAlerts
            ? '켜짐'
            : '꺼짐',
        color: YanoljaColors.primary,
      ),
      _StatusItem(
        icon: Icons.place_rounded,
        iconAsset: NolMyIconAsset.location,
        label: '지역',
        value: settings.defaultRegion,
        color: YanoljaColors.mint,
      ),
      _StatusItem(
        icon: Icons.history_rounded,
        iconAsset: NolMyIconAsset.recent,
        label: '검색기록',
        value: '$recentSearchCount개',
        color: YanoljaColors.sale,
      ),
    ];

    return Container(
      color: YanoljaColors.background,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Row(
        children: [
          for (int i = 0; i < statusItems.length; i++) ...[
            Expanded(
              child: YanoljaEntrance(
                delay: YanoljaMotion.stagger(i, start: 60, step: 35),
                beginOffset: const Offset(0, 0.03),
                child: _StatusCard(item: statusItems[i]),
              ),
            ),
            if (i != statusItems.length - 1) const SizedBox(width: 9),
          ],
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
      subtitle: '홈과 내 주변 추천의 기준 지역으로 사용합니다',
      options: regions,
      selected: selectedRegion,
      labelBuilder: (region) => region,
      iconBuilder: (_) => Icons.place_rounded,
      onSelected: (region) {
        ref.read(nolSettingsProvider.notifier).setDefaultRegion(region);
        _showSnack(context, '$region 기준 추천으로 변경했어요');
      },
    );
  }

  void _showLanguageSheet(BuildContext context, WidgetRef ref) {
    _feedback(ref);
    final selectedLanguage = ref.read(nolSettingsProvider).language;

    _showOptionSheet<NolLanguage>(
      context: context,
      title: '언어 선택',
      subtitle: '앱 표시 언어를 선택하세요',
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
      iconBuilder: (_) => Icons.language_rounded,
      onSelected: (language) {
        ref.read(nolSettingsProvider.notifier).setLanguage(language);
        _showSnack(context, '언어 설정을 변경했어요');
      },
    );
  }

  void _showOptionSheet<T>({
    required BuildContext context,
    required String title,
    required String subtitle,
    required List<T> options,
    required T selected,
    required String Function(T option) labelBuilder,
    required IconData Function(T option) iconBuilder,
    required void Function(T option) onSelected,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          margin: const EdgeInsets.all(12),
          padding: EdgeInsets.fromLTRB(
            20,
            10,
            20,
            16 + MediaQuery.paddingOf(context).bottom,
          ),
          decoration: BoxDecoration(
            color: YanoljaColors.background,
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                color: YanoljaColors.shadow,
                blurRadius: 24,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 42,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 18),
                  decoration: BoxDecoration(
                    color: YanoljaColors.border,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
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
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0,
                ),
              ),
              const SizedBox(height: 14),
              for (final option in options)
                Material(
                  type: MaterialType.transparency,
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      iconBuilder(option),
                      color: option == selected
                          ? YanoljaColors.primary
                          : YanoljaColors.textTertiary,
                    ),
                    title: Text(
                      labelBuilder(option),
                      style: TextStyle(
                        color: YanoljaColors.textPrimary,
                        fontWeight: option == selected
                            ? FontWeight.w900
                            : FontWeight.w700,
                        letterSpacing: 0,
                      ),
                    ),
                    trailing: option == selected
                        ? const Icon(
                            Icons.check_circle_rounded,
                            color: YanoljaColors.primary,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      onSelected(option);
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  void _clearSearchHistory(BuildContext context, WidgetRef ref) {
    _feedback(ref);
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

class _SettingsHeroMetric extends StatelessWidget {
  final String label;
  final String value;

  const _SettingsHeroMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: YanoljaColors.textTertiary,
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            value,
            style: const TextStyle(
              color: YanoljaColors.textPrimary,
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return YanoljaEntrance(
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        color: YanoljaColors.background,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YanoljaSectionHeader(
              title: title,
              subtitle: subtitle,
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 8),
            ),
            for (int i = 0; i < children.length; i++) ...[
              children[i],
              if (i != children.length - 1)
                const Divider(
                  height: 1,
                  color: YanoljaColors.divider,
                  indent: 78,
                ),
            ],
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? iconAsset;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitchTile({
    required this.icon,
    required this.iconColor,
    this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 18, 14),
      child: Row(
        children: [
          _SettingsIcon(icon: icon, color: iconColor, asset: iconAsset),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: YanoljaColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 4),
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
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            activeThumbColor: YanoljaColors.primary,
            activeTrackColor: YanoljaColors.primaryLight,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String? iconAsset;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool enabled;

  const _SettingsActionTile({
    required this.icon,
    required this.iconColor,
    this.iconAsset,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 18, 14),
          child: Row(
            children: [
              _SettingsIcon(
                icon: icon,
                color: enabled ? iconColor : YanoljaColors.textTertiary,
                asset: enabled ? iconAsset : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: enabled
                            ? YanoljaColors.textPrimary
                            : YanoljaColors.textTertiary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
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
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color:
                    enabled ? YanoljaColors.textTertiary : YanoljaColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const _SettingsIcon(
                icon: Icons.palette_rounded,
                color: YanoljaColors.primary,
                asset: NolMyIconAsset.theme,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '화면 모드',
                      style: TextStyle(
                        color: YanoljaColors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      settings.themeLabel,
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
            ],
          ),
          const SizedBox(height: 14),
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
                    },
                  ),
                ),
                if (i != options.length - 1) const SizedBox(width: 8),
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
      child: AnimatedContainer(
        duration: YanoljaMotion.base,
        curve: YanoljaMotion.curve,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              selected ? YanoljaColors.textPrimary : YanoljaColors.surfaceAlt,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          border: Border.all(
            color: selected ? YanoljaColors.textPrimary : YanoljaColors.border,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: selected ? Colors.white : YanoljaColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : YanoljaColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
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

class _SettingsIcon extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String? asset;

  const _SettingsIcon({
    required this.icon,
    required this.color,
    this.asset,
  });

  @override
  Widget build(BuildContext context) {
    if (asset != null) {
      return NolMyIcon(asset: asset!, size: 46);
    }

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
      ),
      child: Icon(icon, color: color, size: 22),
    );
  }
}

class _StatusItem {
  final IconData icon;
  final String? iconAsset;
  final String label;
  final String value;
  final Color color;

  const _StatusItem({
    required this.icon,
    this.iconAsset,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _StatusCard extends StatelessWidget {
  final _StatusItem item;

  const _StatusCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 94,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        border: Border.all(color: YanoljaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.iconAsset == null)
            Icon(item.icon, color: item.color, size: 21)
          else
            NolMyIcon(asset: item.iconAsset!, size: 34),
          const Spacer(),
          Text(
            item.label,
            style: const TextStyle(
              color: YanoljaColors.textTertiary,
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            item.value,
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
