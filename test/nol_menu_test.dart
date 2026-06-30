import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:yanolja_clone/core/nol_menu.dart';
import 'package:yanolja_clone/presentation/widget/nol_my_icon.dart';

void main() {
  test('all category menu items have generated image assets', () {
    final quickItems = nolQuickMenu
        .where((item) => item.route != '/all-categories')
        .take(6)
        .toList();
    final groupedItems = nolMenuGroups.expand((group) => group.items).toList();
    final allCategoryItems = [...quickItems, ...groupedItems];

    expect(quickItems, hasLength(6));
    expect(groupedItems, hasLength(24));
    expect(allCategoryItems, hasLength(30));
    expect(allCategoryItems.map((item) => item.asset).toSet(), hasLength(30));

    final missingAssets = allCategoryItems
        .where((item) => !File(item.asset).existsSync())
        .map((item) => '${item.label}: ${item.asset}')
        .toList();

    expect(missingAssets, isEmpty);
  });

  test('generated icon png assets are transparent and tightly trimmed',
      () async {
    final failures = <String>[];

    for (final asset in _generatedIconAssets()) {
      final bytes = File(asset).readAsBytesSync();
      if (!_isAlphaPng(bytes)) {
        failures.add('$asset: PNG alpha channel is missing');
        continue;
      }

      final metrics = await _readAlphaMetrics(bytes);
      if (!metrics.hasTransparentPixel) {
        failures.add('$asset: transparent background pixels are missing');
      }
      if (!metrics.touchesTop ||
          !metrics.touchesRight ||
          !metrics.touchesBottom ||
          !metrics.touchesLeft) {
        failures.add('$asset: transparent canvas was not trimmed to content');
      }
    }

    expect(failures, isEmpty);
  });
}

List<String> _generatedIconAssets() {
  final quickItems =
      nolQuickMenu.where((item) => item.route != '/all-categories').take(6);
  final menuAssets = [
    ...quickItems.map((item) => item.asset),
    ...nolMenuGroups.expand((group) => group.items).map((item) => item.asset),
  ];
  const myTabAssets = [
    NolMyIconAsset.reservation,
    NolMyIconAsset.coupon,
    NolMyIconAsset.points,
    NolMyIconAsset.review,
    NolMyIconAsset.notification,
    NolMyIconAsset.settings,
    NolMyIconAsset.support,
    NolMyIconAsset.profileEdit,
    NolMyIconAsset.saved,
    NolMyIconAsset.recent,
    NolMyIconAsset.card,
    NolMyIconAsset.notice,
    NolMyIconAsset.location,
    NolMyIconAsset.language,
    NolMyIconAsset.security,
    NolMyIconAsset.theme,
  ];
  final nearbyAssets = Directory('assets/nearby_icons')
      .listSync()
      .whereType<File>()
      .map((file) => file.path)
      .where((path) => path.endsWith('.png'));
  final searchAssets = Directory('assets/search_icons')
      .listSync()
      .whereType<File>()
      .map((file) => file.path)
      .where((path) => path.endsWith('.png'));
  return [
    NolMenuIcons.appBarHamburger,
    NolMenuIcons.allReservationHub,
    ...menuAssets,
    ...myTabAssets,
    ...nearbyAssets,
    ...searchAssets,
  ];
}

bool _isAlphaPng(List<int> bytes) {
  const pngSignature = [137, 80, 78, 71, 13, 10, 26, 10];
  if (bytes.length < 33) return false;
  for (var i = 0; i < pngSignature.length; i++) {
    if (bytes[i] != pngSignature[i]) return false;
  }

  final colorType = bytes[25];
  if (colorType == 4 || colorType == 6) return true;

  for (var i = 8; i + 12 <= bytes.length;) {
    final length = (bytes[i] << 24) |
        (bytes[i + 1] << 16) |
        (bytes[i + 2] << 8) |
        bytes[i + 3];
    final type = String.fromCharCodes(bytes.sublist(i + 4, i + 8));
    if (type == 'tRNS') return true;
    if (type == 'IEND') return false;
    i += 12 + length;
  }
  return false;
}

Future<_AlphaMetrics> _readAlphaMetrics(List<int> bytes) async {
  final codec = await ui.instantiateImageCodec(Uint8List.fromList(bytes));
  final frame = await codec.getNextFrame();
  final image = frame.image;
  final byteData = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  final pixels = byteData!.buffer.asUint8List();
  final width = image.width;
  final height = image.height;
  image.dispose();

  var hasTransparentPixel = false;
  var touchesTop = false;
  var touchesRight = false;
  var touchesBottom = false;
  var touchesLeft = false;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final alpha = pixels[((y * width + x) * 4) + 3];
      if (alpha == 0) hasTransparentPixel = true;
      if (alpha > 8) {
        if (y == 0) touchesTop = true;
        if (x == width - 1) touchesRight = true;
        if (y == height - 1) touchesBottom = true;
        if (x == 0) touchesLeft = true;
      }
    }
  }

  return _AlphaMetrics(
    hasTransparentPixel: hasTransparentPixel,
    touchesTop: touchesTop,
    touchesRight: touchesRight,
    touchesBottom: touchesBottom,
    touchesLeft: touchesLeft,
  );
}

class _AlphaMetrics {
  final bool hasTransparentPixel;
  final bool touchesTop;
  final bool touchesRight;
  final bool touchesBottom;
  final bool touchesLeft;

  const _AlphaMetrics({
    required this.hasTransparentPixel,
    required this.touchesTop,
    required this.touchesRight,
    required this.touchesBottom,
    required this.touchesLeft,
  });
}
