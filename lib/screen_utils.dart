import 'package:flutter/material.dart';

class ScreenUtils {
  static late MediaQueryData _mediaQueryData;
  static late double screenWidth;
  static late double screenHeight;
  static late double devicePixelRatio;
  static late double statusBarHeight;
  static late double bottomBarHeight;

  // Base design dimensions (e.g. iPhone 13 / modern Android standard: 390x844)
  static const double baseWidth = 390.0;
  static const double baseHeight = 844.0;

  static void init(BuildContext context) {
    _mediaQueryData = MediaQuery.of(context);
    screenWidth = _mediaQueryData.size.width;
    screenHeight = _mediaQueryData.size.height;
    devicePixelRatio = _mediaQueryData.devicePixelRatio;
    statusBarHeight = _mediaQueryData.padding.top;
    bottomBarHeight = _mediaQueryData.padding.bottom;
  }

  // Width ratio scaling
  static double setWidth(num width) {
    return (screenWidth > 0) ? (width * screenWidth / baseWidth) : width.toDouble();
  }

  // Height ratio scaling
  static double setHeight(num height) {
    return (screenHeight > 0) ? (height * screenHeight / baseHeight) : height.toDouble();
  }

  // Font size scale (uses width scaling by default to maintain proportions)
  static double setSp(num fontSize) {
    return setWidth(fontSize);
  }
}

// Extensions for clean responsive code: 16.w, 24.h, 14.sp
extension ScreenUtilsExtension on num {
  double get w => ScreenUtils.setWidth(this);
  double get h => ScreenUtils.setHeight(this);
  double get sp => ScreenUtils.setSp(this);
}
