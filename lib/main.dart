// import 'package:firebase_core/firebase_core.dart';
import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/router.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/presentation/provider/notification_provider.dart';
import 'package:yanolja_clone/presentation/provider/settings_provider.dart';
// import 'package:yanolja_clone/firebase_options.dart';

void main() async {
  // Flutter 엔진과 위젯 트리를 바인딩합니다.
  WidgetsFlutterBinding.ensureInitialized();

  // 앱을 세로 모드로만 고정
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 🔥 Firebase 초기화 (임시 비활성화 - GoogleService-Info.plist 누락)
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  // 상태바 스타일: NOL 앱처럼 밝은 배경 + 어두운 아이콘
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    const ProviderScope(
      child: YanoljaCloneApp(),
    ),
  );
}

class YanoljaCloneApp extends ConsumerWidget {
  const YanoljaCloneApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final settings = ref.watch(nolSettingsProvider);

    // 미확인 알림 수를 OS 앱아이콘 배지에 동기화한다.
    // 현재 카운트를 watch 하므로 첫 빌드와 이후 변경마다 배지가 갱신된다.
    // .ignore(): 네이티브 플러그인 미가용(예: cold rebuild 전 hot restart) 시
    // MissingPluginException 이 크래시로 번지지 않도록 무시한다.
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    AppBadgePlus.updateBadge(unreadCount).ignore();

    return MaterialApp.router(
      title: 'NOL(야놀자)',
      debugShowCheckedModeBanner: false,

      // NOL 라이트 테마 (앱 전체 일관 적용)
      theme: _buildYanoljaTheme(),
      darkTheme: _buildYanoljaTheme(),

      themeMode: _resolveThemeMode(settings.themeMode),

      // 🇰🇷 한국어 로케일 — 날짜 선택기/기본 위젯 텍스트를 한글로 표시
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      routerConfig: router,
    );
  }

  ThemeMode _resolveThemeMode(NolThemeMode mode) {
    switch (mode) {
      case NolThemeMode.system:
        return ThemeMode.system;
      case NolThemeMode.light:
        return ThemeMode.light;
      case NolThemeMode.dark:
        return ThemeMode.dark;
    }
  }

  /// NOL 디자인 테마
  /// 블루/퍼플 브랜드 컬러 + 깔끔한 화이트 플랫 스타일
  ThemeData _buildYanoljaTheme() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: YanoljaColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: YanoljaColors.primary,
      onPrimary: Colors.white,
      secondary: YanoljaColors.primaryPurple,
      surface: YanoljaColors.surface,
      onSurface: YanoljaColors.textPrimary,
      onSurfaceVariant: YanoljaColors.textSecondary,
      outline: YanoljaColors.border,
      outlineVariant: YanoljaColors.divider,
      surfaceContainerHighest: YanoljaColors.surfaceAlt,
      shadow: YanoljaColors.shadow,
      error: YanoljaColors.error,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: YanoljaColors.background,
      splashFactory: InkRipple.splashFactory,

      // 🏷️ 칩 테마
      chipTheme: ChipThemeData(
        backgroundColor: YanoljaColors.surfaceAlt,
        selectedColor: YanoljaColors.primaryLight,
        side: BorderSide.none,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        ),
        labelStyle: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: YanoljaColors.textPrimary,
        ),
      ),

      // 🃏 카드 테마 — 절제된 그림자, 둥근 모서리
      cardTheme: CardThemeData(
        color: YanoljaColors.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shadowColor: YanoljaColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        ),
      ),

      // 🔘 메인 버튼 — 예약 앱에서 반복 사용해도 부담 없는 선명한 블루 CTA
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: YanoljaColors.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor:
              YanoljaColors.primary.withValues(alpha: 0.32),
          disabledForegroundColor: Colors.white.withValues(alpha: 0.86),
          elevation: 0,
          minimumSize: const Size.fromHeight(52),
          shadowColor: Colors.transparent,
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.3,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.md),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: YanoljaColors.textPrimary,
          backgroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: YanoljaColors.border, width: 1),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(YanoljaRadius.md),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: YanoljaColors.primary,
          minimumSize: const Size(YanoljaSpacing.tapMin, YanoljaSpacing.tapMin),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),

      // 🏗️ 앱바 — 화이트, 좌측 정렬, 무 elevation (야놀자 스타일)
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.white,
        foregroundColor: YanoljaColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0.5,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: YanoljaColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        iconTheme: IconThemeData(color: YanoljaColors.textPrimary),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
          statusBarBrightness: Brightness.light,
        ),
      ),

      // 🧭 하단 네비게이션 — 플랫 화이트, 핑크 선택
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        indicatorColor: Colors.transparent,
        elevation: 0,
        height: 60,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 24,
            color:
                selected ? YanoljaColors.primary : YanoljaColors.textTertiary,
          );
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color:
                selected ? YanoljaColors.primary : YanoljaColors.textTertiary,
          );
        }),
      ),

      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: YanoljaColors.primary,
        unselectedItemColor: YanoljaColors.textTertiary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        showUnselectedLabels: true,
      ),

      // ✏️ 입력 필드 — 라이트 그레이 필, 핑크 포커스
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: YanoljaColors.surfaceInput,
        hintStyle: const TextStyle(
          color: YanoljaColors.textTertiary,
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          borderSide: const BorderSide(color: YanoljaColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          borderSide: const BorderSide(color: YanoljaColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          borderSide:
              const BorderSide(color: YanoljaColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          borderSide: const BorderSide(color: YanoljaColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          borderSide: const BorderSide(color: YanoljaColors.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),

      // 〰️ 구분선
      dividerTheme: const DividerThemeData(
        color: YanoljaColors.divider,
        thickness: 1,
        space: 1,
      ),
      dividerColor: YanoljaColors.divider,

      // 🔤 타이포그래피 — 또렷하고 깔끔한 한국어 친화 스케일
      textTheme: const TextTheme(
        displayLarge: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.6,
            height: 1.25),
        displayMedium: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.5,
            height: 1.3),
        displaySmall: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.4,
            height: 1.3),
        headlineMedium: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.4,
            height: 1.3),
        headlineSmall: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.3,
            height: 1.35),
        titleLarge: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.3,
            height: 1.4),
        titleMedium: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.2,
            height: 1.4),
        titleSmall: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.2,
            height: 1.4),
        bodyLarge: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w400,
            color: YanoljaColors.textPrimary,
            letterSpacing: -0.2,
            height: 1.5),
        bodyMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            color: YanoljaColors.textSecondary,
            letterSpacing: -0.2,
            height: 1.5),
        bodySmall: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: YanoljaColors.textSecondary,
            letterSpacing: -0.1,
            height: 1.45),
        labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: YanoljaColors.textPrimary),
        labelMedium: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: YanoljaColors.textSecondary),
        labelSmall: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: YanoljaColors.textTertiary),
      ),

      // 🎚️ 바텀시트
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        modalBackgroundColor: Colors.white,
        modalBarrierColor: YanoljaColors.scrim,
        dragHandleColor: YanoljaColors.border,
        dragHandleSize: Size(44, 4),
        showDragHandle: true,
        shape: RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(YanoljaRadius.sheet)),
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: YanoljaColors.snackbar,
        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
          fontSize: 13.5,
          height: 1.35,
        ),
        behavior: SnackBarBehavior.floating,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        ),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        actionTextColor: YanoljaColors.primaryLight,
      ),
    );
  }
}
