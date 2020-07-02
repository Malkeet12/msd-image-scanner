import 'package:flutter/material.dart';
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

    for (var i = 0; i < docs.length; i++) {
      var doc = docs[i];
      var timestamp = doc['timestamp'];
      String delta = DateFormatter.readableDelta(timestamp);
      var name = doc['name'];
      var path = doc["path"];

      list.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditDoc(doc: doc),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16),
          margin: EdgeInsets.only(
            bottom: 16,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                height: 72.0,
                width: 72.0,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(color: Colors.orange, spreadRadius: 3),
                  ],
                ),
                child: MyPdfView(
                  path: path,
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
                      style: Theme.of(context).textTheme.body2Medium.copyWith(
                            color: ColorShades.textPrimaryDark,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ));
    }
    return Column(children: list);
  }
}
