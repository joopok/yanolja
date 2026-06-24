import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';

class AnimatedSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final ValueChanged<String> onSubmitted;
  final VoidCallback? onClear;
  final bool showAutocomplete;
  final List<String> suggestions;
  final ValueChanged<String>? onSuggestionTap;

  const AnimatedSearchField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmitted,
    this.onClear,
    this.showAutocomplete = false,
    this.suggestions = const [],
    this.onSuggestionTap,
  });

  @override
  AnimatedSearchFieldState createState() => AnimatedSearchFieldState();
}

class AnimatedSearchFieldState extends State<AnimatedSearchField> {
  bool _isFocused = false;
  bool _hasText = false;

  // 음성 검색
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_handleFocus);
    widget.controller.addListener(_handleText);
    _hasText = widget.controller.text.isNotEmpty;
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_handleFocus);
    widget.controller.removeListener(_handleText);
    if (_isListening) {
      _speech.cancel();
    }
    super.dispose();
  }

  void _handleFocus() {
    if (_isFocused == widget.focusNode.hasFocus) return;
    setState(() => _isFocused = widget.focusNode.hasFocus);
    if (_isFocused) HapticFeedback.selectionClick();
  }

  void _handleText() {
    final hasText = widget.controller.text.isNotEmpty;
    if (_hasText == hasText) return;
    setState(() => _hasText = hasText);
  }

  /// 외부(홈/더보기 검색바의 마이크)에서 음성 검색을 시작시키는 진입점.
  void startVoiceSearch() {
    if (!_isListening) _toggleListening();
  }

  /// 마이크 아이콘 탭 → 음성 인식 시작/중지.
  ///
  /// 인식된 텍스트는 실시간으로 검색창에 반영되고, 최종 결과가 나오면
  /// 곧바로 검색을 실행한다. 기기에서 음성 인식을 쓸 수 없으면 안내한다.
  Future<void> _toggleListening() async {
    if (_isListening) {
      await _speech.stop();
      if (mounted) setState(() => _isListening = false);
      return;
    }

    HapticFeedback.mediumImpact();

    try {
      final available = await _speech.initialize(
        onStatus: (status) {
          if ((status == 'done' || status == 'notListening') && mounted) {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          if (mounted) setState(() => _isListening = false);
          debugPrint('🎙️ 음성 인식 오류: ${error.errorMsg}');
        },
      );

      if (!available) {
        if (mounted) {
          setState(() => _isListening = false);
          _showSpeechUnavailable();
        }
        return;
      }

      if (!mounted) return;
      widget.focusNode.unfocus();
      setState(() => _isListening = true);

      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          final words = result.recognizedWords;
          widget.controller.value = TextEditingValue(
            text: words,
            selection: TextSelection.collapsed(offset: words.length),
          );
          widget.onChanged(words);
          if (result.finalResult) {
            setState(() => _isListening = false);
            if (words.trim().isNotEmpty) {
              widget.onSubmitted(words.trim());
            }
          }
        },
        listenOptions: stt.SpeechListenOptions(
          localeId: 'ko_KR',
          listenMode: stt.ListenMode.search,
          cancelOnError: true,
          partialResults: true,
        ),
      );
    } catch (e) {
      // MissingPluginException(전체 재빌드 전 hot restart) 등 플랫폼 예외를
      // 잡아 크래시 없이 안내한다.
      debugPrint('🎙️ 음성 검색 사용 불가: $e');
      if (mounted) {
        setState(() => _isListening = false);
        _showSpeechUnavailable();
      }
    }
  }

  void _showSpeechUnavailable() {
    YanoljaToast.show(
      context,
      '음성 검색을 사용할 수 없어요. 마이크 권한을 확인해 주세요.',
      icon: Icons.mic_off_rounded,
    );
  }

  /// 검색창 우측의 음성 검색 버튼. 듣는 중에는 컬러 칩으로 활성 상태를 표시한다.
  Widget _buildMicButton() {
    final listening = _isListening;
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Semantics(
        button: true,
        label: listening ? '음성 검색 중지' : '음성으로 검색',
        child: GestureDetector(
          onTap: _toggleListening,
          behavior: HitTestBehavior.opaque,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color:
                  listening ? YanoljaColors.primary : YanoljaColors.surfaceAlt,
              shape: BoxShape.circle,
              border: Border.all(
                color: listening ? YanoljaColors.primary : YanoljaColors.border,
              ),
            ),
            child: Icon(
              listening ? Icons.mic_rounded : Icons.mic_none_rounded,
              color: listening ? Colors.white : YanoljaColors.textSecondary,
              size: 20,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOut,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(YanoljaRadius.pill),
              border: Border.all(
                color: _isListening
                    ? YanoljaColors.primary
                    : _isFocused
                        ? YanoljaColors.textPrimary
                        : YanoljaColors.border,
                width: (_isListening || _isFocused) ? 1.4 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                const Icon(
                  Icons.search_rounded,
                  color: YanoljaColors.textPrimary,
                  size: 23,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    textInputAction: TextInputAction.search,
                    cursorColor: YanoljaColors.primary,
                    style: const TextStyle(
                      color: YanoljaColors.textPrimary,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      hintText: _isListening ? '듣고 있어요…' : '지역, 숙소, 공연 검색',
                      hintStyle: TextStyle(
                        color: _isListening
                            ? YanoljaColors.primary
                            : YanoljaColors.textTertiary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: widget.onChanged,
                    onSubmitted: widget.onSubmitted,
                  ),
                ),
                if (_hasText)
                  IconButton(
                    onPressed: () {
                      widget.controller.clear();
                      widget.onClear?.call();
                      HapticFeedback.selectionClick();
                    },
                    icon: const Icon(
                      Icons.cancel_rounded,
                      color: YanoljaColors.textTertiary,
                      size: 20,
                    ),
                  ),
                _buildMicButton(),
                const SizedBox(width: 8),
              ],
            ),
          ),
          if (_isFocused && widget.suggestions.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(YanoljaRadius.lg),
                border: Border.all(color: YanoljaColors.border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: widget.suggestions
                    .map(
                      (suggestion) => InkWell(
                        onTap: () => widget.onSuggestionTap?.call(suggestion),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.search_rounded,
                                size: 18,
                                color: YanoljaColors.textTertiary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  suggestion,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: YanoljaColors.textPrimary,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}
