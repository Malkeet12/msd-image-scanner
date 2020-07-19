import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/text_extraction/copy_text.dart';
import 'package:image_scanner/services/foreground_service.dart';

class ImagePreview extends StatefulWidget {
  const ImagePreview({
    Key key,
  }) : super(key: key);

  @override
  _ImagePreviewState createState() => _ImagePreviewState();
}

class _ImagePreviewState extends State<ImagePreview> {
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();
  var completeDoc;
  var labels = [];
  File clickedFile;
  bool isEmptyState = true;

  @override
  void initState() {
    super.initState();
    takePicture();
  }

  takePicture() {
    ForegroundService.registerCallBack("copyText", extractText);
    ForegroundService.start("openCameraForTextExtraction", "");
  }

  extractText(path) async {
    setState(() {
      isEmptyState = false;
    });

    try {
      clickedFile = File(path);
      var isFileExist = await clickedFile.exists();
      if (isFileExist) {
        var image = FirebaseVisionImage.fromFile(clickedFile);
        final VisionText visionText = await textRecognizer.processImage(image);
        completeDoc = visionText.text;
        var strings = [];
        for (TextBlock block in visionText.blocks) {
          for (TextLine line in block.lines) {
            strings.add(line);
          }
        }
        setState(() {
          labels = strings;
        });
      } else {
        setState(() {
          isEmptyState = true;
        });
      }
    } catch (e) {
      print(e.toString());
      setState(() {
        isEmptyState = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CopyText(
      file: clickedFile,
      isEmptyState: isEmptyState,
      labels: labels,
      completeDoc: completeDoc,
      ctaAction: takePicture,
    );
  }
}
