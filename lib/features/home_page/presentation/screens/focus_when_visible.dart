import 'dart:async';

import 'package:flutter/material.dart';

/// Attend que le champ existe et que son onglet soit visible avant le focus.
class FocusWhenVisible {
  const FocusWhenVisible._();

  static const int maxAttempts = 10;
  static const Duration retryDelay = Duration(milliseconds: 50);

  /// La condition pure est séparée pour être vérifiée sans ouvrir le clavier.
  static bool canFocus({
    required bool isMounted,
    required bool isAttached,
    required bool isActive,
  }) => isMounted && isAttached && isActive;

  static void request({
    required bool Function() isMounted,
    required bool Function() isAttached,
    required bool Function() isActive,
    required VoidCallback requestFocus,
    int attempts = 0,
    void Function(VoidCallback)? postFrame,
    void Function(Duration, VoidCallback)? delay,
  }) {
    final schedule =
        postFrame ??
        (callback) =>
            WidgetsBinding.instance.addPostFrameCallback((_) => callback());
    schedule(() {
      if (!isMounted()) return;
      if (canFocus(
        isMounted: true,
        isAttached: isAttached(),
        isActive: isActive(),
      )) {
        requestFocus();
      } else if (attempts < maxAttempts) {
        final wait = delay ?? (duration, callback) => Timer(duration, callback);
        wait(
          retryDelay,
          () => request(
            isMounted: isMounted,
            isAttached: isAttached,
            isActive: isActive,
            requestFocus: requestFocus,
            attempts: attempts + 1,
            postFrame: postFrame,
            delay: delay,
          ),
        );
      }
    });
  }
}
