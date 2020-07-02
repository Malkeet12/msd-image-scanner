import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/build_list.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/primary_button.dart';
import 'package:image_scanner/shared_widgets/text_decoration.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:share/share.dart';

class GalleryView extends StatefulWidget {
  final scaffoldKey;

  const GalleryView({Key key, this.scaffoldKey}) : super(key: key);
  @override
  _GalleryViewState createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File _file;
  List labels = [];
  var completeDoc;
  final TextRecognizer textRecognizer =
      FirebaseVision.instance.textRecognizer();
  // FirebaseVisionTextDetector detector = FirebaseVisionTextDetector.instance;

  @override
  initState() {
    super.initState();
    uploadImage();
  }

  uploadImage() async {
    try {
      //var file = await ImagePicker.pickImage(source: ImageSource.camera);
      final picker = ImagePicker();
      var pickedFile = await picker.getImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _file = File(pickedFile.path);
        });
        try {
          var image = FirebaseVisionImage.fromFilePath(_file.path);
          final VisionText visionText =
              await textRecognizer.processImage(image);
          String text = visionText.text;
          //reseting labels list before adding new image data
          labels = [];
          for (TextBlock block in visionText.blocks) {
            final Rect boundingBox = block.boundingBox;
            final List<Offset> cornerPoints = block.cornerPoints;
            final String text = block.text;
            final List<RecognizedLanguage> languages =
                block.recognizedLanguages;
            print('languages $languages');
            print('text $text');
            for (TextLine line in block.lines) {
              // Same getters as TextBlock
              labels.add(line);
              for (TextElement element in line.elements) {
                // Same getters as TextBlock
              }
            }
          }
          setState(() {
            completeDoc = text;
            labels = labels;
          });
        } catch (e) {
          print(e.toString());
        }
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      print(e.toString());
      widget.scaffoldKey.currentState.showSnackBar(SnackBar(
        content: Text('The user did not allow photo access.'),
        backgroundColor: Colors.redAccent,
        duration: Duration(seconds: 2),
      ));

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: ColorShades.backgroundColorPrimary,
        appBar: MyAppBar(
            text: 'Image scanner',
            onBackTap: () {
              Navigator.pop(context);
            }),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: Center(
        child: FutureBuilder<Size>(
          future: CommonUtil.getImageSize(Image.file(
            _file,
          )),
          builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
            if (snapshot.hasData) {
              return Container(
                  foregroundDecoration:
                      TextDetectDecoration(labels, snapshot.data),
                  child: Image.file(_file, fit: BoxFit.fitWidth));
            } else {
              return Text('Detecting...');
            }
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Center(
        child: Container(
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                // if (_file == null)
                //   Column(
                //     children: <Widget>[
                //       PrimaryButton(
                //         onPressed: capureImage,
                //         text: 'Capture image',
                //       ),
                //       PrimaryButton(
                //         onPressed: uploadImage,
                //         text: 'Pick from gallery',
                //       ),
                //     ],
                //   ),
                if (_file != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: PrimaryButton(
                      onPressed: uploadImage,
                      text: 'Upload another',
                    ),
                  ),

                if (_file != null)
                  _buildImage(),
                if (_file != null)
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
              ],
            ),
          ),
        ),
      ),
    );
  }
}
