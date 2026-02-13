// Dart imports:
import 'dart:typed_data';
import 'dart:ui' as ui;

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// Package imports:
import 'package:share_plus/share_plus.dart';
import 'package:provider/provider.dart';

// Project imports:
import 'package:inshort_clone/controller/provider.dart';

void convertWidgetToImageAndShare(BuildContext context, GlobalKey? containerKey) async {
  if (containerKey == null) return;
  
  RenderRepaintBoundary? renderRepaintBoundary =
      containerKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (renderRepaintBoundary == null) return;
  
  ui.Image boxImage = await renderRepaintBoundary.toImage(pixelRatio: 1);
  ByteData? byteData = await boxImage.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;
  
  Uint8List uInt8List = byteData.buffer.asUint8List();
  try {
    await Share.shareXFiles(
        [XFile.fromData(uInt8List, name: 'inshortClone.png', mimeType: 'image/png')],
        text:
            'This message sent from *inshorts Clone* made by *Sanjay Soni*\nFork this repository on *Github*\n\n https://github.com/imSanjaySoni/Inshorts-Clone.');
  } catch (e) {
    print('error: $e');
  }

  Provider.of<FeedProvider>(context, listen: false).setWatermarkVisible(false);
}
