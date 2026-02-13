// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:inshort_clone/controller/provider.dart';
import 'package:inshort_clone/style/colors.dart';
import 'package:inshort_clone/style/text_style.dart';

class NewsCardAppBar extends StatelessWidget {
  const NewsCardAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Material(
        // color: Colors.white,
        child: SizedBox(
          height: 52,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          IconButton(
                            icon: const Icon(FeatherIcons.chevronLeft),
                            color: AppColor.accent,
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          const Text(
                            "Search",
                            style: AppTextStyle.appBarTitle,
                          )
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  Consumer<FeedProvider>(
                    builder: (context, value, child) =>
                        value.getCurentArticalIndex != 0
                            ? IconButton(
                                icon: const Icon(FeatherIcons.arrowUp),
                                onPressed: () {
                                  value.getfeedPageController?.animateToPage(0,
                                      duration: const Duration(milliseconds: 700),
                                      curve: Curves.easeInBack);
                                })
                            : Container(),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
