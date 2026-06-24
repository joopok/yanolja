import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:yanolja_clone/core/theme/yanolja_theme.dart';
import 'package:yanolja_clone/data/model/accommodation.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_app_bar.dart';
import 'package:yanolja_clone/presentation/widget/yanolja_brand_surfaces.dart';

class YanoljaShareData {
  final String title;
  final String subtitle;
  final String url;
  final String message;
  final String? priceLabel;

  const YanoljaShareData({
    required this.title,
    required this.subtitle,
    required this.url,
    required this.message,
    this.priceLabel,
  });

  factory YanoljaShareData.accommodation(Accommodation accommodation) {
    final priceLabel = '${YanoljaFormat.price(accommodation.price)}원부터';
    final url =
        'https://yanolja-clone.app/detail/${Uri.encodeComponent(accommodation.id)}';
    return YanoljaShareData(
      title: accommodation.name,
      subtitle: accommodation.address,
      url: url,
      priceLabel: priceLabel,
      message: [
        accommodation.name,
        accommodation.address,
        priceLabel,
        '여기가어때에서 확인하기',
        url,
      ].join('\n'),
    );
  }

  String get shareTextWithoutUrl {
    return [
      title,
      subtitle,
      if (priceLabel != null) priceLabel!,
      '여기가어때에서 확인하기',
    ].join('\n');
  }
}

Future<void> showYanoljaSocialShareSheet({
  required BuildContext context,
  required YanoljaShareData data,
}) {
  return showModalBottomSheet<void>(
    context: context,
    useSafeArea: true,
    isScrollControlled: true,
    barrierColor: Colors.black.withValues(alpha: 0.42),
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => _ShareBottomSheet(
      parentContext: context,
      data: data,
    ),
  );
}

enum _ShareChannel {
  kakao,
  naver,
  facebook,
  instagram,
  x,
  copy,
}

enum _ShareLaunchMode {
  direct,
  copyThenOpen,
  copyOnly,
}

class _ShareBottomSheet extends StatelessWidget {
  final BuildContext parentContext;
  final YanoljaShareData data;

  const _ShareBottomSheet({
    required this.parentContext,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.78,
      minChildSize: 0.48,
      maxChildSize: 0.96,
      expand: false,
      builder: (context, scrollController) {
        return _ShareSurface(
          scrollController: scrollController,
          data: data,
          parentContext: parentContext,
          onClose: () => Navigator.of(context).pop(),
          onFullScreen: () {
            Navigator.of(context).pop();
            _showFullSharePopup(parentContext, data);
          },
        );
      },
    );
  }
}

class _ShareSurface extends StatelessWidget {
  final ScrollController scrollController;
  final YanoljaShareData data;
  final BuildContext parentContext;
  final VoidCallback onClose;
  final VoidCallback onFullScreen;

  const _ShareSurface({
    required this.scrollController,
    required this.data,
    required this.parentContext,
    required this.onClose,
    required this.onFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    final channels = _ShareChannel.values;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: Material(
        color: Colors.white,
        child: ListView(
          controller: scrollController,
          padding: EdgeInsets.fromLTRB(
            18,
            10,
            18,
            18 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            const _SheetGrabber(),
            const SizedBox(height: 12),
            _ShareHeader(
              onClose: onClose,
              onFullScreen: onFullScreen,
            ),
            const SizedBox(height: 16),
            _SharePreviewCard(
              data: data,
              onPreview: () => _showLayerPreview(context, data),
            ),
            const SizedBox(height: 18),
            const _ShareSectionTitle(
              title: '공유할 채널',
              subtitle: '브랜드 아이콘과 공식 공유 경로를 기준으로 연결합니다.',
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = (constraints.maxWidth - 10) / 2;
                return Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    for (final channel in channels)
                      SizedBox(
                        width: itemWidth,
                        child: _ShareChannelTile(
                          channel: channel,
                          data: data,
                          parentContext: parentContext,
                          closeCurrentPopup: onClose,
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 18),
            _ShareNotice(data: data),
          ],
        ),
      ),
    );
  }
}

class _SheetGrabber extends StatelessWidget {
  const _SheetGrabber();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 38,
        height: 4,
        decoration: BoxDecoration(
          color: YanoljaColors.divider,
          borderRadius: BorderRadius.circular(YanoljaRadius.pill),
        ),
      ),
    );
  }
}

