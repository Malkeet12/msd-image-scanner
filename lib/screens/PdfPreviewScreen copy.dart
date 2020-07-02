import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
import 'package:image_scanner/shared_widgets/primary_button.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String path;

  PdfPreviewScreen({this.path});

  @override
  Widget build(BuildContext context) {
    return
        // Scaffold(
        //     body:
        PDFViewerScaffold(
      appBar: AppBar(
        title: Text("Share as pdf"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              try {
                final ByteData bytes = await rootBundle.load(path);
                await Share.file(
                    'File shared by image scanner',
                    'Image scanner document.pdf',
                    bytes.buffer.asUint8List(),
                    'text/csv',
                    text: 'File shared by image scanner.');
              } catch (e) {
                print('error: $e');
              }
            },
          ),
        ],
      ),
      path: path,
    );
    // floatingActionButton: FloatingActionButton(
    //   child: Icon(Icons.camera_alt),
    //   // Provide an onPressed callback.
    //   onPressed: () async {
    //     Future<void> _shareImage() async {
    //       try {
    //         final ByteData bytes = await rootBundle.load(path);
    //         await Share.file('esys image', 'esys.png',
    //             bytes.buffer.asUint8List(), 'image/png',
    //             text: 'My optional text.');
    //       } catch (e) {
    //         print('error: $e');
    //       }
    //     }
    //   },
    // ));
  }
}
