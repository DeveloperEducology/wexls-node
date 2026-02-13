// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_feather_icons/flutter_feather_icons.dart';

// Project imports:
import 'package:inshort_clone/aplication_localization.dart';
import 'package:inshort_clone/routes/simple_router.dart';
import 'package:inshort_clone/style/colors.dart';

appSearchBar(context) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(142),
    child: Material(
      elevation: 1,
      // color: Colors.white,
      child: GestureDetector(
        onTap: () {
          // TODO: Implement search screen
          // SimpleRouter.navigator.pushNamed(SimpleRouter.searchScreen);
        },
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 98, 16, 16),
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColor.surface,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                FeatherIcons.search,
                color: AppColor.iconGrey,
              ),
              const SizedBox(width: 16),
              Text(
                AppLocalizations.of(context).translate("search_message"),
                style: TextStyle(
                  color: AppColor.iconGrey,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
