import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:yanolja_clone/core/nol_menu.dart';

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
}
