import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

/// 🖼️ 풀스크린 이미지 갤러리 (Instagram/Pinterest 스타일)
class FullscreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String heroTag;

  const FullscreenImageGallery({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    required this.heroTag,
  });

  @override
  State<FullscreenImageGallery> createState() => _FullscreenImageGalleryState();
}

class _FullscreenImageGalleryState extends State<FullscreenImageGallery>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _animationController;
  late AnimationController _overlayController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _overlayAnimation;
  
  int _currentIndex = 0;
  bool _showOverlay = true;
  bool _isZoomed = false;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // 전체 화면 애니메이션 컨트롤러
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    // 오버레이 애니메이션 컨트롤러
    _overlayController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
    _overlayController.forward();
    
    // 3초 후 자동으로 UI 숨김
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showOverlay) {
        _toggleOverlay();
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    _overlayController.dispose();
    super.dispose();
  }

  void _toggleOverlay() {
    setState(() {
      _showOverlay = !_showOverlay;
    });
    
    if (_showOverlay) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }
    
    // 상태 바 스타일 변경
    SystemChrome.setSystemUIOverlayStyle(
      _showOverlay
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    );
  }

  void _onScaleStateChanged(PhotoViewScaleState scaleState) {
    setState(() {
      _isZoomed = scaleState != PhotoViewScaleState.initial;
    });
  }

  void _closeGallery() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _shareImage() {
    HapticFeedback.selectionClick();
    // TODO: 이미지 공유 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('이미지 공유 기능을 구현해주세요'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  void _downloadImage() {
    HapticFeedback.selectionClick();
    // TODO: 이미지 다운로드 기능 구현
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('이미지 다운로드 기능을 구현해주세요'),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          children: [
            // 🖼️ 메인 이미지 갤러리
            GestureDetector(
              onTap: _toggleOverlay,
              child: PhotoViewGallery.builder(
                scrollPhysics: _isZoomed 
                    ? const NeverScrollableScrollPhysics() 
                    : const BouncingScrollPhysics(),
                builder: (BuildContext context, int index) {
                  final imageUrl = widget.imageUrls[index];
                  return PhotoViewGalleryPageOptions(
                    imageProvider: CachedNetworkImageProvider(imageUrl),
                    initialScale: PhotoViewComputedScale.contained,
                    minScale: PhotoViewComputedScale.contained * 0.8,
                    maxScale: PhotoViewComputedScale.covered * 3.0,
                    heroAttributes: index == widget.initialIndex
                        ? PhotoViewHeroAttributes(tag: widget.heroTag)
                        : null,
                    onTapUp: (context, details, controllerValue) {
                      // 터치 시 오버레이 토글
                      if (!_isZoomed) {
                        _toggleOverlay();
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.broken_image_rounded,
                                size: 64,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 16),
                              Text(
                                '이미지를 불러올 수 없습니다',
                                style: TextStyle(
                                  color: Colors.white54,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                itemCount: widget.imageUrls.length,
                loadingBuilder: (context, event) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  ),
                ),
                pageController: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                  HapticFeedback.selectionClick();
                },
              ),
            ),
            
            // 🎨 상단 오버레이 (앱바)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _overlayAnimation,
                child: Container(
                  padding: EdgeInsets.only(
                    top: MediaQuery.of(context).padding.top + 8,
                    left: 8,
                    right: 8,
                    bottom: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.8),
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      // 닫기 버튼
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: IconButton(
                          onPressed: _closeGallery,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // 페이지 인디케이터
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          '${_currentIndex + 1} / ${widget.imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      
                      const Spacer(),
                      
                      // 더보기 메뉴
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: PopupMenuButton<String>(
                          onSelected: (value) {
                            switch (value) {
                              case 'share':
                                _shareImage();
                                break;
                              case 'download':
                                _downloadImage();
                                break;
                            }
                          },
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                          color: Colors.black87,
                          elevation: 8,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          itemBuilder: (BuildContext context) => [
                            const PopupMenuItem(
                              value: 'share',
                              child: ListTile(
                                leading: Icon(Icons.share_rounded, color: Colors.white),
                                title: Text('공유하기', style: TextStyle(color: Colors.white)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'download',
                              child: ListTile(
                                leading: Icon(Icons.download_rounded, color: Colors.white),
                                title: Text('저장하기', style: TextStyle(color: Colors.white)),
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // 🎨 하단 오버레이 (썸네일)
            if (widget.imageUrls.length > 1)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _overlayAnimation,
                  child: Container(
                    height: 120,
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom + 16,
                      top: 16,
                      left: 16,
                      right: 16,
                    ),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.imageUrls.length,
                      itemBuilder: (context, index) {
                        final isSelected = index == _currentIndex;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _pageController.animateToPage(
                              index,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Container(
                            width: 60,
                            height: 60,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: isSelected 
                                    ? Colors.white 
                                    : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: CachedNetworkImage(
                                imageUrl: widget.imageUrls[index],
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey[800],
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey[800],
                                  child: const Icon(
                                    Icons.broken_image_rounded,
                                    color: Colors.white54,
                                    size: 24,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 