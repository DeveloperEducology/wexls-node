// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:inshort_clone/controller/feed_controller.dart';
import 'package:inshort_clone/global/global.dart';
import 'package:inshort_clone/style/colors.dart';
import 'package:inshort_clone/style/text_style.dart';

class TopicCard extends StatelessWidget {
  final String icon;
  final String title;
  final VoidCallback onTap;

  const TopicCard({super.key, required this.icon, required this.title, required this.onTap});
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FeedController.addCurrentPage(1);
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.all(8),
        height: Global.height(context) * 0.2,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColor.accent,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            Align(
              alignment: Alignment.center,
              child: Image.asset(
                "assets/icons/$icon.png",
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => const Icon(Icons.topic, size: 70),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(6.0),
                child: Text(
                  title,
                  style: AppTextStyle.topiccardTitle,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
