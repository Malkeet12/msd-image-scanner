import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/screens/document_details.dart';
import 'package:image_scanner/shared_widgets/img_preview.dart';
import 'package:image_scanner/shared_widgets/modal.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/common_util.dart';
import 'package:image_scanner/util/date_formater.dart';
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
  var currentView = "linear";
  setCurrentDocument(id) async {
    BlocProvider.of<GlobalBloc>(context).add(GetCurrentDocument(id: id));
  }

  setUserView(value) async {
    await StorageManager.setItem("userSelectedView", value);
    setState(() {
      currentView = value;
    });
  }

  openBottomSheet(context, name) async {
    Modal modal = new Modal();
    modal.mainBottomSheet(context, name);
  }

  getUserSelectedView() async {
    var value = await StorageManager.getItem("userSelectedView");
    return value ?? 'linear';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.docs.length == 0) return SizedBox();
    List<Widget> list = new List<Widget>();
    for (var i = widget.docs.length - 1; i >= 0; i--) {
      var doc = widget.docs[i];
      var name = doc["name"];
      var lastUpdated = doc["lastUpdated"];

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
                  Icon(
                    Icons.folder,
                    color: CommonUtil.getRandomColor(),
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
                        SizedBox(
                          height: 4,
                        ),
                        Text(
                          "Last edited ${DateFormatter.readableDelta(lastUpdated)}",
                          style:
                              Theme.of(context).textTheme.body2Medium.copyWith(
                                    color: ColorShades.textSecGray3,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: () => openBottomSheet(context, name),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, right: 12.0),
                      child: Icon(
                        Icons.more_vert,
                        color: Colors.black,
                      ),
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
    return FutureBuilder<dynamic>(
        future: getUserSelectedView(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return SizedBox();
          var isGrdiView = snapshot.data == 'grid';
          return Padding(
            padding: const EdgeInsets.only(bottom: 48.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Text(
                            'Last modified by me',
                            style:
                                Theme.of(context).textTheme.body1Bold.copyWith(
                                      color: ColorShades.textSecGray3,
                                    ),
                          ),
                          Icon(
                            Icons.arrow_downward,
                            size: 20,
                            color: ColorShades.textSecGray3,
                          )
                        ],
                      ),
                      IconButton(
                        color: Colors.deepOrange,
                        icon: isGrdiView
                            ? Icon(Icons.line_style)
                            : Icon(Icons.grid_on),
                        onPressed: () => isGrdiView
                            ? setUserView('linear')
                            : setUserView('grid'),
                      ),
                    ],
                  ),
                ),
                isGrdiView
                    ? MyGridView(
                        widget: widget,
                        setCurrentDocument: setCurrentDocument,
                        openBottomSheet: openBottomSheet,
                      )
                    : Column(children: list)
              ],
            ),
          );
        });
  }
}

class MyGridView extends StatelessWidget {
  const MyGridView({
    Key key,
    @required this.widget,
    this.setCurrentDocument,
    this.openBottomSheet,
  }) : super(key: key);
  final setCurrentDocument;
  final openBottomSheet;
  final Documents widget;
  // openBottomSheet(context, name) async {
  //   Modal modal = new Modal();
  //   modal.mainBottomSheet(context, name);
  // }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      scrollDirection: Axis.vertical,
      physics: const ClampingScrollPhysics(),
      shrinkWrap: true,
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 25,
      children: List.generate(
        widget.docs.length,
        (index) {
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
            child: Column(
              children: <Widget>[
                Flexible(
                  child: ImgPreview(path: widget.docs[index]["firstChild"]),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () =>
                      openBottomSheet(context, widget.docs[index]['name']),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.0, vertical: 12.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.folder,
                          color: CommonUtil.getRandomColor(),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child: Text(
                            widget.docs[index]['name'],
                            style:
                                Theme.of(context).textTheme.body1Bold.copyWith(
                                      color: ColorShades.textSecGray3,
                                    ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        SizedBox(
                          width: 8,
                        ),
                        Icon(
                          Icons.more_vert,
                          color: Colors.black,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
