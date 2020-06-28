import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/build_list.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/primary_button.dart';
import 'package:image_scanner/shared_widgets/text_decoration.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:share/share.dart';

class ImagePreview extends StatelessWidget {
  final String imagePath;
  final currentLabels;
  final completeDoc;

  const ImagePreview(
      {Key key, this.imagePath, this.currentLabels, this.completeDoc})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorShades.backgroundColorPrimary,
      appBar: MyAppBar(text: 'Image preview'),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Center(
              child: FutureBuilder<Size>(
                future: CommonUtil.getImageSize(Image.file(
                  File(imagePath),
                )),
                builder: (BuildContext context, AsyncSnapshot<Size> snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                        foregroundDecoration:
                            TextDetectDecoration(currentLabels, snapshot.data),
                        child:
                            Image.file(File(imagePath), fit: BoxFit.fitWidth));
                  } else {
                    return Text('Detecting...');
                  }
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: PrimaryButton(
                onPressed: () => Navigator.pop(context),
                text: 'Upload another',
              ),
            ),
            // Image.file(File(imagePath)),
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
            BuildList(texts: currentLabels),
          ],
        ),
      ),
    );
  }
}
