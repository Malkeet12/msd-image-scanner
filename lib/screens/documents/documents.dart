import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/document_details.dart';
import 'package:image_scanner/screens/edit_document/edit_document.dart';
import 'package:image_scanner/services/foreground_service.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/date_formater.dart';

class Documents extends StatefulWidget {
  const Documents({
    Key key,
    @required this.docs,
  }) : super(key: key);

  final docs;

  @override
  _DocumentsState createState() => _DocumentsState();
}

class _DocumentsState extends State<Documents> {
  setCurrentDocument(id) async {
    BlocProvider.of<GlobalBloc>(context).add(GetCurrentDocument(id: id));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.docs.length == 0) return SizedBox();

    List<Widget> list = new List<Widget>();
    // docs.sort((a, b) {
    //   return a['timestamp']
    //       .toString()
    //       .toLowerCase()
    //       .compareTo(b['timestamp'].toString().toLowerCase());
    // });
    for (var i = widget.docs.length - 1; i >= 0; i--) {
      var doc = widget.docs[i];
      // var timestamp = doc['timestamp'];
      // String delta = DateFormatter.readableDelta(timestamp);
      var name = doc["name"];
      var image = doc["firstChild"];

      list.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
          // var res = await ForegroundService.start(
          //     'getGroupImages', path[path.length - 2]);
          // return res;
          await setCurrentDocument(name);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentDetails(),
            ),
          );
        },
        child: Container(
          color: ColorShades.textColorOffWhite,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          // margin: EdgeInsets.only(
          //   bottom: 8,
          // ),
          child: Column(
            children: <Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Container(
                    // height: 72.0,
                    width: 72.0,
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(20),
                      // color: Colors.black,
                      boxShadow: [
                        BoxShadow(spreadRadius: 2),
                      ],
                    ),
                    child: Image.file(
                      File(
                        image,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.h4.copyWith(
                                color: ColorShades.textPrimaryDark,
                              ),
                        ),
                        // Text(
                        //   'delta'.toString(),
                        //   style:
                        //       Theme.of(context).textTheme.body2Medium.copyWith(
                        //             color: ColorShades.textPrimaryDark,
                        //           ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              // if (i > 0)
              Divider(color: Colors.black),
            ],
          ),
        ),
      ));
    }
    return Column(children: list);
  }
}
