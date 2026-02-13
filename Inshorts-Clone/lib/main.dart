// Flutter imports:
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:inshort_clone/controller/provider.dart';
import 'package:inshort_clone/controller/settings.dart';
import 'package:inshort_clone/model/news_model.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive differently for web vs mobile
  if (kIsWeb) {
    await Hive.initFlutter();
  } else {
    await Hive.initFlutter();
  }
  
  Hive.registerAdapter(ArticlesAdapter());

  await Hive.openBox('settingsBox');
  await Hive.openBox<Articles>('bookmarks');
  await Hive.openBox<Articles>('unreads');

  final isDarkModeOn = Hive.box('settingsBox').get('isDarkModeOn');
  SettingsProvider().darkTheme(isDarkModeOn ?? false);

  final lang = Hive.box('settingsBox').get('activeLang');
  SettingsProvider().setLang(lang ?? "English");

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black,
      statusBarColor: Colors.black,
      statusBarBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>(
            create: (_) => SettingsProvider()),
        ChangeNotifierProvider<FeedProvider>(create: (_) => FeedProvider()),
      ],
      child: const App(),
    ),
  );
}
