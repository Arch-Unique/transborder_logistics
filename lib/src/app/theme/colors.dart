import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../global/services/app_service.dart';

abstract class AppColors {
  // static const Color primaryColorBackground = Color(0xFFFFFFFF);

  //Text Colors
  // static const Color textColor = Color(0xFF1A1A1A);
  static const Color accentColor = Color(0xFF0C89D2);
  // static const Color darkTextColor = Color(0xFF000000);
  // static  const Color lightTextColor = Color(0xFFA3A3A3);

  //Action Colors
  // static const Color disabledColor = Color(0xFFE8E8E8);
  // static const Color borderColor = Color(0xFFE8E8E8);
  // static const Color circleBorderColor = Color(0xFFE8E8E8);
  // static const Color textBorderColor = Color(0xFFE8E8E8);
  static const Color textFieldColorOld = Colors.transparent;
  static const Color textFieldColor = Colors.transparent;

  //Other Colors
  static const Color red = Color(0xFFFF1F1F);
  static const Color green = Color(0xFF00D743);
  static const Color yellow = Color(0xFFFFB400);
  // static const Color white = Colors.white;
  // static const Color black = Colors.black;
  // static const Color grey = Colors.grey;
  static const Color transparent = Colors.transparent;
  static final appService = Get.find<AppService>();

  static Color get primaryColorBackground {
    return appService.isDarkMode.value
        ? const Color(0xFF000000)
        : const Color(0xFFFFFFFF);
  }

  static Color get textColor {
    return appService.isDarkMode.value
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF1A1A1A);
  }

  static Color get darkTextColor {
    return appService.isDarkMode.value
        ? const Color(0xFFE0E0E0)
        : const Color(0xFF000000);
  }

  static Color get lightTextColor {
    return appService.isDarkMode.value
        ? const Color(0xFF9E9E9E)
        : const Color(0xFFA3A3A3);
  }

  static Color get borderColor {
    return appService.isDarkMode.value
        ? const Color(0xFF9E9E9E)
        : const Color(0xFFE8E8E8);
  }

  static Color get disabledColor {
    return appService.isDarkMode.value
        ? const Color(0xFF9E9E9E)
        : const Color(0xFFE8E8E8);
  }

  static Color get circleBorderColor {
    return appService.isDarkMode.value
        ? const Color(0xFF9E9E9E)
        : const Color(0xFFE8E8E8);
  }

  // Convenience getters for common colors
  static Color get white {
    return appService.isDarkMode.value ? const Color(0xFF000000) : Colors.white;
  }

  static Color get black {
    return appService.isDarkMode.value ? Colors.white : Colors.black;
  }

  static Color get grey {
    return appService.isDarkMode.value ? const Color(0xFF9E9E9E) : Colors.grey;
  }

  static Color get textBorderColor {
    return appService.isDarkMode.value
        ? const Color(0xFF9E9E9E)
        : const Color(0xFFE8E8E8);
  }

  static const int _primaryColorValue = 0xFFDB261D;

  static const MaterialColor primaryColor =
      MaterialColor(_primaryColorValue, <int, Color>{
        50: Color(0xFFFBE9E7),
        100: Color(0xFFFFCDD2),
        200: Color(0xFFEF9A9A),
        300: Color(0xFFE57373),
        400: Color(0xFFEF5350),
        500: Color(_primaryColorValue),
        600: Color(0xFFC62828),
        700: Color(0xFFB71C1C),
        800: Color(0xFF8B1515),
        900: Color(0xFF5F0E0E),
      });
}
