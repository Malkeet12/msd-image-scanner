import 'dart:convert';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:esys_flutter_share/esys_flutter_share.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_scanner/blocs/global/bloc.dart';
import 'package:image_scanner/blocs/global/event.dart';
// import 'package:image_cropper/image_cropper.dart';
import 'package:image_scanner/screens/document_details.dart';
import 'package:image_scanner/screens/documents/all_documents.dart';
import 'package:image_scanner/shared_widgets/my_app_bar.dart';
import 'package:image_scanner/shared_widgets/my_pdf_view.dart';
import 'package:image_scanner/theme/style.dart';
import 'package:image_scanner/util/date_formater.dart';
import 'package:image_scanner/util/storage_manager.dart';

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

  Choice _selectedChoice = choices[0]; // The app's "state".
  void _showDialog(doc) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Are you sure you want to delete this document"),
          // content: new Text("Are you sure you want to delete this document"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
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

  // void deleteImage() async {
  //   var userDocs = await StorageManager.getItem('userDocs') ?? "[]";
  //   userDocs = jsonDecode(userDocs);
  //   var currentDocumentId = widget.doc['documentId'];
  //   var index;
  //   for (var i = 0; i < userDocs.length; i++) {
  //     if (userDocs[i]['documentId'] == currentDocumentId) index = i;
  //   }
  //   var existingDoc = userDocs[index];
  //   if (existingDoc['images'].length == 1) {
  //     userDocs.removeAt(index);
  //     await StorageManager.setItem("userDocs", userDocs);
  //     Navigator.of(context).pop();
  //     Navigator.of(context).pop();
  //     Navigator.of(context).pop();
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(
  //         builder: (context) => AllDocuments(),
  //       ),
  //     );
  //   } else {
  //     existingDoc['images'].removeAt(_currentPage);
  //     userDocs[index] = existingDoc;
  //     existingDoc["timestamp"] = DateTime.now().millisecondsSinceEpoch;
  //     await StorageManager.setItem("userDocs", userDocs);
  //     Navigator.of(context).pop();
  //     Navigator.of(context).pop();
  //     Navigator.pushReplacement(
  //         context,
  //         MaterialPageRoute(
  //             builder: (context) => DocumentDetails(
  //                   id: id,
  //                 )));
  //   }
  // }

  void _select(doc, Choice choice) async {
    if (choice.title == 'Delete') {
      _showDialog(doc);
    } else if (choice.title == 'Edit') {
      var path = doc['images'][_currentPage];
      // File croppedFile = await ImageCropper.cropImage(
      //     sourcePath: path,
      //     aspectRatioPresets: [
      //       CropAspectRatioPreset.square,
      //       CropAspectRatioPreset.ratio3x2,
      //       CropAspectRatioPreset.original,
      //       CropAspectRatioPreset.ratio4x3,
      //       CropAspectRatioPreset.ratio16x9
      //     ],
      //     androidUiSettings: AndroidUiSettings(
      //         toolbarTitle: 'Edit image',
      //         toolbarColor: Colors.deepOrange,
      //         toolbarWidgetColor: Colors.white,
      //         initAspectRatio: CropAspectRatioPreset.original,
      //         lockAspectRatio: false),
      //     iosUiSettings: IOSUiSettings(
      //       minimumAspectRatio: 1.0,
      //     ));
      // widget.doc['images'].removeAt(_currentPage);
      // widget.doc['images'].insert(_currentPage, croppedFile.path);
      // var userDocs = await StorageManager.getItem('userDocs') ?? "[]";
      // userDocs = jsonDecode(userDocs);
      // var currentDocumentId = widget.doc['documentId'];
      // var index;
      // for (var i = 0; i < userDocs.length; i++) {
      //   if (userDocs[i]['documentId'] == currentDocumentId) index = i;
      // }
      // var existingDoc = userDocs[index];
      // existingDoc['images'].removeAt(_currentPage);
      // existingDoc['images'].add(croppedFile.path);
      // existingDoc["timestamp"] = DateTime.now().millisecondsSinceEpoch;
      // userDocs[index] = existingDoc;
      // await StorageManager.setItem("userDocs", userDocs);
    }

    // Causes the app to rebuild with the new _selectedChoice.
  }

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
    // var timestamp = widget.doc['timestamp'];
    // String delta = DateFormatter.readableDelta(timestamp);
    // var name = widget.doc[0];

    // var images = widget.doc;
    return BlocBuilder<GlobalBloc, Map>(
      builder: (context, currentState) {
        var images = currentState['doc']['data'];
        var name = currentState['doc']['name'];
        return Scaffold(
          backgroundColor: Colors.blueGrey,
          appBar: AppBar(
            backgroundColor: Colors.deepOrange,
            centerTitle: true,
            title: Text(name),
            actions: <Widget>[
              IconButton(
                icon: Icon(Icons.share),
                onPressed: () => _shareImage(images, name),
              ),
              PopupMenuButton<Choice>(
                onSelected: (choice) => _select(images, choice),
                itemBuilder: (BuildContext context) {
                  return choices.map((Choice choice) {
                    return PopupMenuItem<Choice>(
                      value: choice,
                      child: Text(choice.title),
                    );
                  }).toList();
                },
              ),
            ],
          ),
          body: Center(
            child: Container(
              // color: Colors.deepOrange,

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
                                  child: Stack(
                                    children: <Widget>[
                                      Image.file(
                                        File(
                                          item,
                                        ),
                                        fit: BoxFit.fill,
                                      ),
                                      Positioned(
                                        bottom: 0.0,
                                        left: 0.0,
                                        right: 0.0,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color.fromARGB(200, 0, 0, 0),
                                                Color.fromARGB(0, 0, 0, 0)
                                              ],
                                              begin: Alignment.bottomCenter,
                                              end: Alignment.topCenter,
                                            ),
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              vertical: 10.0, horizontal: 20.0),
                                          child: Text(
                                            "${images.indexOf(item) + 1}/${images.length}"
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )),
                            ),
                          ))
                      .toList()
                  //           child: Image.file(
                  //             File(
                  //               path,
                  //             ),
                  //             fit: BoxFit.fill,
                  //             // width: double.maxFinite,
                  //           ),
                  //         ),
                  //       ),
                  //       color: Colors.green,
                  //     ))
                  // .toList(),
                  ),
            ),
          ),
        );
      },
    );
  }
}

class Choice {
  const Choice({this.title, this.icon});

  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(title: 'Edit', icon: Icons.edit),
  const Choice(title: 'Delete', icon: Icons.delete),
];

class ChoiceCard extends StatelessWidget {
  const ChoiceCard({Key key, this.choice}) : super(key: key);

  final Choice choice;

  @override
  Widget build(BuildContext context) {
    final TextStyle textStyle = Theme.of(context).textTheme.headline4;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                actions: <Widget>[
                  new FlatButton(onPressed: null, child: Text('Close'))
                ],
              );
            });
      },
      child: Card(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Icon(choice.icon, size: 128.0, color: textStyle.color),
              Text(choice.title, style: textStyle),
            ],
          ),
        ),
      ),
    );
  }
}
