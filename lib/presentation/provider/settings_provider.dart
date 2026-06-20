import 'package:flutter_riverpod/flutter_riverpod.dart';

enum NolThemeMode { system, light, dark }

enum NolLanguage { korean, english, japanese }

class NolSettingsState {
  final bool reservationAlerts;
  final bool marketingAlerts;
  final bool locationRecommendations;
  final bool personalization;
  final bool biometricLock;
  final bool dataSaver;
  final bool hapticFeedback;
  final bool motionEffects;
  final NolThemeMode themeMode;
  final NolLanguage language;
  final String defaultRegion;

  const NolSettingsState({
    this.reservationAlerts = true,
    this.marketingAlerts = false,
    this.locationRecommendations = true,
    this.personalization = true,
    this.biometricLock = false,
    this.dataSaver = false,
    this.hapticFeedback = true,
    this.motionEffects = true,
    this.themeMode = NolThemeMode.system,
    this.language = NolLanguage.korean,
    this.defaultRegion = '서울',
  });

  NolSettingsState copyWith({
    bool? reservationAlerts,
    bool? marketingAlerts,
    bool? locationRecommendations,
    bool? personalization,
    bool? biometricLock,
    bool? dataSaver,
    bool? hapticFeedback,
    bool? motionEffects,
    NolThemeMode? themeMode,
    NolLanguage? language,
    String? defaultRegion,
  }) {
    return NolSettingsState(
      reservationAlerts: reservationAlerts ?? this.reservationAlerts,
      marketingAlerts: marketingAlerts ?? this.marketingAlerts,
      locationRecommendations:
          locationRecommendations ?? this.locationRecommendations,
      personalization: personalization ?? this.personalization,
      biometricLock: biometricLock ?? this.biometricLock,
      dataSaver: dataSaver ?? this.dataSaver,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
      motionEffects: motionEffects ?? this.motionEffects,
      themeMode: themeMode ?? this.themeMode,
      language: language ?? this.language,
      defaultRegion: defaultRegion ?? this.defaultRegion,
    );
  }

  int get enabledCount {
    return [
      reservationAlerts,
      marketingAlerts,
      locationRecommendations,
      personalization,
      biometricLock,
      dataSaver,
      hapticFeedback,
      motionEffects,
    ].where((enabled) => enabled).length;
  }

  String get themeLabel {
    switch (themeMode) {
      case NolThemeMode.system:
        return '시스템 설정';
      case NolThemeMode.light:
        return '라이트';
      case NolThemeMode.dark:
        return '다크';
    }
  }

  String get languageLabel {
    switch (language) {
      case NolLanguage.korean:
        return '한국어';
      case NolLanguage.english:
        return 'English';
      case NolLanguage.japanese:
        return '日本語';
    }
  }
}

class NolSettingsNotifier extends StateNotifier<NolSettingsState> {
  NolSettingsNotifier() : super(const NolSettingsState());

  void setReservationAlerts(bool value) {
    state = state.copyWith(reservationAlerts: value);
  }

  void setMarketingAlerts(bool value) {
    state = state.copyWith(marketingAlerts: value);
  }

  void setLocationRecommendations(bool value) {
    state = state.copyWith(locationRecommendations: value);
  }

  void setPersonalization(bool value) {
    state = state.copyWith(personalization: value);
  }

  void setBiometricLock(bool value) {
    state = state.copyWith(biometricLock: value);
  }

  void setDataSaver(bool value) {
    state = state.copyWith(dataSaver: value);
  }

  void setHapticFeedback(bool value) {
    state = state.copyWith(hapticFeedback: value);
  }

  void setMotionEffects(bool value) {
    state = state.copyWith(motionEffects: value);
  }

  void setThemeMode(NolThemeMode value) {
    state = state.copyWith(themeMode: value);
  }

  void setLanguage(NolLanguage value) {
    state = state.copyWith(language: value);
  }

  void setDefaultRegion(String value) {
    state = state.copyWith(defaultRegion: value);
  }

  void reset() {
    state = const NolSettingsState();
  }
}

final nolSettingsProvider =
    StateNotifierProvider<NolSettingsNotifier, NolSettingsState>((ref) {
  return NolSettingsNotifier();
});
