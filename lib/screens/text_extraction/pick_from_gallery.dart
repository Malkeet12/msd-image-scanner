import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_scanner/screens/text_extraction/copy_text.dart';

class PickFromGallery extends StatefulWidget {
  const PickFromGallery({
    Key key,
  }) : super(key: key);
  @override
  _PickFromGalleryState createState() => _PickFromGalleryState();
}

class _PickFromGalleryState extends State<PickFromGallery> {
  final GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();
  File _file;
  List labels = [];
  var completeDoc;
  File clickedFile;
  bool isEmptyState = true;
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();

  @override
  initState() {
    super.initState();
    uploadImage();
  }

  uploadImage() async {
    try {
      final picker = ImagePicker();
      var pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        try {
          clickedFile = File(pickedFile.path);
          var isFileExist = await clickedFile.exists();
          if (isFileExist) {
            var image = FirebaseVisionImage.fromFile(clickedFile);
            final VisionText visionText =
                await textRecognizer.processImage(image);
            completeDoc = visionText.text;
            var strings = [];
            for (TextBlock block in visionText.blocks) {
              for (TextLine line in block.lines) {
                strings.add(line);
              }
            }
            setState(() {
              labels = strings;
              isEmptyState = false;
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
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CopyText(
      file: clickedFile,
      isEmptyState: isEmptyState,
      labels: labels,
      completeDoc: completeDoc,
      ctaAction: uploadImage,
      ctaIcon: Icons.photo_library,
    );
  }
}
