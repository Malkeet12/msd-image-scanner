import 'dart:io';
import 'dart:math';

import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:image_scanner/theme/style.dart';
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
  var fullPath;

  writeOnPdf(pdf, images) {
    for (var index = 0; index < images.length; index++) {
      File file = File(images[index]);
      final image = PdfImage.file(
        pdf.document,
        bytes: file.readAsBytesSync(),
      );
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return
                // pw.FittedBox(
                //   fit:
                // pw.BoxFit.fill,
                // child:
                pw.Image(
              image,
              alignment: pw.Alignment.center,
              fit: pw.BoxFit.contain,
              // width: double.infinity,
              // width: MediaQuery.of(ctx).size.width * 2,
              // height: MediaQuery.of(ctx).size.height * 2,
              // ),
            ); // Center
          },
          margin: pw.EdgeInsets.all(0.0),
          pageFormat: PdfPageFormat.a4,
          // theme: pw.ThemeData.withFont(),
          // clip: true,
        ),
      );
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
      fullPath = "$documentPath/msd12$uid.pdf";
      File file = File(fullPath);
      file.writeAsBytesSync(pdf.save());
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
    final ByteData bytes = await rootBundle.load(fullPath);
    await Share.file('File shared by image scanner',
        'Image scanner document.pdf', bytes.buffer.asUint8List(), 'text/csv',
        text: 'File shared by image scanner.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorShades.textPrimaryDark,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Pdf view'),
        centerTitle: true,
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
              color: ColorShades.textPrimaryDark,
              child: MyPdfView(
                path: path,
              ),
            );
          }),
    );
  }
}
