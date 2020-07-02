import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

class MyPdfView extends StatelessWidget {
  const MyPdfView({
    Key key,
    @required this.path,
  }) : super(key: key);

  final String path;

  @override
  Widget build(BuildContext context) {
    return PDFView(
      filePath: path,
      enableSwipe: true,
      pageSnap: false,
      autoSpacing: false,
      fitEachPage: true,
      pageFling: true,
      onRender: (_pages) {},
      onError: (error) {
        print(error.toString());
      },
      onPageError: (page, error) {
        print('$page: ${error.toString()}');
      },
      onViewCreated: (PDFViewController pdfViewController) {
        // _controller.complete(pdfViewController);
      },
      onPageChanged: (int page, int total) {
        print('page change: $page/$total');
      },
    );
  }
}
