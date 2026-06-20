import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';

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
  late ScrollController _thumbnailController;
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
    _thumbnailController = ScrollController();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);

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
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _overlayAnimation = CurvedAnimation(
      parent: _overlayController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
    _overlayController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncThumbnailStrip(widget.initialIndex, jump: true);
    });

    // 3초 후 자동으로 UI 숨김
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && _showOverlay) {
        _setOverlayVisible(false);
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _thumbnailController.dispose();
    _animationController.dispose();
    _overlayController.dispose();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
    super.dispose();
  }

  void _toggleOverlay() {
    _setOverlayVisible(!_showOverlay);
  }

  void _setOverlayVisible(bool visible) {
    if (_showOverlay == visible) return;
    setState(() {
      _showOverlay = visible;
    });

    if (_showOverlay) {
      _overlayController.forward();
    } else {
      _overlayController.reverse();
    }

    // 상태 바 스타일 변경
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
  }

  void _closeGallery() {
    HapticFeedback.lightImpact();
    _animationController.reverse().then((_) {
      if (mounted) {
        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);
        Navigator.of(context).pop();
      }
    });
  }

  void _syncThumbnailStrip(int index, {bool jump = false}) {
    if (!_thumbnailController.hasClients) return;

    final max = _thumbnailController.position.maxScrollExtent;
    final target = (index * 76.0 - 24).clamp(0.0, max);
    if (jump) {
      _thumbnailController.jumpTo(target);
      return;
    }
    _thumbnailController.animateTo(
      target,
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutCubic,
    );
  }

  void _updateZoomState(PhotoViewControllerValue controllerValue) {
    final next = (controllerValue.scale ?? 1.0) > 1.03;
    if (_isZoomed != next) {
      setState(() => _isZoomed = next);
    }
    if (next && _showOverlay) {
      _setOverlayVisible(false);
    }
  }

  Future<void> _shareImage() async {
    HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: _currentImageUrl));
    _showGallerySnack('이미지 링크를 복사했어요');
  }

  Future<void> _downloadImage() async {
    HapticFeedback.selectionClick();
    await Clipboard.setData(ClipboardData(text: _currentImageUrl));
    _showGallerySnack('저장할 이미지 링크를 복사했어요');
  }

  String get _currentImageUrl {
    if (widget.imageUrls.isEmpty) return '';
    final index = _currentIndex.clamp(0, widget.imageUrls.length - 1).toInt();
    return widget.imageUrls[index];
  }

  void _showGallerySnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.black87,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Widget _buildGalleryMenuButton() {
    return PopupMenuButton<String>(
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
      offset: const Offset(0, 8),
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.46),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: const Icon(
          Icons.more_horiz_rounded,
          color: Colors.white,
          size: 23,
        ),
      ),
      color: Colors.black87,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'share',
          child: Row(
            children: [
              Icon(Icons.share_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('공유하기', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'download',
          child: Row(
            children: [
              Icon(Icons.download_rounded, color: Colors.white, size: 20),
              SizedBox(width: 12),
              Text('저장하기', style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.imageUrls.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: YanoljaAppBar.modal(
          title: '사진',
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          onBackPress: _closeGallery,
        ),
        body: SafeArea(
          child: Stack(
            children: [
              const Center(
                child: Text(
                  '표시할 사진이 없습니다',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        extendBodyBehindAppBar: true,
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: Stack(
            children: [
              // 🖼️ 메인 이미지 갤러리
              PhotoViewGallery.builder(
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
                    filterQuality: FilterQuality.high,
                    heroAttributes: index == widget.initialIndex
                        ? PhotoViewHeroAttributes(tag: widget.heroTag)
                        : null,
                    onTapUp: (context, details, controllerValue) {
                      final isZoomed = (controllerValue.scale ?? 1.0) > 1.03;
                      if (!isZoomed) {
                        _toggleOverlay();
                      }
                    },
                    onScaleEnd: (context, details, controllerValue) {
                      _updateZoomState(controllerValue);
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
                    _isZoomed = false;
                  });
                  _syncThumbnailStrip(index);
                  HapticFeedback.selectionClick();
                },
              ),

              // 🎨 상단 오버레이 (공통 앱바)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  ignoring: !_showOverlay,
                  child: FadeTransition(
                    opacity: _overlayAnimation,
                    child: YanoljaAppBar.modal(
                      title:
                          '${_currentIndex + 1} / ${widget.imageUrls.length}',
                      backgroundColor: Colors.black.withValues(alpha: 0.58),
                      foregroundColor: Colors.white,
                      onBackPress: _closeGallery,
                      actions: [_buildGalleryMenuButton()],
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
                  child: IgnorePointer(
                    ignoring: !_showOverlay,
                    child: FadeTransition(
                      opacity: _overlayAnimation,
                      child: Container(
                        height: MediaQuery.of(context).padding.bottom + 118,
                        padding: EdgeInsets.only(
                          bottom: MediaQuery.of(context).padding.bottom + 14,
                          top: 14,
                          left: 16,
                          right: 16,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              Colors.black.withValues(alpha: 0.86),
                              Colors.black.withValues(alpha: 0.58),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.56, 1.0],
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '사진 ${_currentIndex + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                              ),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 66,
                              child: ListView.separated(
                                controller: _thumbnailController,
                                scrollDirection: Axis.horizontal,
                                physics: const BouncingScrollPhysics(),
                                itemCount: widget.imageUrls.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(width: 8),
                                itemBuilder: (context, index) {
                                  final isSelected = index == _currentIndex;
                                  return GestureDetector(
                                    onTap: () {
                                      HapticFeedback.selectionClick();
                                      _pageController.animateToPage(
                                        index,
                                        duration:
                                            const Duration(milliseconds: 300),
                                        curve: Curves.easeOutCubic,
                                      );
                                    },
                                    child: AnimatedContainer(
                                      duration:
                                          const Duration(milliseconds: 180),
                                      curve: Curves.easeOut,
                                      width: isSelected ? 66 : 58,
                                      height: isSelected ? 66 : 58,
                                      padding:
                                          EdgeInsets.all(isSelected ? 3 : 0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.white
                                                  .withValues(alpha: 0.16),
                                          width: isSelected ? 2 : 1,
                                        ),
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(9),
                                        child: CachedNetworkImage(
                                          imageUrl: widget.imageUrls[index],
                                          fit: BoxFit.cover,
                                          placeholder: (context, url) =>
                                              Container(
                                            color: Colors.grey[850],
                                          ),
                                          errorWidget: (context, url, error) =>
                                              Container(
                                            color: Colors.grey[850],
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
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
