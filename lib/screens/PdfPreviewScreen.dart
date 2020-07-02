import 'package:flutter/material.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String path;
  final files;

  PdfPreviewScreen({this.path, this.files});

  @override
  Widget build(BuildContext context) {
    var title = path.split("msd12")[1].split(".pdf")[0];
    return Scaffold(
      appBar: MyAppBar(text: 'Document$title'),
      body: GridView.count(
        scrollDirection: Axis.vertical,
        physics: const ClampingScrollPhysics(),
        shrinkWrap: true,
        crossAxisCount: 2,
        // crossAxisSpacing: 20,
        mainAxisSpacing: 4,
        // childAspectRatio: 0.8,
        children: List.generate(
          files.length,
          (index) {
            return Image(
              width: 30.0,
              image: AssetImage(
                path,
              ),
            );
          },
        ),
      ),
    );
  }
}