class _ShareHeader extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onFullScreen;

  const _ShareHeader({
    required this.onClose,
    required this.onFullScreen,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: YanoljaColors.textPrimary,
            borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          ),
          child: const Icon(
            Icons.ios_share_rounded,
            color: Colors.white,
            size: 23,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '공유하기',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: YanoljaColors.textPrimary,
                  letterSpacing: 0,
                ),
              ),
              SizedBox(height: 2),
              Text(
                '숙소 정보를 원하는 채널로 보낼 수 있어요',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: YanoljaColors.textSecondary,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
        _HeaderIconButton(
          tooltip: '전체 화면',
          icon: Icons.open_in_full_rounded,
          onTap: onFullScreen,
        ),
        const SizedBox(width: 6),
        _HeaderIconButton(
          tooltip: '닫기',
          icon: Icons.close_rounded,
          onTap: onClose,
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  const _HeaderIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: YanoljaPressable(
        pressedScale: 0.92,
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: YanoljaColors.surfaceAlt,
            borderRadius: BorderRadius.circular(YanoljaRadius.pill),
          ),
          child: Icon(icon, size: 19, color: YanoljaColors.textPrimary),
        ),
      ),
    );
  }
}

class _SharePreviewCard extends StatelessWidget {
  final YanoljaShareData data;
  final VoidCallback onPreview;

