import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/pdf_viewer.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/edit_name_dialog.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/analytics_service.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class MyBottomSheet extends StatefulWidget {
  const MyBottomSheet({Key key, this.name, this.folderSizeReadable})
      : super(key: key);
  final name;
  final folderSizeReadable;

  @override
  _MyBottomSheetState createState() => _MyBottomSheetState();
}

class _MyBottomSheetState extends State<MyBottomSheet> {
  TextEditingController _controller = new TextEditingController();
  var fullPath, fileSize, savedPdfPath;

  @override
  void initState() {
    super.initState();
    generatePdf();
  }

  ListTile _createTileWithSecondartText(BuildContext context, String name,
      fileSize, IconData icon, Function action,
      {bool showIcon = true, Color iconColor = Colors.green}) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.grey,
      ),
      title: Row(
        children: <Widget>[
          Text(name),
          if (fileSize != null)
            Text(
              " ($fileSize)",
              style: Theme.of(context).textTheme.body2Medium.copyWith(
                    color: ColorShades.textSecGray3,
                  ),
            )
        ],
      ),
      onTap: () {
        Navigator.pop(context);
        if (action != null) action();
      },
    );
  }

  ListTile _createTile(
      BuildContext context, String name, IconData icon, Function action,
      {bool showIcon = true, Color iconColor = Colors.green, assetPath}) {
    return ListTile(
      leading: showIcon == true
          ? Icon(
              icon,
              color: Colors.grey,
            )
          : assetPath != null
              ? Image(
                  height: 24,
                  image: AssetImage(assetPath),
                )
              : SizedBox(),
      title: Text(name),
      onTap: () {
        Navigator.pop(context);
        if (action != null) action();
      },
    );
  }

  getCurrentDocument(context, id) async {
    BlocProvider.of<GlobalBloc>(context).add(GetCurrentDocument(id: id));
  }

  generatePdf() async {
    var name = widget.name;
    await getCurrentDocument(context, name);
    final pdf = pw.Document();
    print(BlocProvider.of<GlobalBloc>(context).state["doc"]["name"]);
    var images = BlocProvider.of<GlobalBloc>(context).state["doc"]["data"];
    if (images == null || images.length == 0) return;
    writeOnPdf(pdf, images);
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String documentPath = documentDirectory.path;
    fullPath = "$documentPath/$name.pdf";
    File file = File(fullPath);

    file.writeAsBytesSync(pdf.save());
    savedPdfPath = await ForegroundService.start("saveAsPdf", fullPath);
    print("savedPdfPath $savedPdfPath");
    File savedFile = File(savedPdfPath);
    var length = await savedFile.length();
    print("length $length");
    print("fullPath $fullPath");
    var size = await CommonUtil.formatBytes(length);
    setState(() {
      fileSize = size;
    });
  }

  shareFileAsPdf() async {
    AnalyticsService().sendEvent(
      name: 'share_pdf_from_bottom_sheet',
    );
    if (savedPdfPath != null) {
      var data = {"str": savedPdfPath, "type": "application/pd}f"};
      ForegroundService.start("shareFile", data);
    } else {
      var result = await ForegroundService.start("saveAsPdf", fullPath);
      var data = {"str": result, "type": "application/pd}f"};
      ForegroundService.start("shareFile", data);
    }
  }

  shareFilesPng(name) async {
    AnalyticsService().sendEvent(
      name: 'share_png_from_bottom_sheet',
    );
    ForegroundService.start('shareMultipleFiles', name);
  }

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
            return pw.Image(
              image,
              alignment: pw.Alignment.center,
              fit: pw.BoxFit.contain,
            );
          },
          margin: pw.EdgeInsets.all(0.0),
          pageFormat: PdfPageFormat.a4,
        ),
      );
    }
  }

  _rename(context, name) {
    AnalyticsService().sendEvent(
      name: 'rename_from_bottom_sheet',
    );
    _controller.text = name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditNameDialog(controller: _controller);
      },
    );
    setState(() {});
  }

  _deleteFolder(context, name) async {
    AnalyticsService().sendEvent(
      name: 'delete_folder_from_bottom_sheet',
    );
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text.rich(
              TextSpan(
                text: '', // default text style
                children: <TextSpan>[
                  TextSpan(
                    text: 'Are you sure you want to delete ',
                    style: Theme.of(context)
                        .textTheme
                        .h4
                        .copyWith(color: ColorShades.textSecGray3),
                  ),
                  TextSpan(
                    text: name,
                    style: Theme.of(context)
                        .textTheme
                        .h3
                        .copyWith(color: ColorShades.textSecGray3),
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              new FlatButton(
                child: new Text("CLOSE"),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              new FlatButton(
                child: new Text(
                  "DELETE",
                ),
                onPressed: () async {
                  ForegroundService.start("deleteFolder", name);
                  Navigator.pop(context);
                  // BlocProvider.of<GlobalBloc>(context).add(FetchAllDocuments());
                },
              ),
            ],
          );
        });
  }

  viewPdf(docs, name) {
    AnalyticsService().sendEvent(
      name: 'view_pdf_from_bottom_sheet',
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PdfViewer(doc: docs, name: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, Map>(builder: (context, currentState) {
      var docs = currentState['doc']['data'];
      var name = currentState['doc']['name'];
      if (name == null) return SizedBox();
      return SingleChildScrollView(
        child: Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, name, Icons.picture_as_pdf, null,
                  showIcon: false,
                  iconColor: Colors.red,
                  assetPath: "assets/images/pdf.png"),
              SizedBox(
                height: 12,
              ),
              Divider(
                color: ColorShades.textSecGray3,
                height: 5,
              ),
              _createTile(
                context,
                'View PDF',
                Icons.picture_as_pdf,
                () => viewPdf(docs, name),
                showIcon: true,
                iconColor: Colors.grey,
                assetPath: "assets/images/pdf_preview.png",
              ),
              _createTileWithSecondartText(
                  context,
                  'Share PNG',
                  widget.folderSizeReadable,
                  Icons.mobile_screen_share,
                  () => shareFilesPng(name),
                  showIcon: true,
                  iconColor: Colors.blueAccent),
              _createTileWithSecondartText(context, 'Share PDF', fileSize,
                  Icons.share, () => shareFileAsPdf(),
                  showIcon: true, iconColor: Colors.blueAccent),
              _createTile(
                  context, 'Rename', Icons.edit, () => _rename(context, name),
                  showIcon: true, iconColor: Colors.green),
              _createTile(context, 'Delete', Icons.delete_forever,
                  () => _deleteFolder(context, name),
                  showIcon: true, iconColor: Colors.red),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        ),
      );
    });
  }
}
