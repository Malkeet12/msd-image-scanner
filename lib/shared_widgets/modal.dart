import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/edit_name_dialog.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class Modal {
  TextEditingController _controller = new TextEditingController();
  var fullPath, fileSize, savedPdfPath;

  mainBottomSheet(BuildContext context, name) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          print('generating pdf $fullPath');
          if (fullPath == null) generatePdf(context, name);

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              _createTile(context, name, Icons.picture_as_pdf, null,
                  showIcon: true, iconColor: Colors.red),
              SizedBox(
                height: 12,
              ),
              Divider(
                color: ColorShades.textSecGray3,
                height: 5,
              ),
              _createTileWithSecondartText(context, 'Share as pdf', fileSize,
                  Icons.picture_as_pdf, () => shareFileAsPdf(),
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
          );
        });
  }

  ListTile _createTileWithSecondartText(BuildContext context, String name,
      fileSize, IconData icon, Function action,
      {bool showIcon = true, Color iconColor = Colors.green}) {
    return ListTile(
      leading: Icon(
        icon,
        color: iconColor,
      ),
      title: Row(
        children: <Widget>[
          Text(name),
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
      {bool showIcon = true, Color iconColor = Colors.green}) {
    return ListTile(
      leading: showIcon == true
          ? Icon(
              icon,
              color: iconColor,
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

  generatePdf(context, name) async {
    await getCurrentDocument(context, name);
    final pdf = pw.Document();
    var images = BlocProvider.of<GlobalBloc>(context).state["doc"]["data"];
    writeOnPdf(pdf, images);
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String documentPath = documentDirectory.path;
    fullPath = "$documentPath/$name.pdf";
    File file = File(fullPath);
    file.writeAsBytesSync(pdf.save());
    savedPdfPath = await ForegroundService.start("saveAsPdf", fullPath);
    File savedFile = File(savedPdfPath);
    var length = await savedFile.length();
    print("length $length");
    print("fullPath $fullPath");
    fileSize = CommonUtil.formatBytes(length);
  }

  shareFileAsPdf() async {
    if (savedPdfPath != null) {
      var data = {"str": savedPdfPath, "type": "application/pd}f"};
      ForegroundService.start("shareFile", data);
    } else {
      var result = await ForegroundService.start("saveAsPdf", fullPath);
      var data = {"str": result, "type": "application/pd}f"};
      ForegroundService.start("shareFile", data);
    }
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

  shareFile() async {
    var result = await ForegroundService.start("saveAsPdf", fullPath);
    var data = {"str": result, "type": "application/pdf"};
    ForegroundService.start("shareFile", data);
  }

  _rename(context, name) {
    _controller.text = name;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditNameDialog(controller: _controller);
      },
    );
  }

  _deleteFolder(context, name) async {
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
}
