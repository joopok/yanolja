// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yanolja_clone/core/router.dart';
// import 'package:yanolja_clone/firebase_options.dart';
import 'package:go_router/go_router.dart';

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

  // 🎨 상태바 스타일 설정 (T membership 보라색 테마)
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // 보라색 배경에 맞춘 밝은 아이콘
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF8F9FA), // T membership 배경색
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
    return MaterialApp.router(
      title: 'T membership 클론',
      debugShowCheckedModeBanner: false,
      
      // 🌈 Material Design 3 완전 적용 (Context7 최신 기능)
      theme: _buildNeumorphismTheme(),
      
      // 🌙 Dark Theme (T membership 보라색 다크모드)
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
          dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 0,
          scrolledUnderElevation: 3,
        ),
      ),
      
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }

  /// 🎨 **T membership 글라데이션 테마 시스템**
  /// masgib_screen.dart의 보라색 글라데이션을 전체 앱에 적용
  ThemeData _buildNeumorphismTheme() {
    // 🌈 T membership 글라데이션 색상 팔레트
    const primaryPurple = Color(0xFF6C63FF);          // 메인 보라색
    const lightPurple = Color.fromARGB(255, 37, 4, 249); // 진한 보라색
    const blueT = Color.fromARGB(255, 1, 79, 246);    // T 파란색
    const neumorphismBackground = Color(0xFFF8F9FA);  // 연한 배경
    const neumorphismSurface = Color(0xFFFFFFFF);     // 화이트 표면
    const neumorphismShadowLight = Color(0xFFFFFFFF); // 순백 하이라이트
    const neumorphismShadowDark = Color(0xFFE8E8E8);  // 연한 그레이 그림자
    const neumorphismSuccess = Color(0xFF00D4A3);     // 민트 그린 성공색
    const neumorphismWarning = Color(0xFFEA580C);     // 오렌지 경고색
    const neumorphismText = Color(0xFF1F2937);        // 다크 텍스트
    const neumorphismTextSecondary = Color(0xFF6B7280); // 그레이 보조텍스트

    return ThemeData(
      useMaterial3: true,
      
      // 🌈 T membership 글라데이션 색상 시스템
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryPurple,
        dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
        brightness: Brightness.light,
      ).copyWith(
        // 🎨 배경 계층 구조
        surface: neumorphismBackground,
        surfaceContainer: neumorphismSurface,
        surfaceContainerHigh: neumorphismSurface,
        surfaceContainerHighest: const Color(0xFFFBFBFC),
        
        // 🎯 주요 색상들 (T membership 보라색 적용)
        primary: primaryPurple,
        secondary: lightPurple,
        tertiary: blueT,
        
        // 📝 텍스트 색상
        onSurface: neumorphismText,
        onSurfaceVariant: neumorphismTextSecondary,
        
        // 🔲 테두리 색상
        outline: const Color(0xFFE5E7EB),
        outlineVariant: const Color(0xFFF3F4F6),
        
        // 🌟 그림자 색상
        shadow: neumorphismShadowDark,
      ),

      // 🎭 네오모피즘 카드 테마
      cardTheme: CardThemeData(
        color: neumorphismSurface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // 🔘 네오모피즘 버튼 테마들
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neumorphismSurface,
          foregroundColor: neumorphismText,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: neumorphismSurface,
          foregroundColor: neumorphismText,
          side: BorderSide.none,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        ),
      ),

      // 🏗️ 앱바 테마
      appBarTheme: const AppBarTheme(
        backgroundColor: neumorphismBackground,
        foregroundColor: neumorphismText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: neumorphismText,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // 🧩 네비게이션 바 테마 (T membership 보라색 적용)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: neumorphismSurface,
        selectedItemColor: primaryPurple,
        unselectedItemColor: neumorphismTextSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),

      // ✏️ 입력 필드 테마
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: neumorphismSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryPurple, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.red, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // 🔤 타이포그래피
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: neumorphismText,
          height: 1.2,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: neumorphismText,
          height: 1.3,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: neumorphismText,
          height: 1.3,
        ),
        headlineLarge: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: neumorphismText,
          height: 1.4,
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: neumorphismText,
          height: 1.4,
        ),
        headlineSmall: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: neumorphismText,
          height: 1.4,
        ),
        titleLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: neumorphismText,
          height: 1.5,
        ),
        titleMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: neumorphismText,
          height: 1.5,
        ),
        titleSmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: neumorphismText,
          height: 1.5,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: neumorphismText,
          height: 1.6,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: neumorphismText,
          height: 1.6,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: neumorphismTextSecondary,
          height: 1.6,
        ),
        labelLarge: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: neumorphismText,
          height: 1.4,
        ),
        labelMedium: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: neumorphismTextSecondary,
          height: 1.4,
        ),
        labelSmall: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: neumorphismTextSecondary,
          height: 1.4,
        ),
      ),

      // 📱 스캐폴드 배경
      scaffoldBackgroundColor: neumorphismBackground,
      
      // 🎯 기타 테마들
      dividerColor: const Color(0xFFE5E7EB),
      disabledColor: const Color(0xFFD1D5DB),
    );
  }
}

/// 🎨 **T membership 네오모피즘 디자인 헬퍼 클래스**
/// T membership 보라색 테마에 최적화된 네오모피즘 효과를 제공
class NeumorphismHelper {
  static const _lightShadow = Color(0xFFFFFFFF);
  static const _darkShadow = Color(0xFFE8E8E8);
  static const _purpleAccent = Color(0xFF6C63FF);
  
  /// 🌟 기본 네오모피즘 그림자 (돌출 효과)
  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: _darkShadow.withOpacity(0.5),
      offset: const Offset(6, 6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withOpacity(0.9),
      offset: const Offset(-6, -6),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// 🔽 눌린 네오모피즘 그림자 (인셋 효과)
  static List<BoxShadow> get pressedShadow => [
    BoxShadow(
      color: _darkShadow.withOpacity(0.6),
      offset: const Offset(3, 3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withOpacity(0.7),
      offset: const Offset(-3, -3),
      blurRadius: 6,
      spreadRadius: 0,
    ),
  ];

  /// 🌸 부드러운 네오모피즘 그림자 (미묘한 효과)
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: _darkShadow.withOpacity(0.3),
      offset: const Offset(4, 4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withOpacity(0.8),
      offset: const Offset(-4, -4),
      blurRadius: 8,
      spreadRadius: 0,
    ),
  ];

  /// 🔆 강한 네오모피즘 그림자 (강조 효과)
  static List<BoxShadow> get boldShadow => [
    BoxShadow(
      color: _darkShadow.withOpacity(0.7),
      offset: const Offset(8, 8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
    BoxShadow(
      color: _lightShadow.withOpacity(0.9),
      offset: const Offset(-8, -8),
      blurRadius: 16,
      spreadRadius: 0,
    ),
  ];
}