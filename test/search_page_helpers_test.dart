import 'package:baobabe_0_2/features/home_page/presentation/screens/explore_pagination.dart';
import 'package:baobabe_0_2/features/home_page/presentation/screens/focus_when_visible.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('le focus attend un widget monté, visible et actif', () {
    expect(
      FocusWhenVisible.canFocus(
        isMounted: true,
        isAttached: true,
        isActive: true,
      ),
      isTrue,
    );
    expect(
      FocusWhenVisible.canFocus(
        isMounted: false,
        isAttached: true,
        isActive: true,
      ),
      isFalse,
    );
    expect(
      FocusWhenVisible.canFocus(
        isMounted: true,
        isAttached: false,
        isActive: true,
      ),
      isFalse,
    );
  });

  test('la recherche retente le focus jusqu’à la visibilité', () {
    var attached = false;
    var focused = 0;
    final frames = <VoidCallback>[];
    final delays = <VoidCallback>[];
    FocusWhenVisible.request(
      isMounted: () => true,
      isAttached: () => attached,
      isActive: () => true,
      requestFocus: () => focused++,
      postFrame: frames.add,
      delay: (_, callback) => delays.add(callback),
    );
    frames.removeAt(0)();
    attached = true;
    delays.removeAt(0)();
    frames.removeAt(0)();
    expect(focused, 1);
  });

  test('la pagination commence à 90 % du défilement', () {
    expect(
      ExplorePagination.shouldLoadMore(pixels: 90, maxScrollExtent: 100),
      isTrue,
    );
    expect(
      ExplorePagination.shouldLoadMore(pixels: 89, maxScrollExtent: 100),
      isFalse,
    );
  });
}
