import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  State<AnimatedSearchField> createState() => _AnimatedSearchFieldState();
}

class _AnimatedSearchFieldState extends State<AnimatedSearchField> {
  bool _isFocused = false;
  bool _hasText = false;

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
                color: _isFocused
                    ? YanoljaColors.textPrimary
                    : YanoljaColors.border,
                width: _isFocused ? 1.4 : 1,
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
                    decoration: const InputDecoration(
                      isDense: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                      hintText: '지역, 숙소, 공연 검색',
                      hintStyle: TextStyle(
                        color: YanoljaColors.textTertiary,
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
                  )
                else
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.mic_none_rounded,
                      color: YanoljaColors.textSecondary,
                      size: 21,
                    ),
                  ),
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
