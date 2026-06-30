import 'dart:io';

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

  test('generated icon png assets include transparent alpha channels', () {
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

    final alphaMissing = [...menuAssets, ...myTabAssets]
        .where((asset) => !_isAlphaPng(File(asset).readAsBytesSync()))
        .toList();

    expect(alphaMissing, isEmpty);
  });
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
