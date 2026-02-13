// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:inshort_clone/controller/settings.dart';
import 'package:inshort_clone/global/global.dart';
import 'package:inshort_clone/style/colors.dart';
import 'package:inshort_clone/style/text_style.dart';
import '../../aplication_localization.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 1,
        title: Text(
          AppLocalizations.of(context).translate('settings'),
          style: AppTextStyle.appBarTitle.copyWith(
            fontSize: 18,
            color: Provider.of<SettingsProvider>(context, listen: false)
                    .isDarkThemeOn
                ? AppColor.background
                : AppColor.onBackground,
          ),
        ),
      ),
      body: Consumer<SettingsProvider>(
        builder: (context, settingsProvider, child) => ListView(
          children: <Widget>[
            ListTile(
              leading: const Icon(FeatherIcons.sunset),
              title: Text(AppLocalizations.of(context).translate('dark_theme')),
              subtitle: Text(
                  AppLocalizations.of(context).translate('darktheme_message')),
              onTap: () {
                settingsProvider.darkTheme(!settingsProvider.isDarkThemeOn);
              },
              trailing: Switch(
                  activeTrackColor: AppColor.accent,
                  value: settingsProvider.isDarkThemeOn,
                  onChanged: (status) {
                    settingsProvider.darkTheme(status);
                  }),
            ),
            ListTile(
              leading: const Icon(FontAwesomeIcons.language),
              title: Text(AppLocalizations.of(context).translate('language')),
              onTap: () {},
              trailing: DropdownButton<String>(
                  underline: Container(),
                  value: settingsProvider.activeLanguage,
                  items: Global.lang.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      settingsProvider.setLang(v);
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
