// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:photo_view/photo_view.dart';

class ExpandedImageView extends StatelessWidget {
  final image;

  const ExpandedImageView({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: PhotoView(
                imageProvider: NetworkImage(image),
                // heroAttributes: PhotoViewHeroAttributes(
                //   transitionOnUserGestures: true,
                // ),
              ),
            ),
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                    icon: const Icon(
                      FeatherIcons.x,
                      size: 30,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context)),
              ),
            )
          ],
        ),
      ),
    );
  }
}
