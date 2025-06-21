import 'package:flutter_riverpod/flutter_riverpod.dart';

// 찜한 숙소의 ID 목록을 관리하는 StateNotifier
class SavedNotifier extends StateNotifier<List<String>> {
  SavedNotifier() : super([]);

  // 찜 목록에 숙소를 추가하거나 제거하는 토글 기능
  void toggleSaved(String accommodationId) {
    if (state.contains(accommodationId)) {
      // 이미 찜 목록에 있으면 제거
      state = state.where((id) => id != accommodationId).toList();
    } else {
      // 찜 목록에 없으면 추가
      state = [...state, accommodationId];
    }
  }
}

// StateNotifierProvider를 생성하여 UI에서 SavedNotifier를 사용할 수 있도록 합니다.
final savedProvider = StateNotifierProvider<SavedNotifier, List<String>>((ref) {
  return SavedNotifier();
}); 