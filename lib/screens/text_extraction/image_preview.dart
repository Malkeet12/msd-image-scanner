import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_scanner/screens/text_extraction/text_extraction_empty_state.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/build_list.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/my_drawer.dart';
import 'package:image_scanner/shared_widgets/text_decoration.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:share/share.dart';

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
  var temporaryImagePath = "";

  @override
  void initState() {
    super.initState();
    clickAnother();
  }

  clickAnother() {
    ForegroundService.registerCallBack("copyText", extractText);
    ForegroundService.start("openCameraForTextExtraction", "");
  }

  extractText(path) async {
    setState(() {
      temporaryImagePath = path;
    });

    try {
      File file = File(path);

      var image = FirebaseVisionImage.fromFile(file);
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
    } catch (e) {
      print(e.toString());
      setState(() {
        temporaryImagePath = "";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: MyAppBar(
        text: 'Copy text from image',
        color: Color(0xff4364A1),
      ),
      body: SingleChildScrollView(
        child: temporaryImagePath != ""
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                        child: FutureBuilder<Size>(
                          future: CommonUtil.getImageSize(Image.file(
                            File(temporaryImagePath),
                          )),
                          builder: (BuildContext context,
                              AsyncSnapshot<Size> snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                  foregroundDecoration: TextDetectDecoration(
                                      labels, snapshot.data),
                                  child: Image.file(File(temporaryImagePath),
                                      fit: BoxFit.fitWidth));
                            } else {
                              return Text('Detecting...');
                            }
                          },
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    child: BlueButton(
                      text: 'Share consolidated document',
                      onPressed: () {
                        AnalyticsService().sendEvent(
                          name: 'share_consolidated_doc_click',
                        );
                        final RenderBox box = context.findRenderObject();
                        Share.share(completeDoc,
                            sharePositionOrigin:
                                box.localToGlobal(Offset.zero) & box.size);
                      },
                    ),
                  ),
                  BuildList(texts: labels),
                  SizedBox(
                    height: 100,
                  )
                ],
              )
            : TextExtractionEmptyState(),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FloatingActionButton(
          backgroundColor: Color(0xff4364A1),
          child: Icon(
            Icons.camera_alt,
          ),
          onPressed: () => clickAnother(),
        ),
      ),
    );
  }
}