  const _SharePreviewCard({
    required this.data,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: YanoljaColors.textPrimary,
        borderRadius: BorderRadius.circular(22),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          const Positioned.fill(child: _ShareCardPattern()),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.14),
                        borderRadius: BorderRadius.circular(YanoljaRadius.pill),
                      ),
                      child: const Text(
                        'NOL SHARE CARD',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                    const Spacer(),
                    YanoljaPressable(
                      pressedScale: 0.94,
                      onTap: onPreview,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(YanoljaRadius.pill),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.visibility_outlined,
                              size: 14,
                              color: YanoljaColors.textPrimary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '미리보기',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                color: YanoljaColors.textPrimary,
                                letterSpacing: 0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 26),
                Text(
                  data.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    height: 1.16,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data.subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.74),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0,
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    if (data.priceLabel != null)
                      _PreviewMetric(
                        label: '최저가',
                        value: data.priceLabel!,
                      ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _PreviewMetric(
                        label: '링크',
                        value: data.url.replaceFirst('https://', ''),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareCardPattern extends StatelessWidget {
  const _ShareCardPattern();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _ShareCardPatternPainter());
  }
}

class _ShareCardPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = Colors.white.withValues(alpha: 0.09);
    final path = Path()
      ..moveTo(size.width * 0.06, size.height * 0.78)
      ..cubicTo(
        size.width * 0.28,
        size.height * 0.40,
        size.width * 0.56,
        size.height * 0.92,
        size.width * 0.94,
        size.height * 0.24,
      );
    canvas.drawPath(path, paint);

    final dot = Paint()..color = YanoljaColors.primary.withValues(alpha: 0.24);
    canvas.drawCircle(Offset(size.width * 0.88, size.height * 0.18), 58, dot);
    canvas.drawCircle(
      Offset(size.width * 0.13, size.height * 0.98),
      48,
      Paint()..color = YanoljaColors.mint.withValues(alpha: 0.18),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PreviewMetric extends StatelessWidget {
  final String label;
  final String value;

  const _PreviewMetric({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(YanoljaRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.58),
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareSectionTitle extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ShareSectionTitle({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16.5,
            fontWeight: FontWeight.w900,
            color: YanoljaColors.textPrimary,
            letterSpacing: 0,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: YanoljaColors.textTertiary,
            letterSpacing: 0,
          ),
        ),
      ],
    );
  }
}

class _ShareChannelTile extends StatelessWidget {
  final _ShareChannel channel;
  final YanoljaShareData data;
  final BuildContext parentContext;
  final VoidCallback closeCurrentPopup;

  const _ShareChannelTile({
    required this.channel,
    required this.data,
    required this.parentContext,
    required this.closeCurrentPopup,
  });

  @override
  Widget build(BuildContext context) {
    final meta = _ShareMeta.of(channel, data);
    return YanoljaPressable(
      pressedScale: 0.97,
      onTap: () => _share(context, meta),
      child: Container(
        constraints: const BoxConstraints(minHeight: 82),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(YanoljaRadius.lg),
          border: Border.all(color: YanoljaColors.border),
          boxShadow: const [
            BoxShadow(
              color: Color(0x08000000),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            _SocialMark(meta: meta),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    meta.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w900,
                      color: YanoljaColors.textPrimary,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    meta.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: YanoljaColors.textTertiary,
                      letterSpacing: 0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _share(BuildContext context, _ShareMeta meta) async {
    HapticFeedback.selectionClick();
    closeCurrentPopup();

    if (meta.mode != _ShareLaunchMode.direct) {
      unawaited(Clipboard.setData(ClipboardData(text: data.message)));
    }

    var launched = false;
    for (final uri in meta.launchUris) {
      launched = await _tryLaunch(uri);
      if (launched) break;
    }

    if (meta.mode == _ShareLaunchMode.copyOnly || !launched) {
      unawaited(Clipboard.setData(ClipboardData(text: data.message)));
      if (parentContext.mounted) {
        _showShareToast(parentContext, '공유 링크를 복사했어요');
      }
      return;
    }

    if (meta.mode == _ShareLaunchMode.copyThenOpen && parentContext.mounted) {
      _showShareToast(parentContext, '${meta.label}에 붙여넣을 링크를 복사했어요');
    }
  }

  Future<bool> _tryLaunch(Uri uri) async {
    try {
      return launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  }
}

class _ShareNotice extends StatelessWidget {
  final YanoljaShareData data;

  const _ShareNotice({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: YanoljaColors.surfaceAlt,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: YanoljaColors.textSecondary,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              '카카오톡과 인스타그램은 앱 정책상 링크를 먼저 복사한 뒤 앱을 열어요. 공유 문구에는 ${data.title} 정보가 포함됩니다.',
              style: const TextStyle(
                color: YanoljaColors.textSecondary,
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ShareMeta {
  final String label;
  final String caption;
  final Color backgroundColor;
  final Color iconColor;
  final _ShareChannel channel;
  final _ShareLaunchMode mode;
  final IconData? materialIcon;
  final FaIconData? brandIcon;
  final List<Uri> launchUris;

  const _ShareMeta({
    required this.label,
    required this.caption,
    required this.backgroundColor,
    required this.iconColor,
    required this.channel,
    required this.mode,
    required this.launchUris,
    this.materialIcon,
    this.brandIcon,
  });

  factory _ShareMeta.of(_ShareChannel channel, YanoljaShareData data) {
    final title = data.title;
    final url = data.url;
    final encodedShareText = Uri.encodeComponent(data.shareTextWithoutUrl);
    final encodedUrl = Uri.encodeComponent(url);

    return switch (channel) {
      _ShareChannel.kakao => _ShareMeta(
          label: '카카오톡',
          caption: '복사 후 앱 열기',
          backgroundColor: const Color(0xFFFEE500),
          iconColor: const Color(0xFF191600),
          channel: channel,
          mode: _ShareLaunchMode.copyThenOpen,
          brandIcon: FontAwesomeIcons.kakaoTalk,
          launchUris: [
            Uri.parse('kakaotalk://launch'),
            Uri.https('www.kakaocorp.com', '/page/service/service/kakaotalk'),
          ],
        ),
      _ShareChannel.naver => _ShareMeta(
          label: '네이버',
          caption: '공유 페이지 열기',
          backgroundColor: const Color(0xFF03C75A),
          iconColor: Colors.white,
          channel: channel,
          mode: _ShareLaunchMode.direct,
          launchUris: [
            Uri.https('share.naver.com', '/web/shareView', {
              'url': url,
              'title': title,
            }),
          ],
        ),
      _ShareChannel.facebook => _ShareMeta(
          label: '페이스북',
          caption: '공유 페이지 열기',
          backgroundColor: const Color(0xFF1877F2),
          iconColor: Colors.white,
          channel: channel,
          mode: _ShareLaunchMode.direct,
          brandIcon: FontAwesomeIcons.facebookF,
          launchUris: [
            Uri.https('www.facebook.com', '/sharer/sharer.php', {
              'u': url,
            }),
          ],
        ),
      _ShareChannel.instagram => _ShareMeta(
          label: '인스타그램',
          caption: '복사 후 앱 열기',
          backgroundColor: const Color(0xFFE1306C),
          iconColor: Colors.white,
          channel: channel,
          mode: _ShareLaunchMode.copyThenOpen,
          brandIcon: FontAwesomeIcons.instagram,
          launchUris: [
            Uri.parse('instagram://app'),
            Uri.https('www.instagram.com', '/'),
          ],
        ),
      _ShareChannel.x => _ShareMeta(
          label: 'X',
          caption: '게시 작성 열기',
          backgroundColor: const Color(0xFF111111),
          iconColor: Colors.white,
          channel: channel,
          mode: _ShareLaunchMode.direct,
          brandIcon: FontAwesomeIcons.xTwitter,
          launchUris: [
            Uri.parse(
              'https://twitter.com/intent/tweet?text=$encodedShareText&url=$encodedUrl',
            ),
          ],
        ),
      _ShareChannel.copy => _ShareMeta(
          label: '링크 복사',
          caption: '클립보드 저장',
          backgroundColor: YanoljaColors.textSecondary,
          iconColor: Colors.white,
          channel: channel,
          mode: _ShareLaunchMode.copyOnly,
          materialIcon: Icons.link_rounded,
          launchUris: const [],
        ),
    };
  }
}

class _SocialMark extends StatelessWidget {
  final _ShareMeta meta;

  const _SocialMark({required this.meta});

  @override
  Widget build(BuildContext context) {
    final decoration = switch (meta.channel) {
      _ShareChannel.instagram => BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF9CE34),
              Color(0xFFEE2A7B),
              Color(0xFF6228D7),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
        ),
      _ => BoxDecoration(
          color: meta.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
    };

    return Container(
      width: 48,
      height: 48,
      alignment: Alignment.center,
      decoration: decoration,
      child: _icon(),
    );
  }

  Widget _icon() {
    if (meta.brandIcon != null) {
      return FaIcon(
        meta.brandIcon,
        color: meta.iconColor,
        size: meta.channel == _ShareChannel.facebook ? 25 : 24,
      );
    }
    if (meta.channel == _ShareChannel.naver) {
      return Text(
        'N',
        style: TextStyle(
          color: meta.iconColor,
          fontSize: 25,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
        ),
      );
    }
    return Icon(meta.materialIcon, color: meta.iconColor, size: 25);
  }
}

Future<void> _showFullSharePopup(
  BuildContext context,
  YanoljaShareData data,
) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '공유 전체 화면 닫기',
    barrierColor: Colors.black.withValues(alpha: 0.55),
    transitionDuration: const Duration(milliseconds: 240),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return SafeArea(
        child: Material(
          color: Colors.white,
          child: _FullSharePopup(
            parentContext: context,
            data: data,
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return FadeTransition(
        opacity: curved,
        child: child,
      );
    },
  );
}

class _FullSharePopup extends StatelessWidget {
  final BuildContext parentContext;
  final YanoljaShareData data;

  const _FullSharePopup({
    required this.parentContext,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: YanoljaAppBar.modal(
        title: '공유 미리보기',
        onBackPress: () => Navigator.of(context).pop(),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          _SharePreviewCard(
            data: data,
            onPreview: () => _showLayerPreview(context, data),
          ),
          const SizedBox(height: 22),
          const _ShareSectionTitle(
            title: '전체 화면에서 공유',
            subtitle: '화면을 닫지 않고 공유 대상을 더 넓게 확인합니다.',
          ),
          const SizedBox(height: 12),
          for (final channel in _ShareChannel.values) ...[
            _ShareChannelTile(
              channel: channel,
              data: data,
              parentContext: parentContext,
              closeCurrentPopup: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 10),
          ],
          _ShareNotice(data: data),
        ],
      ),
    );
  }
}

Future<void> _showLayerPreview(
  BuildContext context,
  YanoljaShareData data,
) {
  final toastContext = Navigator.of(context, rootNavigator: true).context;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: '공유 문구 미리보기 닫기',
    barrierColor: Colors.black.withValues(alpha: 0.45),
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (dialogContext, animation, secondaryAnimation) {
      return Center(
        child: Material(
          color: Colors.transparent,
          child: _ShareLayerPopup(
            data: data,
            toastContext: toastContext,
          ),
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeInCubic,
      );
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(
          scale: Tween<double>(begin: 0.94, end: 1).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _ShareLayerPopup extends StatelessWidget {
  final YanoljaShareData data;
  final BuildContext toastContext;

  const _ShareLayerPopup({
    required this.data,
    required this.toastContext,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.sizeOf(context).width - 40,
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2A000000),
            blurRadius: 30,
            offset: Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  '공유 문구 미리보기',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: YanoljaColors.textPrimary,
                    letterSpacing: 0,
                  ),
                ),
              ),
              IconButton(
                tooltip: '닫기',
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: YanoljaColors.surfaceAlt,
              borderRadius: BorderRadius.circular(YanoljaRadius.lg),
              border: Border.all(color: YanoljaColors.border),
            ),
            child: Text(
              data.message,
              style: const TextStyle(
                fontSize: 13,
                height: 1.55,
                color: YanoljaColors.textPrimary,
                fontWeight: FontWeight.w700,
                letterSpacing: 0,
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: () async {
                if (!context.mounted) return;
                unawaited(Clipboard.setData(ClipboardData(text: data.message)));
                Navigator.of(context).pop();
                _showShareToast(toastContext, '공유 문구를 복사했어요');
              },
              style: FilledButton.styleFrom(
                backgroundColor: YanoljaColors.textPrimary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(YanoljaRadius.md),
                ),
              ),
              icon: const Icon(Icons.content_copy_rounded, size: 18),
              label: const Text(
                '문구 복사',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showShareToast(BuildContext context, String message) {
  final overlay = Navigator.maybeOf(context, rootNavigator: true)?.overlay ??
      Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;

  late final OverlayEntry entry;
  entry = OverlayEntry(
    builder: (context) => _ShareToast(
      message: message,
      onDismissed: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _ShareToast extends StatefulWidget {
  final String message;
  final VoidCallback onDismissed;

  const _ShareToast({
    required this.message,
    required this.onDismissed,
  });

  @override
  State<_ShareToast> createState() => _ShareToastState();
}

class _ShareToastState extends State<_ShareToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
      reverseDuration: const Duration(milliseconds: 160),
    );
    final curved = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _opacity = Tween<double>(begin: 0, end: 1).animate(curved);
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 1600), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.paddingOf(context).top + 12,
      left: 18,
      right: 18,
      child: FadeTransition(
        opacity: _opacity,
        child: Material(
          color: Colors.transparent,
          child: _ShareToastCard(message: widget.message),
        ),
      ),
    );
  }
}

class _ShareToastCard extends StatelessWidget {
  final String message;

  const _ShareToastCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: YanoljaColors.textPrimary,
        borderRadius: BorderRadius.circular(YanoljaRadius.lg),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26000000),
            blurRadius: 18,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: YanoljaColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
