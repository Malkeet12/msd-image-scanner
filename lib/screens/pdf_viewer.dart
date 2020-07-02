import 'dart:io';
import 'dart:math';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfViewer extends StatefulWidget {
  final doc;
  PdfViewer({Key key, this.doc}) : super(key: key);

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  var fullPath1;
  writeOnPdf(pdf, images) {
    for (var index = 0; index < images.length; index++) {
      File file = File(images[index]);
      final image = PdfImage.file(
        pdf.document,
        bytes: file.readAsBytesSync(),
      );
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.Center(
          child: pw.Image(image),
        ); // Center
      }));
    }
  }

  share(images) async {
    try {
      final pdf = pw.Document();
      writeOnPdf(pdf, images);
      var rng = new Random();
      var uid = rng.nextInt(pow(10, 6));
      Directory documentDirectory = await getApplicationDocumentsDirectory();

      String documentPath = documentDirectory.path;
      String fullPath = "$documentPath/msd12$uid.pdf";
      File file = File(fullPath);
      file.writeAsBytesSync(pdf.save());
      fullPath1 = fullPath;
      return fullPath;
      // final ByteData bytes = await rootBundle.load(fullPath);
      // await Share.file('File shared by image scanner',
      //     'Image scanner document.pdf', bytes.buffer.asUint8List(), 'text/csv',
      //     text: 'File shared by image scanner.');
    } catch (e) {
      print('error: $e');
    }
  }

  shareAsPdf() async {
    final ByteData bytes = await rootBundle.load(fullPath1);
    await Share.file('File shared by image scanner',
        'Image scanner document.pdf', bytes.buffer.asUint8List(), 'text/csv',
        text: 'File shared by image scanner.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('doc'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => shareAsPdf(),
          ),
        ],
      ),
      body: FutureBuilder<dynamic>(
          future: share(widget.doc['images']),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return SizedBox();
            var path = snapshot.data;
            return Container(
              child: MyPdfView(
                path: path,
              ),
            );
          }),
    );
  }
}
