import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/document_details.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/storage_manager.dart';

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
  var currentView = "grid";
  setCurrentDocument(id) async {
    BlocProvider.of<GlobalBloc>(context).add(GetCurrentDocument(id: id));
  }

  setUserView(value) async {
    setState(() {
      currentView = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.docs.length == 0) return SizedBox();

    List<Widget> list = new List<Widget>();
    for (var i = widget.docs.length - 1; i >= 0; i--) {
      var doc = widget.docs[i];
      var name = doc["name"];
      var image = doc["firstChild"];

      list.add(GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () async {
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
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Divider(color: Colors.black),
            ],
          ),
        ),
      ));
    }
    if (currentView == 'grid') {
      return Padding(
        padding: const EdgeInsets.only(bottom: 48.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  IconButton(
                    color: Colors.deepOrange,
                    icon: Icon(Icons.line_style),
                    onPressed: () => setUserView('linear'),
                  ),
                ],
              ),
            ),
            MyGridView(
              widget: widget,
              setCurrentDocument: setCurrentDocument,
            )
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 48.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                IconButton(
                  color: Colors.deepOrange,
                  icon: Icon(Icons.grid_on),
                  onPressed: () => setUserView('grid'),
                ),
              ],
            ),
          ),
          Column(children: list)
        ],
      ),
    );

    // return Column(children: list);

    // return MyGridView(widget: widget);
  }
}

class MyGridView extends StatelessWidget {
  const MyGridView({
    Key key,
    @required this.widget,
    this.setCurrentDocument,
  }) : super(key: key);
  final setCurrentDocument;
  final Documents widget;

  @override
  Widget build(BuildContext context) {
    var colors = [
      Colors.lightBlue,
      Colors.amberAccent,
      Colors.redAccent,
      Colors.greenAccent,
      Colors.tealAccent,
      Colors.lightGreenAccent
    ];

    return GridView.count(
      reverse: true,
      // childAspectRatio: 1,
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 10,
      // childAspectRatio: 0.8,
      children: List.generate(
        widget.docs.length,
        (index) {
          var rng = new Random();
          var uid = rng.nextInt(pow(5, 1));
          print(uid);
          return GestureDetector(
            behavior: HitTestBehavior.translucent,
            onTap: () async {
              await setCurrentDocument(widget.docs[index]['name']);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DocumentDetails(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(
                bottom: 10,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    child: Container(
                      decoration: BoxDecoration(
                          // color: colors[uid],
                          border: Border.all(
                              color: ColorShades.textSecGray3, width: 3.0)),
                      alignment: Alignment.center,
                      width: MediaQuery.of(context).size.width * 0.35,
                      // height: 150,
                      child: Image.file(
                        File(
                          widget.docs[index]['firstChild'],
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 44.0, vertical: 10),
                    child: Text(
                      widget.docs[index]['name'],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
