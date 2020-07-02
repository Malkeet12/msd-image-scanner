import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_scanner/screens/document_details.dart';
import 'package:image_scanner/screens/edit_document/edit_document.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/date_formater.dart';

class Documents extends StatelessWidget {
  const Documents({
    Key key,
    @required this.docs,
  }) : super(key: key);

  final docs;

  @override
  Widget build(BuildContext context) {
    if (docs.length == 0) return SizedBox();

    List<Widget> list = new List<Widget>();
    docs.sort((a, b) {
      return a['timestamp']
          .toString()
          .toLowerCase()
          .compareTo(b['timestamp'].toString().toLowerCase());
    });
    for (var i = docs.length - 1; i >= 0; i--) {
      var doc = docs[i];
      var timestamp = doc['timestamp'];
      String delta = DateFormatter.readableDelta(timestamp);
      var name = doc['name'];
      var images = doc["images"];

      list.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DocumentDetails(
                doc: doc,
              ),
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
                        images[0],
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
                        Text(
                          delta.toString(),
                          style:
                              Theme.of(context).textTheme.body2Medium.copyWith(
                                    color: ColorShades.textPrimaryDark,
                                  ),
                        ),
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
