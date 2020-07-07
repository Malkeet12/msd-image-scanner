import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfViewer extends StatefulWidget {
  final doc;
  final name;
  PdfViewer({Key key, this.doc, this.name}) : super(key: key);

  @override
  _PdfViewerState createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  var fullPath;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  writeOnPdf(pdf, images) {
    for (var index = 0; index < images.length; index++) {
      File file = File(images[index]["path"]);
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
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      Directory tempDir = await getTemporaryDirectory();
      String tempPath = tempDir.path;
      String documentPath = documentDirectory.path;
      fullPath = "$documentPath/${widget.name}.pdf";
      File file = File(fullPath);
      file.writeAsBytesSync(pdf.save());
      return fullPath;
    } catch (e) {
      print('error: $e');
    }
  }

  Future<String> downloadPdf(ctx) async {
    var result = await ForegroundService.start("saveAsPdf", fullPath);
    _scaffoldKey.currentState.showSnackBar(SnackBar(
      content: Text('File saved at $result'),
      duration: const Duration(seconds: 2),
    ));
  }

  shareFile() async {
    var result = await ForegroundService.start("saveAsPdf", fullPath);
    var data = {"str": result, "type": "application/pdf"};
    ForegroundService.start("shareFile", data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorShades.textPrimaryDark,
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        title: Text('Pdf view'),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.file_download),
            onPressed: () => downloadPdf(context),
          ),
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () => shareFile(),
          ),
        ],
      ),
      body: FutureBuilder<dynamic>(
          future: share(widget.doc),
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
