import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class AnimatedSearchField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final Function(String) onChanged;
  final Function(String) onSubmitted;
  final VoidCallback? onClear;
  final bool showAutocomplete;
  final List<String> suggestions;
  final Function(String)? onSuggestionTap;

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

class _AnimatedSearchFieldState extends State<AnimatedSearchField>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _slideController;
  late AnimationController _pulseController;
  
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  bool _isFocused = false;
  bool _hasText = false;

  // 구글 맵 스타일 애니메이션 힌트 텍스트들
  final List<String> _animatedHints = [
    '어디로 떠나고 싶으세요?',
    '제주도 여행은 어떠세요?',
    '부산 바다를 보러 가요',
    '강릉에서 휴식을...',
    '서울 호텔을 찾아보세요',
    '펜션에서 힐링하기',
    '리조트에서 특별한 하루',
    '한옥에서 전통 체험',
  ];

  @override
  void initState() {
    super.initState();
    
    // 애니메이션 컨트롤러 초기화
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // 애니메이션 설정
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // 포커스 및 텍스트 변화 감지
    widget.focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChange);
    
    // 애니메이션 시작
    _slideController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _slideController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isFocused = widget.focusNode.hasFocus;
    });
    
    if (_isFocused) {
      _scaleController.forward();
      HapticFeedback.lightImpact();
    } else {
      _scaleController.reverse();
    }
  }

  void _onTextChange() {
    final hasText = widget.controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return SlideTransition(
      position: _slideAnimation,
      child: Column(
        children: [
          // 🎯 구글 맵 스타일 검색 필드
          AnimatedBuilder(
            animation: _scaleAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  height: 56,
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _isFocused 
                          ? theme.colorScheme.primary 
                          : theme.colorScheme.outline.withValues(alpha: 0.3),
                      width: _isFocused ? 2 : 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: _isFocused ? 0.15 : 0.08),
                        blurRadius: _isFocused ? 16 : 8,
                        offset: const Offset(0, 4),
                        spreadRadius: _isFocused ? 2 : 0,
                      ),
                      if (_isFocused)
                        BoxShadow(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // 🔍 검색 아이콘 (구글 맵 스타일)
                      Padding(
                        padding: const EdgeInsets.only(left: 16, right: 8),
                        child: AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _isFocused ? _pulseAnimation.value : 1.0,
                              child: Icon(
                                Icons.search_rounded,
                                color: _isFocused 
                                    ? theme.colorScheme.primary 
                                    : theme.colorScheme.onSurfaceVariant,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                      
                      // 📝 텍스트 필드
                      Expanded(
                        child: TextField(
                          controller: widget.controller,
                          focusNode: widget.focusNode,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            hintStyle: TextStyle(
                              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w400,
                            ),
                            // 🎬 타이핑 애니메이션 힌트 텍스트
                            hintText: null,
                          ),
                          onChanged: widget.onChanged,
                          onSubmitted: widget.onSubmitted,
                        ),
                      ),
                      
                      // ❌ 클리어 버튼
                      if (_hasText)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: TweenAnimationBuilder<double>(
                            duration: const Duration(milliseconds: 200),
                            tween: Tween(begin: 0.0, end: 1.0),
                            builder: (context, value, child) {
                              return Transform.scale(
                                scale: value,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.clear_rounded,
                                    color: theme.colorScheme.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    widget.controller.clear();
                                    widget.onClear?.call();
                                    HapticFeedback.lightImpact();
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
          
          // 💭 타이핑 애니메이션 힌트 (검색 필드가 비어있을 때만 표시)
          if (!_isFocused && !_hasText)
            Container(
              margin: const EdgeInsets.only(top: 8, left: 32, right: 32),
              child: AnimatedTextKit(
                animatedTexts: _animatedHints.map((hint) => 
                  TypewriterAnimatedText(
                    hint,
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                      fontWeight: FontWeight.w400,
                    ),
                    speed: const Duration(milliseconds: 80),
                  ),
                ).toList(),
                totalRepeatCount: 1,
                pause: const Duration(milliseconds: 2000),
                displayFullTextOnTap: false,
              ),
            ),
        ],
      ),
    );
  }
}