import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_scanner/screens/text_extraction/text_extraction_empty_state.dart';
import 'package:image_scanner/shared_widgets/blue_button.dart';
import 'package:image_scanner/shared_widgets/build_list.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/my_drawer.dart';
import 'package:image_scanner/shared_widgets/text_decoration.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:share/share.dart';

class CopyText extends StatelessWidget {
  const CopyText({
    Key key,
    @required this.labels,
    @required this.completeDoc,
    this.ctaAction,
    this.file,
    this.isEmptyState,
  }) : super(key: key);
  final ctaAction;
  final List labels;
  final completeDoc;
  final isEmptyState;
  final file;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: MyDrawer(),
      appBar: MyAppBar(
        text: 'Copy text from image',
        color: Color(0xff4364A1),
      ),
      body: SingleChildScrollView(
        child: !isEmptyState
            ? Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height / 2,
                      child: Center(
                        child: FutureBuilder<Size>(
                          future: CommonUtil.getImageSize(Image.file(
                            file,
                          )),
                          builder: (BuildContext context,
                              AsyncSnapshot<Size> snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                  foregroundDecoration: TextDetectDecoration(
                                      labels, snapshot.data),
                                  child:
                                      Image.file(file, fit: BoxFit.fitWidth));
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
          onPressed: () => ctaAction(),
        ),
      ),
    );
  }
}
