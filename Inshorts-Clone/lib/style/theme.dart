// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Project imports:
import 'package:inshort_clone/style/colors.dart';

final ThemeData kDarkThemeData = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xff222222),
  primaryColor: AppColor.accent,
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xff333333),
    iconTheme: IconThemeData(
      color: AppColor.accent,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.light,
  ),
  iconTheme: IconThemeData(
    color: AppColor.accent,
  ),
  fontFamily: "Montserrat",
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.dark)
      .copyWith(secondary: AppColor.accent),
);

final ThemeData kLightThemeData = ThemeData(
  canvasColor: AppColor.background,
  scaffoldBackgroundColor: Colors.white,
  brightness: Brightness.light,
  iconTheme: IconThemeData(
    color: AppColor.accent,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(
      color: AppColor.accent,
    ),
    systemOverlayStyle: SystemUiOverlayStyle.dark,
  ),
  fontFamily: "Montserrat",
  textSelectionTheme:
      TextSelectionThemeData(cursorColor: AppColor.primaryVariant),
  colorScheme: ColorScheme.fromSwatch(brightness: Brightness.light)
      .copyWith(secondary: AppColor.accent, error: AppColor.error),
);
