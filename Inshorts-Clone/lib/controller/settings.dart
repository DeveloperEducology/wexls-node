// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:hive/hive.dart';

class SettingsProvider extends ChangeNotifier {
  bool isDarkThemeOn = Hive.isBoxOpen('settingsBox') ? (Hive.box('settingsBox').get('isDarkModeOn') ?? false) : false;
  String activeLanguage = Hive.isBoxOpen('settingsBox') ? (Hive.box('settingsBox').get('activeLang') ?? "English") : "English";
  String localeCode = "en";

  String getActiveLanguageCode() {
    if (!Hive.isBoxOpen('settingsBox')) return "en";
    final value = Hive.box('settingsBox').get('activeLang');
    switch (value) {
      case "ಕನ್ನಡ":
        return "kn";
      case "हिंदी":
        return "hi";
      case "मರಾଠୀ":
        return "mr";
      default:
        return "en";
    }
  }

  void darkTheme(bool status) {
    isDarkThemeOn = status;

    if (Hive.isBoxOpen('settingsBox')) {
      final themeBox = Hive.box('settingsBox');
      themeBox.put('isDarkModeOn', status);
    }
    
    notifyListeners();
  }

  void setLang(String value) {
    activeLanguage = value;

    if (Hive.isBoxOpen('settingsBox')) {
      final langBox = Hive.box('settingsBox');

      switch (value) {
        case "ಕನ್ನಡ":
          langBox.put('activeLang', "ಕನ್ನಡ");
          localeCode = "kn";
          break;
        case "हिंदी":
          langBox.put('activeLang', "हिंदी");
          localeCode = "hi";
          break;
        case "मराठी":
          langBox.put('activeLang', "मರಾଠୀ");
          localeCode = "mr";
          break;
        default:
          langBox.put('activeLang', "English");
          localeCode = "en";
          break;
      }
    }

    notifyListeners();
  }
}
