import 'package:flutter/material.dart';

class OtherTheme extends ThemeExtension<OtherTheme> {
  final Color? warning;

  const OtherTheme({
    this.warning,
  });

  @override
  OtherTheme copyWith({
    Color? warning,
  }) {
    return OtherTheme(
      warning: warning ?? this.warning,
    );
  }

  @override
  ThemeExtension<OtherTheme> lerp(
    covariant ThemeExtension<OtherTheme>? other,
    double t,
  ) {
    if (other is! OtherTheme) return this;
    return OtherTheme(
      warning: Color.lerp(warning, other.warning, t),
    );
  }
}
