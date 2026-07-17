import 'package:flutter/foundation.dart';

bool get isAppleDevice {
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}
