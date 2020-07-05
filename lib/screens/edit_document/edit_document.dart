import 'dart:io';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
import 'package:image_scanner/theme/style.dart';

class EditDoc extends StatefulWidget {
  final carouselInitialPage;
  const EditDoc({Key key, this.carouselInitialPage}) : super(key: key);

  @override
  _EditDocState createState() => _EditDocState();
}

class _EditDocState extends State<EditDoc> {
  int _currentPage = 0;
  @override
  void initState() {
    super.initState();
    _currentPage = widget.carouselInitialPage;
  }

  // Choice _selectedChoice = choices[0]; // The app's "state".
  void _showDialog(doc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: new Text("Are you sure you want to remove this image"),
          actions: <Widget>[
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            new FlatButton(
              child: new Text(
                "Delete",
              ),
              onPressed: () {
                var path = doc[_currentPage];
                BlocProvider.of<GlobalBloc>(context)
                    .add(DeleteFile(file: path));
                Navigator.of(context).pop();
                if (doc.length == 1) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  // void _select(doc, Choice choice) async {
  //   if (choice.title == 'Delete') {
  //     _showDialog(doc);
  //   } else if (choice.title == 'Edit') {
  //     var path = doc['images'][_currentPage];
  //   }
  // }

  Future<void> _shareImage(doc, name) async {
    try {
      var path = doc[_currentPage];
      var splitedPath = path.split(".");
      var docType = splitedPath[splitedPath.length - 1];
      final ByteData bytes = await rootBundle.load(path);
      await Share.file('Pdf genegerated by image scanner', '$name.$docType',
          bytes.buffer.asUint8List(), '*/*',
          text: 'Pdf genegerated by image scanner');
    } catch (e) {
      print('error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GlobalBloc, Map>(
      builder: (context, currentState) {
        var images = currentState['doc']['data'];
        var name = currentState['doc']['name'];
        return Scaffold(
          // backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            centerTitle: true,
            title: Text(name),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.delete_forever),
                onPressed: () => {_showDialog(images)},
              ),
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareImage(images, name),
              ),
              // PopupMenuButton<Choice>(
              //   onSelected: (choice) => _select(images, choice),
              //   itemBuilder: (BuildContext context) {
              //     return choices.map((Choice choice) {
              //       return PopupMenuItem<Choice>(
              //         value: choice,
              //         child: Text(choice.title),
              //       );
              //     }).toList();
              //   },
              // ),
            ],
          ),
          body: Center(
            child: Container(
              child: CarouselSlider(
                  options: CarouselOptions(
                      height: MediaQuery.of(context).size.height,
                      viewportFraction: 1,
                      initialPage: widget.carouselInitialPage,
                      enableInfiniteScroll: false,
                      onPageChanged: (index, reason) {
                        setState(() {
                          _currentPage = index;
                        });
                      },
                      scrollDirection: Axis.horizontal),
                  items: images
                      .map<Widget>((item) => Container(
                            child: Container(
                              margin: EdgeInsets.all(5.0),
                              child: ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5.0)),
                                  child: Column(
                                    children: <Widget>[
                                      Expanded(
                                        child: Image.file(
                                          File(
                                            item,
                                          ),
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                      Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 10.0, horizontal: 20.0),
                                        child: Text(
                                          "${images.indexOf(item) + 1}/${images.length}"
                                              .toString(),
                                          style: TextStyle(
                                            color: ColorShades.textSecGray3,
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ))
                      .toList()),
            ),
          ),
        );
      },
    );
  }
}
